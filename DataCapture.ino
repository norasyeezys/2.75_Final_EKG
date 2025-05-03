/*
Arduino Code. To be flashed on Arduino Microcontroller.
Used to gather data and put them in a CSV friendly format.
*/

void setup() {
  Serial.begin(115200);
}

void loop() {
  Serial.println(String(millis()) + "," + String(analogRead(A0))+",\n"); //take a reading on pin A0 and pass it to your computer
  delay(10); // Adjust delay based on processor's capabilities (to prevent overheating). I used a delay of 10 ms for simplicity.
}
