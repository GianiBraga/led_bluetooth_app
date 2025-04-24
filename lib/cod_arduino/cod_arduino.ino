char comando;

void setup() {
  pinMode(7, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    comando = Serial.read();
    if (comando == '1') {
      digitalWrite(7, HIGH);
    } else if (comando == '0') {
      digitalWrite(7, LOW);
    }
  }
}
