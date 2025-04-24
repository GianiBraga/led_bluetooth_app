import 'package:flutter/material.dart';
import 'package:led_bluetooth_app/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Ligar/Desligar LED',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
