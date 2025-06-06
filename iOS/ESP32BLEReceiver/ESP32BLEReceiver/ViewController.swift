//
//  ViewController.swift
//  ESP32BLEReceiver
//
//  Created by Ashish Chittimilla on 5/30/25.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var centralManager: CBCentralManager!
    var espPeripheral: CBPeripheral?

    // Replace with your ESP32 BLE service UUID and characteristic UUID
    let espServiceUUID = CBUUID(string: "FFE0")
    let espCharacteristicUUID = CBUUID(string: "FFE1")

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // Called when the central manager state updates
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth ON, start scanning")
            centralManager.scanForPeripherals(withServices: [espServiceUUID], options: nil)
        } else {
            print("Bluetooth not available")
        }
    }

    // Discovered peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Found peripheral: \(peripheral.name ?? "Unknown")")
        espPeripheral = peripheral
        espPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    // Connected to peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to ESP32")
        peripheral.discoverServices([espServiceUUID])
    }

    // Discover services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("Service found: \(service.uuid)")
                if service.uuid == espServiceUUID {
                    peripheral.discoverCharacteristics([espCharacteristicUUID], for: service)
                }
            }
        }
    }

    // Discover characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Characteristic found: \(characteristic.uuid)")
                if characteristic.uuid == espCharacteristicUUID {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }

    // Receive data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            if let string = String(data: data, encoding: .utf8) {
                print("Received: \(string)")
                // You can update your UI here with the temperature value
            }
        }
    }
}

