//
//  ContentView.swift
//  ESP32BLEReceiver
//
//  Created by Ashish Chittimilla on 5/30/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var bleManager = BLEManager()

    var body: some View {
        VStack(spacing: 20) {
            // Current readings
            Text("Die Temp: \(bleManager.dieTemp) °C")
                .font(.title2)
            Text("Obj Temp: \(bleManager.objTemp) °C")
                .font(.title2)

            Text("Data points: \(bleManager.objectTempHistory.count)")
                .font(.caption)
                .foregroundColor(.gray)

            // Chart
            Group {
                if bleManager.objectTempHistory.isEmpty {
                    Text("No data yet. Waiting for BLE...")
                        .foregroundColor(.secondary)
                } else {
                    Chart {
                        // Raw temp line
                        ForEach(bleManager.objectTempHistory) { reading in
                            LineMark(
                                x: .value("Time", reading.timestamp),
                                y: .value("Temperature", reading.temperature),
                                series: .value("Series", "Raw")
                            )
                            .interpolationMethod(.monotone)
                            .foregroundStyle(.blue)
                        }

                        // Smoothed average line
                        ForEach(rollingAverages(), id: \.timestamp) { avg in
                            LineMark(
                                x: .value("Time", avg.timestamp),
                                y: .value("Temperature", avg.temperature),
                                series: .value("Series", "Smoothed")
                            )
                            .interpolationMethod(.monotone)
                            .foregroundStyle(.red)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                        }
                    }
                    .frame(height: 240)
                    .chartLegend(position: .bottom)
                    .animation(.easeInOut, value: bleManager.objectTempHistory)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            bleManager.startScanning()
        }
    }

    // 30s rolling average
    private func rollingAverages() -> [BLEManager.TemperatureReading] {
        let allReadings = bleManager.objectTempHistory
        var smoothed: [BLEManager.TemperatureReading] = []

        for current in allReadings {
            let windowStart = current.timestamp.addingTimeInterval(-30)
            let window = allReadings.filter { $0.timestamp >= windowStart && $0.timestamp <= current.timestamp }
            let avgTemp = window.map(\.temperature).reduce(0, +) / Double(max(window.count, 1))

            smoothed.append(
                .init(timestamp: current.timestamp, temperature: avgTemp)
            )
        }

        return smoothed
    }
}
