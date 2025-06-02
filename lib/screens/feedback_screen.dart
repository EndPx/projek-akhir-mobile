import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Kontribusi Mata Kuliah',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mata kuliah Teknologi dan Pemrograman Mobile memberikan kontribusi signifikan dalam memperluas wawasan dan keterampilan mahasiswa di bidang pengembangan aplikasi mobile. Materi yang disampaikan mencakup berbagai aspek penting seperti pengenalan framework Flutter, pemanfaatan plugin untuk akses fitur perangkat, serta integrasi layanan pihak ketiga seperti penyimpanan lokal dan layanan lokasi.',
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Text(
              'Manfaat Praktikum',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Praktikum yang diberikan turut mendorong mahasiswa untuk memahami praktik nyata dalam membangun aplikasi mobile secara terstruktur dan efisien.',
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Text(
              'Tantangan dan Pembelajaran',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Meskipun terdapat beberapa tantangan selama proses pembelajaran, seperti kendala teknis dan penyesuaian terhadap versi pustaka yang cepat berubah, pengalaman ini justru memperkuat kemampuan pemecahan masalah dan adaptasi terhadap teknologi terkini.',
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}