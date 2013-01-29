// Rotate a continuous servo counter-clockwise 180 degrees
// Most of this code taken from the sample SWEEP code

#include <Servo.h> 
 
Servo myservo;  // create servo object to control a servo 
                // a maximum of eight servo objects can be created 
 
int pos = 0;    // variable to store the servo position 
 
void setup() 
{ 
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
} 
 
 
void loop() 
{ 
  myservo.write(0);
  delay(850);
  exit(0);
} 
