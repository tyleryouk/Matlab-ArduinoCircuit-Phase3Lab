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


//initializing dht sensor to recognize temperature and humidity
#include <DHT.h>
#define DHTTYPE DHT11
DHT dht(2, DHTTYPE);


//function to measure temperature & humidity
static bool measure_environment(float &t,float &h ) {

  static uint32_t measurement_timestamp = millis( );
  static float humidity = 0;
  h = dht.readHumidity(); 
  static float temperature = 0; 
  t = dht.readTemperature(); //produces celsius now
  if(h != h){
    h = humidity; //humidity will be old humidity value if new h is naan
  }
  else{
    humidity = h; //if h is okay, save it to humidity
  }
  if(t != t){
    t = temperature; //temperature will be old temperature value if new h is naan
  }
  else{
    temperature = t; //if t is okay, save it to temperature
  }

  
  //float f = dht.readTemperature(true);
  // Measure once every .5 seconds. 
  if( millis( ) - measurement_timestamp > 500 ) {  
      measurement_timestamp = millis( );
      return(true);
  }
  return(false);
}

void setup() {
  //sweep code
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  dht.begin();
  delay(500);
  //photoresistor code
  pinMode(PhotoPin,INPUT); // initialize photoresistor to input
  pinMode(LedPin,OUTPUT); // initialize LED to output
  Serial.begin(9600); // initialize serial
  Serial.println("please issue a command: 's #' to move servo, 'd' to display all data, or 'e' to end");
  
}
void loop() {
     //sweep code
    //pos = random(0,2);  //random position between 0 and 180
    //myservo.write(pos); // tell servo to go to position in variable 'pos'

    //delay(10); // delay 10ms for each time interval, also delays 10ms for the servo to reach the position (180)
    float temperature;
    float humidity;

    //if something is typed in the top bar of the serial monitor
    while ( Serial.available() == 0){}
    if (Serial.available() > 0){ 
      char b = Serial.read(); 
      String s; //a text buffer to hold the command
      if(b == 's'){ //move servo by this much cmd="s 80"
        while( Serial.available() == 0){ }
        while(true){ 
          char ch = Serial.read();
          if( ch>='0' && ch<='9' ) s += ch; //input data into buffer //data is the number of degrees by which you want to move servo
          else break;
          while( Serial.available() == 0){ }
        }
         //null termination for string (c-string) don't keep reading input
        int x=s.toInt(); // converts buffer to integer
         Serial.println(x);
         if(x<0)x=0;
         if(x>180)x=180;
         myservo.write(x); 
      }else if(b=='d'){//collect data
        while(true){
          if(Serial.available() > 0) if(Serial.read() == 'e') break;
          if(measure_environment(temperature,humidity) == true){
             //photoresistor code
            t = millis(); //so t returns number of milliseconds 
            PhotoValue = analogRead(PhotoPin);   // read value of photoresistor  
            mappedVal = map(PhotoValue,0,1023,0,100); // convert A0 voltage from (0 to 1023) to (0 to 100)  
            //analogWrite(LedPin,mappedVal); //turn on LED pin  to value above
            //Serial.print(" The command value to the LED = "); 
            Serial.print(t/1000.0); // time is first column
            Serial.print(" "); //space in between
            Serial.print(mappedVal); //actual value for photoresistor 
                              // units = normalized light intensity from [0 to 100]
                              // light intensity is second column
            Serial.print(" ");
            Serial.print(temperature); //temperature is third column (Celsius)
            Serial.print(" ");
            Serial.println(humidity); //humidity is fourth column 
            }
          
      }
    while(Serial.available() > 0){ Serial.read();}
    Serial.println("please issue a command: 's# ' to move servo, 'd' to display all data, or 'e' to end");
   }

 
  // for humidity and temperature it will occasionally produce garbage numbers.  Rest of the time it is okay.  
  } 
}
