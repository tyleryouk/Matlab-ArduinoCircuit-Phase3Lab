

int PhotoPin = 0; //Define photoresistor to AnalogPin0
int LedPin = 3; //Define LED to DigitalPin3
int PhotoValue;
int mappedVal; 
int t;

void setup(){
  pinMode(PhotoPin,INPUT); // initialize photoresistor to input
  pinMode(LedPin,OUTPUT); // initialize LED to output
  Serial.begin(9600); // initialize serial
  
}


void loop(){
  t = millis(); //so t returns number of milliseconds
  PhotoValue = analogRead(PhotoPin);   // read value of photoresistor  
  mappedVal = map(PhotoValue,0,100,0,255); // convert A0 voltage from 0 to 225  //reads - t
  analogWrite(LedPin,mappedVal); //turn on LED pin  to value above
  //Serial.print(" The command value to the LED = "); 
  Serial.print(t/1000); //first column printing t
  Serial.print(" "); //space in between
  Serial.println(mappedVal); //actual value for photoresistor
  delay(200);
  
}
