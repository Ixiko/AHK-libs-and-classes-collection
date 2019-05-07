// Controlling a servo position using a slider in autohotkey
// by ahklerner / kruzan
// based on:
// Controlling a servo position using a potentiometer (variable resistor) 
// by Michal Rinott <http://people.interaction-ivrea.it/m.rinott> 

#include <Servo.h> 
 
Servo myservo;  // create servo object to control a servo 
 
int pos;    // variable to read the value from the analog pin 
 
void setup() 
{ 
  delay(1000);          // wait a bit before starting
  Serial.begin(115200);   // set up Serial library at 9600 bps
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
} 
 
void loop() 
{ 
  if (Serial.available() > 0) {
	pos = Serial.read();
	myservo.write(pos);                  // sets the servo position according to the scaled value 
	Serial.println(pos);
	delay(15);                           // waits for the servo to get there 
  }
} 