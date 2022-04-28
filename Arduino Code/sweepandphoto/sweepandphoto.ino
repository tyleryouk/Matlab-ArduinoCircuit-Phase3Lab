/* Sweep
 by BARRAGAN <http://barraganstudio.com>
 This example code is in the public domain.

 modified 8 Nov 2013
 by Scott Fitzgerald
 http://www.arduino.cc/en/Tutorial/Sweep
*/

#include <Servo.h>

Servo myservo;  // create servo object to control a servo
// twelve servo objects can be created on most boards

//sweep global variables
int pos = 0;    // variable to store the servo position

//photoresistor global variables
int PhotoPin = 0; //Define photoresistor to AnalogPin0
int LedPin = 3; //Define LED to DigitalPin3
int PhotoValue;
int mappedVal; 
uint32_t t;

void setup() {
  //sweep code
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  
  //photoresistor code
  pinMode(PhotoPin,INPUT); // initialize photoresistor to input
  pinMode(LedPin,OUTPUT); // initialize LED to output
  Serial.begin(9600); // initialize serial
}
void loop() {

  //sweep code
  pos = random(0,2);  //random position between 0 and 180
  myservo.write(pos); // tell servo to go to position in variable 'pos'

  //photoresistor code
  t = millis(); //so t returns number of milliseconds
  PhotoValue = analogRead(PhotoPin);   // read value of photoresistor  
  mappedVal = map(PhotoValue,0,1023,0,100); // convert A0 voltage from (0 to 1023) to (0 to 100)  
  analogWrite(LedPin,mappedVal); //turn on LED pin  to value above
  //Serial.print(" The command value to the LED = "); 
  Serial.print(t/1000.0); //first column printing t (seconds)
  Serial.print(" "); //space in between
  Serial.println(mappedVal); //actual value for photoresistor 
                              // units = normalized light intensity from [0 to 100]
  delay(10); // delay 10ms for each time interval, also delays 10ms for the servo to reach the position (180)
  
}
