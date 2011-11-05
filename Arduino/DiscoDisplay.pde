#include <SPI.h>
#include <Ethernet.h>
#include <Udp.h>
#include <Servo.h>

#define SERVO1 12
#define SERVO2 13

// Define LED pins!!
#define LED0 22
#define LED1 24
#define LED2 28
#define LED3 32
#define LED4 36
#define LED5 38
#define LED6 42
#define LED7 44
#define LED8 48
#define LED9 49

// Change this to match Arduino!!
byte mac[] = {  
   0x90, 0xA2, 0xDA, 0x00, 0x45, 0x55 };

// Adjust if using multiple Arduino's on one network!!
byte ip[] = { 
  192,168,1,102 };

unsigned int localPort = 61557;      // local port to listen on

// the next two variables are set when a packet is received
byte remoteIp[4];        // holds received packet's originating IP
unsigned int remotePort; // holds received packet's originating port

// buffers for receiving and sending data
char packetBuffer[5]; //buffer to hold incoming packet,

int parameters[3];

// define Servos
Servo servo1;
Servo servo2;

// variables for LEDs
long slowInterval = 500;
long fastInterval = 200;
long emergencyInterval = 50;

unsigned long currentMillis;
unsigned long previousMillis = 0;

unsigned long lostConnectionMillis = 0;
unsigned long lostConnectionCurrentMillis;
long lostConnectionInterval = 300;
boolean noConnection;

int ledStates = LOW;
int selector = 0;
int currentLED1 = 0;
int currentLED2 = 0;
int currentLED3 = 0;
int currentLED4 = 0;
int currentLED5 = 0;
int currentLED6 = 0;
int currentLED7 = 0;

void setup() {
  // start the Ethernet and UDP:
  Ethernet.begin(mac,ip);
  Udp.begin(localPort);

  Serial.begin(9600);
  
  // attach the servo outputs
  servo1.attach(SERVO1);
  servo2.attach(SERVO2);
  
  // setup pins for LEDs
  pinMode(LED0, OUTPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  pinMode(LED5, OUTPUT);
  pinMode(LED6, OUTPUT);
  pinMode(LED7, OUTPUT);
  pinMode(LED8, OUTPUT);
  pinMode(LED9, OUTPUT);
  
  // start everything at 0 if you want...
  servo1.write(90);
  servo2.write(90);
  
  Serial.println("Starting up...");
}

void loop() {
  // if there's data available, read a packet
  lostConnectionCurrentMillis = millis();
  int packetSize = Udp.available(); // note that this includes the UDP header
  if(packetSize)
  {
    lostConnectionMillis = lostConnectionCurrentMillis;
    //Serial.print("connected");
    noConnection = false;
    packetSize = packetSize - 8;      // subtract the 8 byte header
    
    //Serial.print("Received packet of size ");
    //Serial.println(packetSize);

    // read the packet into packetBufffer and get the senders IP addr and port number
    Udp.readPacket(packetBuffer,5, remoteIp, remotePort);
    
    //Serial.println("Contents:");
    //Serial.println(packetBuffer);

    checkData((unsigned char*) packetBuffer,packetSize);
  } 
  
// This is only if there needs to be an emergency state!

  if (((lostConnectionCurrentMillis - lostConnectionMillis > lostConnectionInterval) && (!packetSize)) || (noConnection)) {
    noConnection = true;
    //Serial.print("lost connection at:");
    //Serial.print(lostConnectionCurrentMillis);
    //Serial.print(" ");
    //Serial.println(lostConnectionMillis);
    servo1.write(90);
    servo2.write(90);
    selector = 99;
    ledPatterns(selector);
  }
  //delay(10);
}

void checkData(unsigned char *buffer, int length) {
  // every character is ascii (0-255)
  // order is: *Checker-b*,Servo1,Servo2,LED program,*Checker-e*
  if (length == 5) {
    // correct length
    //Serial.println("Received correct length");
    if (buffer[0] == 'b') {
      // we've got the beginning...
      //Serial.print("Received correct start ...");
      if (buffer[9] == 'e') {
        // we'be got the end, great!
        //Serial.println(" and correct end"); 
      } else {
        // we didn't get correct end
        //Serial.println("but NOT correct end");
      }
    } else {
      // didn't recieve correct start
      //Serial.println("Did NOT recieve correct start");
    }
  } else {
    // didn't recieve correct length
    //Serial.println("Did NOT recieve correct length");
  }
  transformData(buffer);
  controls(parameters);
}

void transformData(unsigned char *buffer) {
  // take off checkers and convert ASCII to int
  if ((buffer[0] == 'b') && (buffer[4] == 'e')) {

	// SWAP 30 and 150 IF OPERATING BACKWARDS
    parameters[0] = map(int(buffer[1]),0,255,30,150);
    parameters[1] = map(int(buffer[2]),0,255,30,150);
    parameters[2] = int(buffer[3]);
  }
}

void controls(int *data) {
  // send control to the driving motors
  
  // Basic control:
  // NO scaling...
  servo1.write(data[0]);
  servo2.write(data[1]);
  
  // setup the leds...
  if(data[2] == 1) {
    selector++;
  }
  if(selector > 6) {
    selector = 0;
  }
  //send to display pattern
  ledPatterns(selector);
}

void ledPatterns(int selector) {
  randomSeed(analogRead(0));
    switch (selector) {
        case 0: { //all on
            digitalWrite(LED0, LOW);
            digitalWrite(LED1, LOW);
            digitalWrite(LED2, LOW);
            digitalWrite(LED3, LOW);
            digitalWrite(LED4, LOW);
            digitalWrite(LED5, LOW);
            digitalWrite(LED6, LOW);
            digitalWrite(LED7, LOW);
            digitalWrite(LED8, LOW);
            digitalWrite(LED9, LOW);
            break;
        }
        case 1: { //all flashing on/off slow
            currentMillis = millis();
            if (currentMillis - previousMillis > slowInterval) {
                previousMillis = currentMillis;
                
                if (ledStates == LOW) {
                    ledStates = HIGH;
                } else {
                    ledStates = LOW;
                }
                
                digitalWrite(LED0, ledStates);
                digitalWrite(LED1, ledStates);
                digitalWrite(LED2, ledStates);
                digitalWrite(LED3, ledStates);
                digitalWrite(LED4, ledStates);
                digitalWrite(LED5, ledStates);
                digitalWrite(LED6, ledStates);
                digitalWrite(LED7, ledStates);
                digitalWrite(LED8, ledStates);
                digitalWrite(LED9, ledStates);
            }
            break;
        }
        case 2: {//all flashing on/off fast
            currentMillis = millis();
            if (currentMillis - previousMillis > fastInterval) {
                previousMillis = currentMillis;
                
                if (ledStates == LOW) {
                    ledStates = HIGH;
                } else {
                    ledStates = LOW;
                }
                
                digitalWrite(LED0, ledStates);
                digitalWrite(LED1, ledStates);
                digitalWrite(LED2, ledStates);
                digitalWrite(LED3, ledStates);
                digitalWrite(LED4, ledStates);
                digitalWrite(LED5, ledStates);
                digitalWrite(LED6, ledStates);
                digitalWrite(LED7, ledStates);
                digitalWrite(LED8, ledStates);
                digitalWrite(LED9, ledStates);
            }
            break;
        }
        case 3: { //down the line (1) slow
            currentMillis = millis();
            if (currentMillis - previousMillis > slowInterval) {
                previousMillis = currentMillis;
                
                switch (currentLED1) {
                    case 0:
                        currentLED1++;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 1:
                        currentLED1++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 2:
                        currentLED1++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 3:
                        currentLED1++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 4:
                        currentLED1++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 5:
                        currentLED1++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 6:
                        currentLED1++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 7:
                        currentLED1++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 8:
                        currentLED1++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 9:
                        currentLED1=0;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, LOW);
                        break;
                    default:
                        break;
                }
            }
            break;
        }
        case 4: { //down the line (1) fast
            currentMillis = millis();
            if (currentMillis - previousMillis > fastInterval) {
                previousMillis = currentMillis;
                
                switch (currentLED2) {
                    case 0:
                        currentLED2++;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 1:
                        currentLED2++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 2:
                        currentLED2++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 3:
                        currentLED2++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 4:
                        currentLED2++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 5:
                        currentLED2++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 6:
                        currentLED2++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 7:
                        currentLED2++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 8:
                        currentLED2++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 9:
                        currentLED2=0;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, LOW);
                        break;
                    default:
                        break;
                }
            }
            break;
        }
        case 5: { //all switch, like x-mas
            currentMillis = millis();
            if (currentMillis - previousMillis > slowInterval) {
                previousMillis = currentMillis;
                
                switch (currentLED3) {
                    case 0:
                        currentLED3++;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 1:
                        currentLED3 = 0;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, LOW);
                        break;
                    default:
                        break;
                }
            }
            break;
        }
        case 6: { //bouncing (4)
            currentMillis = millis();
            if (currentMillis - previousMillis > emergencyInterval) {
                previousMillis = currentMillis;
                
                switch (currentLED6) {
                    case 0:
                        currentLED6++;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 1:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 2:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 3:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 4:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 5:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 6:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, LOW);
                        break;
                    case 7:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, LOW);
                        break;
                    case 8:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, LOW);
                        break;
                    case 9:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, LOW);
                        break;
                    case 10:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, LOW);
                        break;
                    case 11:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, LOW);
                        break;
                    case 12:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, LOW);
                        break;
                    case 13:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, LOW);
                        break;
                    case 14:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, LOW);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 15:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, LOW);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 16:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, LOW);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 17:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, LOW);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 18:
                        currentLED6++;
                        digitalWrite(LED0, HIGH);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, LOW);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 19:
                        currentLED6++;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, LOW);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 20:
                        currentLED6++;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 21:
                        currentLED6++;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 22:
                        currentLED6++;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, HIGH);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 23:
                        currentLED6++;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, HIGH);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    case 24:
                        currentLED6 = 0;
                        digitalWrite(LED0, LOW);
                        digitalWrite(LED1, LOW);
                        digitalWrite(LED2, LOW);
                        digitalWrite(LED3, HIGH);
                        digitalWrite(LED4, HIGH);
                        digitalWrite(LED5, HIGH);
                        digitalWrite(LED6, HIGH);
                        digitalWrite(LED7, HIGH);
                        digitalWrite(LED8, HIGH);
                        digitalWrite(LED9, HIGH);
                        break;
                    default:
                        break;
                }
            }
            break;
        }
        case 99: { // emergency...
            currentMillis = millis();
            if (currentMillis - previousMillis > emergencyInterval) {
                previousMillis = currentMillis;
                if (ledStates == HIGH) {
                    ledStates = LOW;
                } else {
                    ledStates = HIGH;
                }
                
                digitalWrite(LED0, ledStates);
                digitalWrite(LED1, ledStates);
                digitalWrite(LED2, ledStates);
                digitalWrite(LED3, ledStates);
                digitalWrite(LED4, ledStates);
                digitalWrite(LED5, ledStates);
                digitalWrite(LED6, ledStates);
                digitalWrite(LED7, ledStates);
                digitalWrite(LED8, ledStates);
                digitalWrite(LED9, ledStates);
            }
            break;
        }
        default:
            break;

    }

}
