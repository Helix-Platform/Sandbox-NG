## NodeMCU to Helix 
#### About

The code below automatically creates the sensor in the Helix Sandbox and sends the temperature and humidity from DHT-11 to Helix using the restful message with the POST method. Moreover, this code uses the force update to guarantee the storage persistence on the database. 
You can use the Arduino IDE to create the code for your NodeMCU.

#### Electrical Diagram

![](../images/nodemcu_dht-11.png)

#### Code

```C++
#include <ESP8266WiFi.h> 
#include <ESP8266HTTPClient.h>
#include "DHT.h"
#include <math.h>
#include <Adafruit_Sensor.h>
#define DHTTYPE DHT11   
#define dht_dpin D1
#define LED_BUILTIN 2

//Helix IP Address 
const char* orionAddressPath = "IP_HELIX:1026/v2";

//Device ID (example: urn:ngsi-ld:entity:001) 
const char* deviceID = "ID_DEVICE";

//Wi-Fi Credentials
const char* ssid = "SSID"; 
const char* password = "PASSWORD";

//global variables
int medianTemperature;
float totalTemperature;
int medianHumidity;
float totalHumidity;

  
WiFiClient espClient;
HTTPClient http;
DHT dht(dht_dpin, DHTTYPE);

void setup() {
  //setup
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(9600);
  
  //start sensor DHT11
  dht.begin();
  
  //Wi-Fi access
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.println("Connecting to WiFi..");
  }

  Serial.println("Connected WiFi network!");
  delay(2000);

  Serial.println("Creating " + String(deviceID) + " entitie...");
  delay(2000);
  //creating the device in the Helix Sandbox (plug&play) 
  orionCreateEntitie(deviceID);
  
}
 
void loop(){

//reset variables
  medianTemperature=0;
  totalTemperature=0;
  medianHumidity=0;
  totalHumidity=0;

//looping for calculating average temperature and humidity
  for(int i = 0; i < 5; i ++){
    totalHumidity  += dht.readHumidity();
    totalTemperature += dht.readTemperature(); 
    Serial.println("COUNT[" + String(i+1) + "] - Total Humidity: " + String(totalHumidity) + " Total Temperature: " + String(totalTemperature));
    delay(5000); //delay 5 seg
    digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(250);                       
    digitalWrite(LED_BUILTIN, LOW);    // turn the LED off by making the voltage LOW
    delay(250); 
  };

//calculation of average values
  medianHumidity = totalHumidity/5;
  medianTemperature = totalTemperature/5;
  
  Serial.println("Median after 5 reads is Humidity: " + String(medianHumidity) + " Temperature: " + String(medianTemperature));
  
  char msgHumidity[10];
  char msgTemperature[10]; 
  sprintf(msgHumidity,"%d",medianHumidity);
  sprintf(msgTemperature,"%d",medianTemperature);

  //update 
  Serial.println("Updating data in orion...");
  orionUpdate(deviceID, msgTemperature, msgHumidity);

  //indicação luminosa do envio
  digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(500);                       
  digitalWrite(LED_BUILTIN, LOW);    // turn the LED off by making the voltage LOW
  delay(500);                          
  Serial.println("Finished updating data in orion...");
}

//plug&play
void orionCreateEntitie(String entitieName) {

    String bodyRequest = "{\"id\": \"" + entitieName + "\", \"type\": \"iot\", \"temperature\": { \"value\": \" 0\", \"type\": \"float"},\"humidity\": { \"value\": \" 0\", \"type\": \"float\"}}";
    httpRequest("/entities", bodyRequest);
}

//update 
void orionUpdate(String entitieID, String temperature, String humidity){

    String bodyRequest = "{\"temperature\": { \"value\": \""+ temperature + "\", \"type\": \"float\"}, \"humidity\": { \"value\": \""+ humidity +"\", \"type\": \"float\"}}";
    String pathRequest = "/entities/" + entitieID + "/attrs?options=forcedUpdate";
    httpRequest(pathRequest, bodyRequest);
}

//request
void httpRequest(String path, String data)
{
  String payload = makeRequest(path, data);

  if (!payload) {
    return;
  }

  Serial.println("##[RESULT]## ==> " + payload);

}

//request
String makeRequest(String path, String bodyRequest)
{
  String fullAddress = "http://" + String(orionAddressPath) + path;
  http.begin(fullAddress);
  Serial.println("Orion URI request: " + fullAddress);

  http.addHeader("Content-Type", "application/json"); 
  http.addHeader("Accept", "application/json"); 
  http.addHeader("fiware-service", "helixiot"); 
  http.addHeader("fiware-servicepath", "/"); 

Serial.println(bodyRequest);
  int httpCode = http.POST(bodyRequest);

  String response =  http.getString();

  Serial.println("HTTP CODE");
  Serial.println(httpCode);
  
  if (httpCode < 0) {
    Serial.println("request error - " + httpCode);
    return "";
  }

  if (httpCode != HTTP_CODE_OK) {
    return "";
  }

  http.end();

  return response;
}
```
Enjoy and explore all Helix features with NodeMCU.
#### © Helix Platform 2020, All rights reserved.
<a href="https://gethelix.org">Helix</a> for a better world! 
