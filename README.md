# 💡 Controle de LED via Bluetooth com Flutter e Arduino

Este projeto demonstra como um aplicativo Flutter pode se comunicar com um Arduino via Bluetooth para **ligar e desligar um LED**. Ideal para fins didáticos e projetos de introdução à comunicação sem fio entre mobile e hardware.

## 🛠 Tecnologias Utilizadas

- Flutter (Dart)
- Pacote `flutter_bluetooth_serial`
- Arduino Uno com módulo Bluetooth HC-05
- IDE Arduino
- Android (mínimo API 31 recomendado)

## 🔌 Requisitos de Permissões (Android)

Certifique-se de adicionar as seguintes permissões no arquivo `AndroidManifest.xml`:


<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

## ⚙️ Funcionalidades
- Listagem de dispositivos Bluetooth já pareados
- Conexão com dispositivo escolhido
- Envio de dados (1 = liga LED, 0 = desliga LED)
- Atualização de status da conexão
- Interface simples e didática para alunos

## 📱 Estrutura do App Flutter
- [`lib/main.dart`](lib/main.dart): Tela principal do app.
- lib/home.dart: Tela inicial, conexão com Bluetooth e controle do LED.
- lib/select_device_page.dart: Tela de seleção de dispositivos Bluetooth pareados.

## 🔌 Código Arduino
- lib/cod_arduino/cod_arduino.ino: Código responsável por receber comandos via porta serial e ligar/desligar o LED.

## 📸 Capturas de Tela


