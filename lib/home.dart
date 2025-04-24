// Importações necessárias
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'select_device_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Objeto da conexão Bluetooth
  BluetoothConnection? connection;

  // Dispositivo selecionado
  BluetoothDevice? selectedDevice;

  // Status de conexão
  bool isConnected = false;

  // Estado atual do LED
  bool ledOn = false;

  // Status exibido na interface
  String status = 'Desconectado';

  // Função para solicitar as permissões de Bluetooth e localização
  Future<void> _checkPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  // Função que conecta ao dispositivo Bluetooth selecionado
  void connectToDevice() async {
    // Solicita permissões
    await _checkPermissions();

    // Abre a tela de seleção de dispositivos pareados
    final device = await Navigator.of(context).push<BluetoothDevice>(
      MaterialPageRoute(
        builder: (context) => const SelectBondedDevicePage(),
      ),
    );

    // Cancela se nenhum for selecionado
    if (device == null) return;

    setState(() {
      selectedDevice = device;
      status = 'Conectando ao dispositivo...';
    });

    try {
      // Tenta conectar ao endereço do dispositivo
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        isConnected = true;
        status = 'Conectado a ${device.name}';
      });

      // Escuta os dados recebidos do Bluetooth (opcional neste caso)
      connection!.input!.listen((data) {
        print('Recebido: ${ascii.decode(data)}');
      }).onDone(() {
        // Quando a conexão for encerrada
        setState(() {
          isConnected = false;
          status = 'Desconectado pelo dispositivo';
        });
      });
    } catch (e) {
      // Erro ao conectar
      print('Erro: $e');
      setState(() {
        status = 'Erro ao conectar';
      });
    }
  }

  // Envia comando para ligar/desligar o LED
  void toggleLed(bool turnOn) {
    if (connection != null && connection!.isConnected) {
      // '1' = ligar LED, '0' = desligar LED
      final data = Uint8List.fromList(turnOn ? '1'.codeUnits : '0'.codeUnits);

      // Envia os dados
      connection!.output.add(data);
      setState(() {
        ledOn = turnOn;
      });
    }
  }

  @override
  void dispose() {
    // Libera a conexão ao sair do app
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controle de LED Bluetooth')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Exibe o status de conexão
            Text('Status: $status'),
            const SizedBox(height: 20),

            // Botão para conectar
            ElevatedButton(
              onPressed: connectToDevice,
              child: Text(isConnected ? 'Reconectar' : 'Conectar'),
            ),
            const SizedBox(height: 20),

            // Exibe o controle do LED somente se estiver conectado
            if (isConnected)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('LED'),
                  Switch(
                    // Estado atual do LED
                    value: ledOn,

                    // Ao mudar o switch, envia comando
                    onChanged: toggleLed,
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
