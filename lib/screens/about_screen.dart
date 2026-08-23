import 'package:flutter/material.dart';
import '../theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info Aplikasi & Developer')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset('assets/icon/app_icon.png', width: 110, height: 110),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('Study Mate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SMColors.navy))),
          const Center(child: Text('Teman Belajar Digital', style: TextStyle(color: Colors.black54))),
          const SizedBox(height: 24),

          _card('Informasi Aplikasi', [
            _row('Nama', 'Study Mate'),
            _row('Nama pendek', 'SM'),
            _row('Versi', '1.0.0'),
            _row('Package Name', 'com.studymate.sm.cid'),
            _row('Platform', 'Android'),
            _row('Jenis', 'Aplikasi pendidikan / pendamping pelajar'),
            _row('Penyimpanan', 'Lokal / Offline'),
            _row('Format Backup', 'JSON'),
          ]),

          _card('Informasi Developer', [
            _row('Nama', 'Nugroho Yuli Rahmadhani'),
            _row('Developer', 'Nugroho'),
            _row('Studio', 'CID Studio'),
            _row('Peran', 'Developer / Creator'),
          ]),

          _card('AI Asisten', [
            _row('Model', 'gemini-flash-latest'),
            _row('Platform', 'Google AI Studio'),
            _row('Catatan', 'Membutuhkan API key pribadi milik pengguna'),
          ]),

          const SizedBox(height: 16),
          const Center(child: Text('© 2026 Nugroho', style: TextStyle(color: Colors.black45))),
          const SizedBox(height: 4),
          const Center(child: Text('Study Mate — Teman Belajar Digital.', style: TextStyle(color: Colors.black45, fontSize: 12))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> rows) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: SMColors.navy)),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Colors.black54))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
