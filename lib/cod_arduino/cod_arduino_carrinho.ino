String comando;

void setup() {
  pinMode(7, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    comando = Serial.readStringUntil('\n'); // lê até encontrar quebra de linha
    comando.trim(); 

    if (comando == '1') {
      digitalWrite(7, HIGH);
    } else if (comando == '0') {
      digitalWrite(7, LOW);
    }

     if (comando == "RIGHT") {
      digitalWrite(5, HIGH);
    } else if (comando == "STOP") {
      digitalWrite(5, LOW);
    }

    if (comando == "LEFT") {
      digitalWrite(6, HIGH);
    } else if (comando == "STOP") {
      digitalWrite(6, LOW);
    }

      if (comando == "FORWARD") {
      digitalWrite(7, HIGH);
    } else if (comando == "STOP") {
      digitalWrite(7, LOW);
    }

      if (comando == "BACKWARD") {
      digitalWrite(7, HIGH);
      digitalWrite(3, HIGH);
      digitalWrite(4, HIGH);
    } else if (comando == "STOP") {
      digitalWrite(7, LOW);
      digitalWrite(3, LOW);
      digitalWrite(4, LOW);
    }
  }
}