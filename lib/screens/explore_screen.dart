import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksplorasi Lokal'),
      ),
      body: const Center(
        child: Text(
          'Halaman Eksplorasi (POI, Peta, LBS akan di sini)',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}