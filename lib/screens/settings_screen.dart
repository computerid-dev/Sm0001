import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../store.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppStore store;
  const SettingsScreen({super.key, required this.store});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController userName;
  late TextEditingController apiKey;
  bool obscureKey = true;

  @override
  void initState() {
    super.initState();
    userName = TextEditingController(text: widget.store.settings.userName);
    apiKey = TextEditingController(text: widget.store.settings.geminiApiKey);
  }

  Future<void> _exportBackup() async {
    final store = widget.store;
    final json = store.exportJson();
    try {
      final dir = await getTemporaryDirectory();
      final fileName = 'study-mate-backup-${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(json);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Backup data Study Mate'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat backup: $e')));
      }
    }
  }

  Future<void> _importBackup() async {
    final store = widget.store;
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Import Data'),
          content: const Text('Data lama akan ditimpa oleh data dari file backup ini. Lanjutkan?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Import')),
          ],
        ),
      );
      if (confirm != true) return;

      store.importFromJsonString(content);
      setState(() {
        userName.text = store.settings.userName;
        apiKey.text = store.settings.geminiApiKey;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil diimpor.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File JSON tidak valid: $e')));
      }
    }
  }

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text('Semua data Study Mate akan dihapus permanen. Yakin ingin melanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
        ],
      ),
    );
    if (confirm == true) {
      await widget.store.resetAll();
      setState(() {
        userName.text = '';
        apiKey.text = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil direset.')));
      }
    }
  }

  void _saveProfile() {
    widget.store.settings.userName = userName.text.trim();
    widget.store.save();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama pengguna disimpan.')));
  }

  void _saveApiKey() {
    widget.store.settings.geminiApiKey = apiKey.text.trim();
    widget.store.save();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key Gemini disimpan.')));
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Profil'),
          TextField(controller: userName, decoration: const InputDecoration(labelText: 'Nama pengguna')),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _saveProfile, child: const Text('Simpan Nama'))),

          _section('Tema Aplikasi'),
          RadioListTile<String>(
            title: const Text('Ikuti sistem'),
            value: 'system',
            groupValue: store.settings.themeMode,
            onChanged: (v) {
              setState(() => store.settings.themeMode = v!);
              store.save();
            },
          ),
          RadioListTile<String>(
            title: const Text('Terang'),
            value: 'light',
            groupValue: store.settings.themeMode,
            onChanged: (v) {
              setState(() => store.settings.themeMode = v!);
              store.save();
            },
          ),
          RadioListTile<String>(
            title: const Text('Gelap'),
            value: 'dark',
            groupValue: store.settings.themeMode,
            onChanged: (v) {
              setState(() => store.settings.themeMode = v!);
              store.save();
            },
          ),

          _section('AI Asisten (Gemini)'),
          const Text('Ambil API key gratis dari Google AI Studio, lalu tempel di sini. Kunci disimpan hanya di perangkatmu.',
              style: TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: apiKey,
            obscureText: obscureKey,
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              suffixIcon: IconButton(
                icon: Icon(obscureKey ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => obscureKey = !obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _saveApiKey, child: const Text('Simpan API Key'))),

          _section('Data'),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Backup Data (JSON)'),
            subtitle: const Text('Simpan / bagikan seluruh data Study Mate'),
            onTap: _exportBackup,
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Import Data (JSON)'),
            subtitle: const Text('Pulihkan data dari file backup'),
            onTap: _importBackup,
          ),
          ListTile(
            leading: const Icon(Icons.restore_page_outlined, color: Colors.red),
            title: const Text('Reset Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Hapus semua data secara permanen'),
            onTap: _resetData,
          ),

          _section('Lainnya'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Informasi Versi & Developer'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      );
}
