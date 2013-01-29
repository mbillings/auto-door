// Rotate a continuous servo 180 degrees
// Most of this code taken from the sample SWEEP code

#include <Servo.h> 
 
Servo myservo;  // create servo object
 
int pos = 0;    // variable to store the servo position 
 
void setup() 
{ 
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
} 
 
 
void loop() 
{
  if (Serial.available())
  {
    char door = Serial.read();
    if      (door == 'u') pos = 0
    else if (door == 'l') pos = 180
  }

  myservo.write(pos);
  delay(850);
  exit(0);
} 
