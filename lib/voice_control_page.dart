import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:led_bluetooth_app/select_device_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceControlPage extends StatefulWidget {
  const VoiceControlPage({Key? key}) : super(key: key);

  @override
  _VoiceControlPageState createState() => _VoiceControlPageState();
}

class _VoiceControlPageState extends State<VoiceControlPage> {
  BluetoothConnection? connection;
  BluetoothDevice? selectedDevice;
  bool isConnected = false;
  bool isListening = false;
  String status = 'Pronto para conectar'; // ✅ status inicial ajustado
  late stt.SpeechToText _speech;
  String _recognizedWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize();
    setState(() {
      status = available ? status : 'Falha ao inicializar reconhecimento de voz';
    });
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.microphone,
    ].request();
  }

  void _connectToDevice() async {
    await _checkPermissions();

    final device = await Navigator.of(context).push<BluetoothDevice>(
      MaterialPageRoute(
        builder: (context) => const SelectBondedDevicePage(),
      ),
    );

    if (device == null) return;

    setState(() {
      status = 'Conectando ao dispositivo...';
    });

    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        isConnected = true;
        selectedDevice = device;
        status = 'Conectado a ${device.name}';
      });

      connection!.input!.listen((data) {
        print('Recebido: ${String.fromCharCodes(data)}');
      }).onDone(() {
        setState(() {
          isConnected = false;
          status = 'Desconectado pelo dispositivo';
        });
      });
    } catch (e) {
      setState(() {
        status = 'Erro ao conectar';
      });
    }
  }

  void sendCommand(String command) {
    if (connection != null && connection!.isConnected) {
      final fullCommand = command.trim() + '\n';
      connection!.output.add(Uint8List.fromList(fullCommand.codeUnits));
      print('Enviado: $fullCommand');
    }
  }

  void startListening() {
    _speech.listen(onResult: (result) {
      setState(() {
        _recognizedWords = result.recognizedWords.toLowerCase();
      });

      final commandMap = {
        'ligar quarto': '1',
        'apagar quarto': '0',
        'ligar sala': '2',
        'apagar sala': '3',
        'ligar banheiro': '4',
        'apagar banheiro': '5',
        'ligar cozinha': '6',
        'apagar cozinha': '7',
        'ligar escritório': '8',
        'apagar escriório': '9',
        'ligar lavanderia': '10',
        'apagar lavanderia': '11',
        'ligar externa': '12',
        'apagar externa': '13',
        'ligar luzes': '14',
        'apagar luzes': '15',
      };

      if (commandMap.containsKey(_recognizedWords)) {
        sendCommand(commandMap[_recognizedWords]!);
      } else if (_recognizedWords.contains('direita')) {
        sendCommand('RIGHT');
      } else if (_recognizedWords.contains('esquerda')) {
        sendCommand('LEFT');
      } else if (_recognizedWords.contains('frente')) {
        sendCommand('FORWARD');
      } else if (_recognizedWords.contains('trás') || _recognizedWords.contains('ré')) {
        sendCommand('BACKWARD');
      } else if (_recognizedWords.contains('parar')) {
        sendCommand('STOP');
      }
    });

    setState(() {
      isListening = true;
    });
  }

  void stopListening() {
    _speech.stop();
    setState(() {
      isListening = false;
    });
  }

  @override
  void dispose() {
    connection?.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Controle por Voz',
          style: GoogleFonts.rajdhani(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Status: $status',
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _connectToDevice,
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
                      child: Icon(Icons.bluetooth, color: Colors.white, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (isConnected)
                  Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: isListening
                              ? [
                                  BoxShadow(
                                    color: Colors.deepPurpleAccent.withOpacity(0.6),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ]
                              : [],
                        ),
                        child: GestureDetector(
                          onLongPressStart: (_) => startListening(),
                          onLongPressEnd: (_) => stopListening(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isListening ? Colors.deepPurpleAccent : Colors.grey[800],
                              border: Border.all(
                                color: isListening ? Colors.deepPurpleAccent : Colors.white38,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              isListening ? Icons.mic : Icons.mic_none,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isListening ? 'Ouvindo...' : 'Segure para Falar',
                        style: GoogleFonts.rajdhani(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Comando reconhecido:\n$_recognizedWords',
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
