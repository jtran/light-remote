// Arduino Funnel code for ADXL335 triple axis accelerometer sensor.

char str[512];

void setup() {
  Serial.begin(19200);
}

void loop() {
  int x = analogRead(7);
  int y = analogRead(6);
  int z = analogRead(5);
  sprintf(str, "%d,%d,%d", x, y, z);
  Serial.println(str);
  delay(100);
}

