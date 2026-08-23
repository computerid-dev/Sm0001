import 'package:flutter/material.dart';
import '../store.dart';
import '../models.dart';
import '../theme.dart';

class TargetsScreen extends StatefulWidget {
  final AppStore store;
  const TargetsScreen({super.key, required this.store});
  @override
  State<TargetsScreen> createState() => _TargetsScreenState();
}

class _TargetsScreenState extends State<TargetsScreen> {
  static const statuses = ['Berjalan', 'Selesai', 'Tertunda'];

  Future<void> _form({StudyTarget? existing}) async {
    final store = widget.store;
    final name = TextEditingController(text: existing?.name ?? '');
    final desc = TextEditingController(text: existing?.description ?? '');
    final targetValue = TextEditingController(text: existing?.targetValue ?? '');
    double progress = existing?.progress ?? 0;
    String status = existing?.status ?? statuses.first;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          title: Text(existing == null ? 'Tambah Target Belajar' : 'Edit Target Belajar'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama target')),
              const SizedBox(height: 10),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'Deskripsi')),
              const SizedBox(height: 10),
              TextField(controller: targetValue, decoration: const InputDecoration(labelText: 'Target waktu / jumlah (mis. 30 menit)')),
              const SizedBox(height: 10),
              Text('Progress: ${progress.toStringAsFixed(0)}%'),
              Slider(value: progress, min: 0, max: 100, divisions: 20, activeColor: SMColors.green, onChanged: (v) => setSt(() => progress = v)),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setSt(() => status = v ?? statuses.first),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
          ],
        );
      }),
    );

    if (saved != true || name.text.trim().isEmpty) return;
    if (existing == null) {
      store.targets.add(StudyTarget(
        id: generateId(), name: name.text.trim(), description: desc.text.trim(), targetValue: targetValue.text.trim(), progress: progress, status: status,
      ));
    } else {
      existing.name = name.text.trim();
      existing.description = desc.text.trim();
      existing.targetValue = targetValue.text.trim();
      existing.progress = progress;
      existing.status = status;
    }
    setState(() {});
    store.save();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final list = store.targets;

    return Scaffold(
      appBar: AppBar(title: const Text('Target Belajar')),
      body: list.isEmpty
          ? const Center(child: Text('Belum ada target belajar. Tap + untuk menambah.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final t = list[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _form(existing: t);
                              if (v == 'delete') {
                                setState(() => store.targets.remove(t));
                                store.save();
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Hapus')),
                            ],
                          ),
                        ]),
                        if (t.description.isNotEmpty) Text(t.description, style: const TextStyle(color: Colors.black54)),
                        if (t.targetValue.isNotEmpty) Text('Target: ${t.targetValue}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: t.progress / 100, color: SMColors.green, backgroundColor: Colors.black12),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${t.progress.toStringAsFixed(0)}%'),
                            Chip(label: Text(t.status), visualDensity: VisualDensity.compact),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _form(), child: const Icon(Icons.add)),
    );
  }
}
