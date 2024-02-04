/*
const int flameSensorPin = 34;  // Pin D34 on the ESP32 board for flame sensor
const int buzzerPin = 4;       // Pin D4 on the ESP32 board for the buzzer

void setup() {
  
  pinMode(flameSensorPin, INPUT);
  pinMode(buzzerPin, OUTPUT);
  analogSetAttenuation(ADC_11db); // Full range: 3.3V
}

void loop() {
  delay(300);
  Serial.println("I am all good");
  int flameValue = analogRead(flameSensorPin);
  Serial.println(flameValue); // Print flame sensor value to serial monitor
  delay(100);

  if (flameValue < 4095) { // If the sensor detects a flame
     digitalWrite(buzzerPin, LOW); 
  } else {
    // digitalWrite(buzzerPin, HIGH);
    digitalWrite(buzzerPin, HIGH); 
  }
}
*/
#if defined(ESP32)
#include <WiFi.h>
#include <FirebaseESP32.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#endif

//Provide the token generation process info.
#include <addons/TokenHelper.h>

//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

/* 1. Define the WiFi credentials */
#define WIFI_SSID "ICA2"
#define WIFI_PASSWORD "ftmkica2"

//For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino

// Insert Firebase project API Key
#define API_KEY "AIzaSyB03AoYlEosstvba5yTevV7wenJcghXJZY"

// Insert RTDB URL
#define DATABASE_URL "https://esp-32-d9503-default-rtdb.firebaseio.com/"


//Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;
bool signupOK = false;

const int flameSensorPin = 34;  // Pin D34 on the ESP32 board for flame sensor
const int buzzerPin = 4;       // Pin D4 on the ESP32 board for the buzzer

const int output = 23;
const int ledChannel = 0;

const int relay_pin = 32; 

void setup()
{

  Serial.begin(74880);

  delay(2000);
  // Solenoid lock
  digitalWrite(relay_pin, LOW);
  pinMode(relay_pin, OUTPUT);

  // fire sensor
  pinMode(flameSensorPin, INPUT);
  pinMode(buzzerPin, OUTPUT);
  analogSetAttenuation(ADC_11db); // Full range: 3.3V

  delay(200);

  // led light
  ledcSetup(ledChannel, 5000, 8);
  ledcAttachPin(output, ledChannel);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  Serial.print("Free Heap: ");
  Serial.println(ESP.getFreeHeap());
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  config.database_url = DATABASE_URL;
  Firebase.begin(&config, &auth);



  if (Firebase.signUp(&config, &auth, "", ""))
  {
    Serial.println("ok");
    signupOK = true;
  }
  else
  {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  Firebase.setDoubleDigits(5);



}

void loop()
{
  
  int flameValue = analogRead(flameSensorPin);

  Serial.println(flameValue); // Print flame sensor value to serial monitor
  // delay(100);
  bool isFireDetected;
  if (flameValue < 4095) { // If the sensor detects a flame
     // digitalWrite(buzzerPin, LOW); 
     isFireDetected = false;
  } else {
    
    Firebase.setBool(fbdo, "/ESP 32 WROOM/BuzzerRing", true); 
    isFireDetected = true;
  } 
  
  if (Firebase.ready()) 
  {
    Firebase.setBool(fbdo, "/ESP 32 WROOM/FireDetected", isFireDetected);

    Serial.printf("Light ON Get string... %s\n", Firebase.getString(fbdo, F("/ESP 32 WROOM/Light/LightOn")) ? fbdo.to<const char *>() : fbdo.errorReason().c_str());
 

    if (strcmp(fbdo.to<const char *>(), "true") == 0) {
       String sliderValue;
      if (Firebase.getString(fbdo, F("/ESP 32 WROOM/Light/Brightness"))) {
        sliderValue = fbdo.to<String>();
      } else {
        sliderValue = "0";
        // Handle the error, e.g., print the error reason
        Serial.println(fbdo.errorReason().c_str());
      };
      Serial.println("Slider: "+sliderValue);

      ledcWrite(ledChannel, sliderValue.toInt());
    }
    else // turn off the light
    {
      ledcWrite(ledChannel, 0); 
    }

    Serial.printf("Buzzer Get string... %s\n", Firebase.getString(fbdo, F("/ESP 32 WROOM/BuzzerRing")) ? fbdo.to<const char *>() : fbdo.errorReason().c_str());


    if (strcmp(fbdo.to<const char *>(), "true") == 0) {
      digitalWrite(buzzerPin, HIGH);
    } else {
      digitalWrite(buzzerPin, LOW);
    }


    Serial.printf("Door Get string... %s\n", Firebase.getString(fbdo, F("/ESP 32 WROOM/DoorLock")) ? fbdo.to<const char *>() : fbdo.errorReason().c_str());


    if (strcmp(fbdo.to<const char *>(), "true") == 0) {
      digitalWrite(relay_pin, HIGH); //lock door
    } else {
      digitalWrite(relay_pin, LOW); //open door
    }


   

    
 


  }
  
}