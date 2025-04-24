import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'select_device_page.dart'; // Não se esqueça de criar/importar esse arquivo!

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Bluetooth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothConnection? connection;
  BluetoothDevice? selectedDevice;
  bool isConnected = false;
  bool ledOn = false;
  String status = 'Desconectado';

  Future<void> _checkPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void connectToDevice() async {
    await _checkPermissions();

    final device = await Navigator.of(context).push<BluetoothDevice>(
      MaterialPageRoute(
        builder: (context) => SelectBondedDevicePage(),
      ),
    );

    if (device == null) return;

    setState(() {
      selectedDevice = device;
      status = 'Conectando ao dispositivo...';
    });

    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        isConnected = true;
        status = 'Conectado a ${device.name}';
      });

      connection!.input!.listen((data) {
        print('Recebido: ${ascii.decode(data)}');
      }).onDone(() {
        setState(() {
          isConnected = false;
          status = 'Desconectado pelo dispositivo';
        });
      });
    } catch (e) {
      print('Erro: $e');
      setState(() {
        status = 'Erro ao conectar';
      });
    }
  }

  void toggleLed(bool turnOn) {
    if (connection != null && connection!.isConnected) {
      final data = Uint8List.fromList(turnOn ? '1'.codeUnits : '0'.codeUnits);
      connection!.output.add(data);
      setState(() {
        ledOn = turnOn;
      });
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Controle LED Bluetooth')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Status: $status'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: connectToDevice,
              child: Text(isConnected ? 'Reconectar' : 'Conectar'),
            ),
            SizedBox(height: 20),
            if (isConnected)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('LED'),
                  Switch(
                    value: ledOn,
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
