// Importações essenciais do Flutter e do pacote bluetooth
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

// Tela responsável por exibir os dispositivos Bluetooth já pareados
class SelectBondedDevicePage extends StatelessWidget {
  // Propriedade opcional para checar disponibilidade do Bluetooth (não usada diretamente aqui)
  final bool checkAvailability;

  // Construtor da classe, com valor padrão true para checkAvailability
  const SelectBondedDevicePage({super.key, this.checkAvailability = true});

  @override
  Widget build(BuildContext context) {
    // FutureBuilder para buscar os dispositivos pareados de forma assíncrona
    return FutureBuilder<List<BluetoothDevice>>(
      // Solicita à API Bluetooth os dispositivos já pareados
      future: FlutterBluetoothSerial.instance.getBondedDevices(),
      builder: (context, snapshot) {
        // Enquanto os dados ainda estão sendo carregados, exibe um indicador de progresso
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Selecionar Dispositivo'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Se os dados foram carregados, utiliza a lista de dispositivos ou uma lista vazia
        List<BluetoothDevice> devices = snapshot.data ?? [];

        // Cria a interface com a lista dos dispositivos encontrados
        return Scaffold(
          appBar: AppBar(
            title: const Text('Selecionar Dispositivo Pareado'),
          ),
          body: ListView.builder(
            // Número de itens na lista
            itemCount: devices.length,
            itemBuilder: (context, index) {
              // Pega o dispositivo atual
              BluetoothDevice device = devices[index];
              return ListTile(
                // Mostra o nome e endereço do dispositivo
                title: Text(device.name ?? "Dispositivo sem nome"),
                subtitle: Text(device.address),
                // Ao tocar no item, retorna o dispositivo selecionado para a tela anterior
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
