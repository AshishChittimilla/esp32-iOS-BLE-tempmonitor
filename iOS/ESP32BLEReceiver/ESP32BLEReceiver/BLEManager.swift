//
//  BLEManager.swift
//  ESP32BLEReceiver
//
//  Created by Ashish Chittimilla on 5/30/25.
//


import CoreBluetooth
import Foundation

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?

    @Published var dieTemp: String = "-"
    @Published var objTemp: String = "-"

    struct TemperatureReading: Identifiable, Equatable {
        let id = UUID()
        let timestamp: Date
        let temperature: Double
    }

    @Published var objectTempHistory: [TemperatureReading] = []

    private let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789abc")
    private let objUUID     = CBUUID(string: "12345678-1234-1234-1234-123456789abd")
    private let dieUUID     = CBUUID(string: "12345678-1234-1234-1234-123456789abe")

    override init() {
        super.init()
        print("👋 BLEManager init()")
        centralManager = CBCentralManager(delegate: self, queue: nil)

        // Optional: log if BLE never activates
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("🕒 2s later: centralManager.state = \(self.centralManager.state.rawValue)")
        }
    }

    func startScanning() {
        if centralManager.state == .poweredOn {
            print("🔍 Starting BLE scan for service \(serviceUUID)")
            centralManager.scanForPeripherals(withServices: [serviceUUID])
        } else {
            print("⚠️ Cannot start scan: Bluetooth not powered on")
        }
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("🔁 centralManagerDidUpdateState: \(central.state.rawValue)")
        if central.state == .poweredOn {
            print("✅ BLE powered ON — scanning for peripherals...")
            centralManager.scanForPeripherals(withServices: [serviceUUID])
        } else {
            print("❌ BLE state: \(central.state.rawValue)")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("📡 Discovered peripheral: \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices([serviceUUID])
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("❌ Service discovery error: \(error.localizedDescription)")
            return
        }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics([dieUUID, objUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("❌ Characteristic discovery error: \(error.localizedDescription)")
            return
        }
        for characteristic in service.characteristics ?? [] {
            print("🔧 Found characteristic: \(characteristic.uuid)")
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Notification error: \(error.localizedDescription)")
        } else {
            print("✅ Notifications enabled for \(characteristic.uuid)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("❌ Data update error: \(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value,
              let str = String(data: data, encoding: .utf8) else {
            print("⚠️ Invalid data from \(characteristic.uuid)")
            return
        }

        DispatchQueue.main.async {
            if characteristic.uuid == self.dieUUID {
                self.dieTemp = str
            } else if characteristic.uuid == self.objUUID {
                self.objTemp = str

                if let tempVal = Double(str.trimmingCharacters(in: .whitespacesAndNewlines)) {
                    let reading = TemperatureReading(timestamp: Date(), temperature: tempVal)
                    self.objectTempHistory.append(reading)
                    if self.objectTempHistory.count > 30 {
                        self.objectTempHistory.removeFirst()
                    }
                }
            }
        }
    }
}
