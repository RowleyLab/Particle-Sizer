#define ledPin 75
#define inPin 57
#define inPin2 59
boolean running = false;
int brightness1;
int brightness2;

void setup()
{
  // initialize the serial communication:
  Serial.begin(115200);
  // initialize the ledPin as an output:
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, HIGH);
  establishContact(); // send a byte to establish contact until receiver responds
  digitalWrite(ledPin, LOW);
  pinMode(inPin, INPUT);
  pinMode(inPin2, INPUT);
  analogReadResolution(14);
}

void loop()
{
  if(Serial.available()>0){
    char val=Serial.read();
    if(val=='1')running=true;
    else running=false;
  }
  digitalWrite(ledPin, running);
  if(running==true){
    brightness1 = 0;
    for (int i = 0; i<400; i++){
      brightness1 = brightness1 + analogRead(inPin);
    }
    brightness1 = brightness1 / 400;
    Serial.write(brightness1>>8); // high byte
    Serial.write(brightness1); // low byte
    brightness2 = 0;
    for (int i = 0; i<400; i++){
      brightness2 = brightness2 + analogRead(inPin2);
    }
    brightness2 = brightness2 / 400;
    Serial.write(brightness2>>8); // high byte
    Serial.write(brightness2); // low byte
  }
}
void establishContact() {
  Serial.println("0,0,0"); // send an initial string
  while (Serial.available() <= 0) {
    delay(300);
  }
}
