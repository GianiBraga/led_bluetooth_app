import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'select_device_page.dart';

class LedControlPage extends StatefulWidget {
  const LedControlPage({super.key});

  @override
  _LedControlPageState createState() => _LedControlPageState();
}

class _LedControlPageState extends State<LedControlPage> {
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
        builder: (context) => const SelectBondedDevicePage(),
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

  void toggleLed() {
    if (connection != null && connection!.isConnected) {
      final command = ledOn ? '0' : '1';
      connection!.output.add(Uint8List.fromList(command.codeUnits));
      setState(() {
        ledOn = !ledOn;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Controle de LED Bluetooth',
          style: GoogleFonts.rajdhani(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000),
              Color(0xFF1C4C9C),
              Color(0xFF00C9FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Status: $status',
                    style:
                        GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => connectToDevice(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.lightGreen : Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.bluetooth,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  if (isConnected)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: toggleLed,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: ledOn
                                      ? Colors.greenAccent.withOpacity(0.85)
                                      : Colors.redAccent.withOpacity(0.85),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    ledOn
                                        ? Icons.lightbulb
                                        : Icons.lightbulb_outline,
                                    color: Colors.white,
                                    size: 150,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ledOn ? 'LED Ligado' : 'LED Desligado',
                              style: GoogleFonts.rajdhani(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
