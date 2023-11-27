#include <WiFi.h>
#include <HardwareSerial.h>
#include <PubSubClient.h>
#include "wifi_config.h" // should export 'password' and 'ssid' 

// WiFi client
WiFiClient netClient;

// MQTT communication
PubSubClient mqttClient(netClient);
const char* mqtt_server = "broker.hivemq.com";
int mqtt_port = 1883;
String stateTopic = "estado";

// Communication with FPGA
HardwareSerial SerialFPGA(2); // Use UART 2 (esp32 gpio 16, 17)
char bytesFromFPGA[] = "***\0";
int byteCount = 0;

void setup_wifi() {
  delay(10);

  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void mqtt_reconnect() {
  // Loop until we're reconnected
  while (!mqttClient.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random Client ID
    String clientId = "ESP32Client-";
    clientId += String(random(0xffff), HEX);
    // Attempt to connect
    if (mqttClient.connect(clientId.c_str())) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(mqttClient.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void setup() {
  // Setup serial ports
  Serial.begin(115200);

  SerialFPGA.begin(115200, SERIAL_7O1, 16, 17);
  // Setup WiFi & Broker  
  setup_wifi();
  mqttClient.setServer(mqtt_server, mqtt_port);
}



void loop() {
  if (!mqttClient.connected())
    mqtt_reconnect();
  mqttClient.loop();

  SerialFPGA.print("ABCD");
  if (SerialFPGA.available()) {
    byteCount = SerialFPGA.readBytesUntil('\n', bytesFromFPGA, 4); // qual caracter?
    if (byteCount == 4) {
        mqttClient.publish((stateTopic).c_str(), bytesFromFPGA);     
    }
    Serial.printf("got: %c, %c, %c, %c\n", (char)bytesFromFPGA[0], (char)bytesFromFPGA[1], (char)bytesFromFPGA[2], (char)bytesFromFPGA[3]);
  }
  delay(5000);
}
