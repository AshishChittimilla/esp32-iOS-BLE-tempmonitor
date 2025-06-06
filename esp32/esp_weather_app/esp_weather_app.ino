#include <Wire.h>
#include <Adafruit_TMP006.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// TMP006 sensor at address 0x44
Adafruit_TMP006 tmp006(0x44);

// BLE service and characteristic UUIDs (randomly generated)
#define SERVICE_UUID        "12345678-1234-1234-1234-123456789abc"
#define CHAR_OBJ_TEMP_UUID  "12345678-1234-1234-1234-123456789abd"
#define CHAR_DIE_TEMP_UUID  "12345678-1234-1234-1234-123456789abe"

BLECharacteristic *objTempCharacteristic;
BLECharacteristic *dieTempCharacteristic;

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("TMP006 BLE Sensor");

  // Initialize I2C for TMP006
  Wire.begin(23, 22);
  if (!tmp006.begin()) {
    Serial.println("Failed to initialize TMP006! Check wiring.");
    while (1);
  }

  // Initialize BLE
  BLEDevice::init("ESP32_TMP006");  // Name of your BLE device
  BLEServer *pServer = BLEDevice::createServer();

  BLEService *pService = pServer->createService(SERVICE_UUID);

  objTempCharacteristic = pService->createCharacteristic(
                          CHAR_OBJ_TEMP_UUID,
                          BLECharacteristic::PROPERTY_READ |
                          BLECharacteristic::PROPERTY_NOTIFY
                        );

  objTempCharacteristic->addDescriptor(new BLE2902());

  dieTempCharacteristic = pService->createCharacteristic(
                          CHAR_DIE_TEMP_UUID,
                          BLECharacteristic::PROPERTY_READ |
                          BLECharacteristic::PROPERTY_NOTIFY
                        );

  dieTempCharacteristic->addDescriptor(new BLE2902());

  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->start();

  Serial.println("Waiting for a client to connect...");
}

void loop() {
  double objTempF = tmp006.readObjTempC();
  double dieTempC = tmp006.readDieTempC();

   // Convert object temp from °F to °C
  double objTempC = (objTempF - 32.0) * 5.0 / 9.0;

  // Convert float to string with 2 decimal places
  char objTempStr[8];
  dtostrf(objTempC, 6, 2, objTempStr);

  char dieTempStr[8];
  dtostrf(dieTempC, 6, 2, dieTempStr);

  // Set BLE characteristic values
  objTempCharacteristic->setValue((uint8_t*)objTempStr, strlen(objTempStr));
  objTempCharacteristic->notify();

  dieTempCharacteristic->setValue((uint8_t*)dieTempStr, strlen(dieTempStr));
  dieTempCharacteristic->notify();

  Serial.print("Sent Object Temp: ");
  Serial.println(objTempStr);
  Serial.print("Sent Die Temp: ");
  Serial.println(dieTempStr);

  delay(2000);
}
