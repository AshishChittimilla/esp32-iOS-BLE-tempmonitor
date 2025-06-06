# ESP32-iOS BLE Temperature Monitor

This project demonstrates a Bluetooth Low Energy (BLE) temperature monitoring system using an ESP32 microcontroller and an iOS application. The ESP32 reads temperature data and broadcasts it over BLE. The iOS app connects to the ESP32, displays real-time temperature readings, and visualizes the data using a dynamic chart.

## 📂 Project Structure

```
esp32-iOS-BLE-tempmonitor/
├── iOS/
│   └── ESP32BLEReceiver/   # SwiftUI-based iOS application
└── esp32/                  # ESP32 firmware code
```

## 🚀 Features

* **ESP32**:

  * Reads temperature data using a connected sensor.
  * Broadcasts temperature readings over BLE.([github.com][2], [randomnerdtutorials.com][1])

* **iOS Application**:

  * Scans and connects to the ESP32 BLE device.
  * Displays real-time temperature readings.
  * Visualizes temperature trends using charts.([forums.swift.org][3])

## 🛠 Setup Instructions

### ESP32 Firmware

1. **Prerequisites**:

   * ESP32 development board.
   * Temperature sensor (e.g., TMP006) connected appropriately.
   * Arduino IDE with ESP32 board support installed.([github.com][2])

2. **Installation**:

   * Navigate to the `esp32/` directory.
   * Open the firmware code in Arduino IDE.
   * Select the correct board and port.
   * Upload the code to the ESP32.

### iOS Application

1. **Prerequisites**:

   * macOS with Xcode installed.
   * An iOS device or simulator.

2. **Installation**:

   * Navigate to the `iOS/ESP32BLEReceiver/` directory.
   * Open the `.xcodeproj` file in Xcode.
   * Build and run the application on your device or simulator.

## 📷 Screenshots

*Screenshot of the iOS application displaying temperature readings and charts.*
![ESP32BLEReceiver_app](https://github.com/user-attachments/assets/09d8e804-2113-494a-bb25-3f742b32c536)


## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.([github.com][4])

---
