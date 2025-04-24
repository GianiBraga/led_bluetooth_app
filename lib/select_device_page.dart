import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SelectBondedDevicePage extends StatelessWidget {
  final bool checkAvailability;

  const SelectBondedDevicePage({Key? key, this.checkAvailability = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BluetoothDevice>>(
      future: FlutterBluetoothSerial.instance.getBondedDevices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text('Selecionar Dispositivo')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        List<BluetoothDevice> devices = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(title: Text('Selecionar Dispositivo Pareado')),
          body: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              BluetoothDevice device = devices[index];
              return ListTile(
                title: Text(device.name ?? "Dispositivo sem nome"),
                subtitle: Text(device.address),
                onTap: () {
                  Navigator.of(context).pop(device);
                },
              );
            },
          ),
        );
      },
    );
  }
}
