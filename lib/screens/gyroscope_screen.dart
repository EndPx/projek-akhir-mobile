import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class GyroscopeScreen extends StatefulWidget {
  const GyroscopeScreen({super.key});

  @override
  State<GyroscopeScreen> createState() => _GyroscopeScreenState();
}

class _GyroscopeScreenState extends State<GyroscopeScreen> {
  double _x = 0, _y = 0, _z = 0;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  @override
  void initState() {
    super.initState();
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (!mounted) return;
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
    });
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Gyroscope'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.screen_rotation, size: 48, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text('X: ${_x.toStringAsFixed(4)}', style: const TextStyle(fontSize: 20)),
                Text('Y: ${_y.toStringAsFixed(4)}', style: const TextStyle(fontSize: 20)),
                Text('Z: ${_z.toStringAsFixed(4)}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                const Text('Putar/miringkan perangkat Anda untuk melihat perubahan nilai.', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}