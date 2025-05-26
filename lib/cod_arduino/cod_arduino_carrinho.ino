String comando;

void setup() {
  pinMode(2, OUTPUT); // LED principal
  pinMode(3, OUTPUT); // Amarelo
  pinMode(4, OUTPUT); // Azul (não usado no código atual)
  pinMode(5, OUTPUT); // Marrom
  pinMode(6, OUTPUT); // Branco
  pinMode(7, OUTPUT); // Branco
  pinMode(8, OUTPUT); // Branco
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(12, OUTPUT);
  pinMode(13, OUTPUT);
  
  Serial.begin(9600); // Inicializa a comunicação serial com o módulo Bluetooth
}

void loop() {
  if (Serial.available()) {
    comando = Serial.readStringUntil('\n'); // Lê até encontrar quebra de linha
    comando.trim(); // Remove espaços em branco e quebras de linha extras

    if (comando == "1") {
      digitalWrite(2, HIGH); // Liga LED
    } 
    else if (comando == "0") {
      digitalWrite(2, LOW); // Desliga LED
    } 
     if (comando == "2") {
      digitalWrite(8, HIGH); // Liga LED
    } 
    else if (comando == "3") {
      digitalWrite(8 ,LOW); // Desliga LED
    } 

     if (comando == "4") {
      digitalWrite(9, HIGH); // Liga LED
    } 
    else if (comando == "5") {
      digitalWrite(9 ,LOW); // Desliga LED
    } 

     if (comando == "6") {
      digitalWrite(10, HIGH); // Liga LED
    } 
    else if (comando == "7") {
      digitalWrite(10 ,LOW); // Desliga LED
    } 

     if (comando == "8") {
      digitalWrite(11, HIGH); // Liga LED
    } 
    else if (comando == "9") {
      digitalWrite(11 ,LOW); // Desliga LED
    } 
     if (comando == "10") {
      digitalWrite(12, HIGH); // Liga LED
    } 
    else if (comando == "11") {
      digitalWrite(12 ,LOW); // Desliga LED
    } 
     if (comando == "12") {
      digitalWrite(13, HIGH); // Liga LED
    } 
    else if (comando == "13") {
      digitalWrite(13 ,LOW); // Desliga LED
    } 
     if (comando == "14") {
      digitalWrite(2, HIGH);
      digitalWrite(8, HIGH); 
      digitalWrite(9, HIGH);
      digitalWrite(10, HIGH);
      digitalWrite(11, HIGH);
      digitalWrite(12, HIGH);
      digitalWrite(13, HIGH);      // Liga LED
    } 
    else if (comando == "15") {
      digitalWrite(2, LOW);
      digitalWrite(8, LOW); 
      digitalWrite(9, LOW);
      digitalWrite(10, LOW);
      digitalWrite(11, LOW);
      digitalWrite(12, LOW);
      digitalWrite(13, LOW); // Desliga LED
    } 

    else if (comando == "RIGHT") {
      digitalWrite(2, HIGH);  // Liga LED (pode ser substituído por outro pino se quiser)
      digitalWrite(5, LOW);   // Garante que o outro lado esteja desligado
    } 
    else if (comando == "LEFT") {
      digitalWrite(5, HIGH);  // Liga pino marrom
      digitalWrite(2, LOW);   // Garante que o outro lado esteja desligado
    } 
    else if (comando == "FORWARD") {
      digitalWrite(3, HIGH); // Liga motor amarelo
    } 
    else if (comando == "BACKWARD") {
      digitalWrite(6, HIGH); // Liga motor branco
      digitalWrite(7, HIGH); // Liga motor branco
      digitalWrite(3, HIGH); // Liga motor amarelo
    } 
    else if (comando == "STOP") {
      // Desliga todos os motores e LEDs
      digitalWrite(2, LOW);
      digitalWrite(3, LOW);
      digitalWrite(5, LOW);
      digitalWrite(6, LOW);
      digitalWrite(7, LOW);
    }

    // Debug no monitor serial (opcional)
    Serial.print("Comando recebido: ");
    Serial.println(comando);
  }
}
