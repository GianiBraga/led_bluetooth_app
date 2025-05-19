import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:led_bluetooth_app/select_device_page.dart';
import 'package:permission_handler/permission_handler.dart';

class CarControlPage extends StatefulWidget {
  const CarControlPage({super.key});

  @override
  State<CarControlPage> createState() => _CarControlPageState();
}

class _CarControlPageState extends State<CarControlPage> {
  BluetoothConnection? _connection;
  BluetoothDevice? _selectedDevice;
  bool isConnecting = false;
  bool isConnected = false;

  // Estados para clique visual
  bool _isForwardPressed = false;
  bool _isBackwardPressed = false;

  void _sendCommand(String command) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList("$command\n".codeUnits));
      _connection!.output.allSent;
      print("Comando enviado: $command");
    } else {
      print("Bluetooth não conectado.");
    }
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<void> _connectToDevice(BuildContext context) async {
    _checkPermissions();
    final BluetoothDevice? device = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectBondedDevicePage()),
    );

    if (device != null) {
      setState(() {
        isConnecting = true;
      });

      try {
        final connection = await BluetoothConnection.toAddress(device.address);
        setState(() {
          _selectedDevice = device;
          _connection = connection;
          isConnected = true;
          isConnecting = false;
        });

        print("Conectado com sucesso a ${device.name}");
      } catch (e) {
        print("Erro ao conectar: $e");
        setState(() {
          isConnecting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Controle do Carrinho',
          style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF1C4C9C), Color(0xFF00C9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    isConnected
                        ? 'Conectado a: ${_selectedDevice?.name ?? 'Desconhecido'}'
                        : 'Bluetooth não conectado',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap:
                        isConnecting ? null : () => _connectToDevice(context),
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
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Joystick à esquerda
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: Joystick(
                                      mode: JoystickMode.horizontal,
                                      listener: (details) {
                                        if (details.x > 0.5) {
                                          _sendCommand("RIGHT");
                                        } else if (details.x < -0.5) {
                                          _sendCommand("LEFT");
                                        } else {
                                          _sendCommand("STOP_LEFT");
                                          _sendCommand("STOP_RIGHT");
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Deslize o controle para os lados",
                                    style: GoogleFonts.rajdhani(
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Botões à direita
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildCircleButton(
                                  icon: Icons.arrow_upward,
                                  color: Colors.greenAccent,
                                  isPressed: _isForwardPressed,
                                  onTapDown: () {
                                    _sendCommand("FORWARD");
                                    setState(() => _isForwardPressed = true);
                                  },
                                  onTapUp: () {
                                    _sendCommand("STOP_FORWARD");
                                    setState(() => _isForwardPressed = false);
                                  },
                                ),
                                const SizedBox(width: 20),
                                _buildCircleButton(
                                  icon: Icons.arrow_downward,
                                  color: Colors.redAccent,
                                  isPressed: _isBackwardPressed,
                                  onTapDown: () {
                                    _sendCommand("BACKWARD");
                                    setState(() => _isBackwardPressed = true);
                                  },
                                  onTapUp: () {
                                    _sendCommand("STOP_BACKWARD");
                                    setState(() => _isBackwardPressed = false);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required bool isPressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
  }) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: isPressed ? 64 : 72,
        height: isPressed ? 64 : 72,
        decoration: BoxDecoration(
          color: color.withOpacity(isPressed ? 0.6 : 0.8),
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
            icon,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}
