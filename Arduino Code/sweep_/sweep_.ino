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
 p
//photoresistor global variables
int PhotoPin = 0; //Define photoresistor to AnalogPin0
int LedPin = 3; //Define LED to DigitalPin3
int PhotoValue;
int mappedVal; 
int t;

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
  pos = random(0,180);  //random position between 0 and 180
  myservo.write(pos);              // tell servo to go to position in variable 'pos'
                           // waits 10ms for the servo to reach the position

  //photoresistor code
  t = millis(); //so t returns number of milliseconds
  PhotoValue = analogRead(PhotoPin);   // read value of photoresistor  
  mappedVal = map(PhotoValue,0,100,0,255); // convert A0 voltage from 0 to 225  //reads - t
  analogWrite(LedPin,mappedVal); //turn on LED pin  to value above
  //Serial.print(" The command value to the LED = "); 
  Serial.print(t/1000); //first column printing t
  Serial.print(" "); //space in between
  Serial.println(mappedVal); //actual value for photoresistor
  delay(10);
  
  
}
