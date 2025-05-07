String comando;

void setup() {
  pinMode(2, OUTPUT); // LED
  pinMode(3, OUTPUT); // Amarelo 
  pinMode(4, OUTPUT); // Azul
  pinMode(5, OUTPUT); // Marrom
  pinMode(6, OUTPUT); // Branco
  pinMode(7, OUTPUT); // Branco
}

void loop() {
  if (Serial.available()) {
    comando = Serial.readStringUntil('\n'); // lê até encontrar quebra de linha
    comando.trim(); // remove espaços e quebras extras

    if (comando == "1") {
      digitalWrite(2, HIGH);
    } else if (comando == "0") {
      digitalWrite(2, LOW);
    }


    if (comando == "RIGHT") {
      digitalWrite(2, HIGH);
    } else if (comando == "STOP") {
      digitalWrite(2, LOW);
    }

    if (comando == "LEFT") {
      digitalWrite(5, HIGH);
    } else if (comando == "STOP") {
      digitalWrite(5, LOW);
    }

    if (comando == "FORWARD") {
      digitalWrite(3, HIGH);
    } else if (comando == "STOP") {
      digitalWrite(3, LOW);
    }

    if (comando == "BACKWARD") {
      digitalWrite(6, HIGH);
      digitalWrite(7, HIGH);
      digitalWrite(3, HIGH);
    } else if (comando == "STOP") {
      digitalWrite(6, LOW);
      digitalWrite(7, LOW);
      digitalWrite(3, LOW);
    }

  }
}
