
/**
 * Created by K. Suwatchai (Mobizt)
 *
 * Email: k_suwatchai@hotmail.com
 *
 * Github: https://github.com/mobizt/Firebase-ESP32
 *
 * Copyright (c) 2023 mobizt
 *
 */

#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>

// Provide the token generation process info.
#include <addons/TokenHelper.h>

// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

/* 1. Define the WiFi credentials */
#define WIFI_SSID "chaiengong_EXT"
#define WIFI_PASSWORD "88888888"

// For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino

/* 2. Define the API Key */
#define API_KEY "AIzaSyB03AoYlEosstvba5yTevV7wenJcghXJZY"

/* 3. Define the RTDB URL */
#define DATABASE_URL "https://esp-32-d9503-default-rtdb.firebaseio.com/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "USER_EMAIL"
#define USER_PASSWORD "USER_PASSWORD"

// Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;

unsigned long count = 0;

const int flameSensorPin = 34;  // Pin D34 on the ESP32 board for flame sensor
const int buzzerPin = 4;       // Pin D4 on the ESP32 board for the buzzer
bool signupOK = false;
void setup()
{

  Serial.begin(115200);

  pinMode(flameSensorPin, INPUT);
  pinMode(buzzerPin, OUTPUT);
  analogSetAttenuation(ADC_11db); // Full range: 3.3V

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
     Serial.println("Connecting to Wi-Fi...");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

    /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("ok");
    signupOK = true;
  } else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  // Comment or pass false value when WiFi reconnection will control by your code or third party library e.g. WiFiManager
  Firebase.reconnectNetwork(true);

  Firebase.begin(&config, &auth);

  Firebase.setDoubleDigits(5);


}

void loop() {
  int flameValue = analogRead(flameSensorPin);
  Serial.println(flameValue); // Print flame sensor value to serial monitor
  delay(100);

  bool isFireDetected = (flameValue < 4095);

  digitalWrite(buzzerPin, isFireDetected ? LOW : HIGH);

  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 1000 || sendDataPrevMillis == 0)) {
    // Since we want the data to be updated every second
    sendDataPrevMillis = millis();

    // Define the path where you want to store the data
    String path = "/fireDetection";

    // Upload boolean value to Firebase
    if (Firebase.setBool(fbdo, path.c_str(), isFireDetected)) {
      Serial.println("Data uploaded to Firebase! Fire Detected: " + String(isFireDetected));
    } else {
      Serial.println("Failed to upload data to Firebase");
      Serial.println("Reason: " + fbdo.errorReason());
    }
  }
}