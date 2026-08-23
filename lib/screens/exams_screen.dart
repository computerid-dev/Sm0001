import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../store.dart';
import '../models.dart';

class ExamsScreen extends StatefulWidget {
  final AppStore store;
  const ExamsScreen({super.key, required this.store});
  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  static const types = ['Ulangan harian', 'UTS', 'UAS', 'Ujian sekolah', 'Asesmen', 'Ujian lainnya'];

  Future<void> _form({ExamItem? existing}) async {
    final store = widget.store;
    final name = TextEditingController(text: existing?.name ?? '');
    final material = TextEditingController(text: existing?.material ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    String subjectId = existing?.subjectId ?? (store.subjects.isNotEmpty ? store.subjects.first.id : '');
    String type = existing?.type ?? types.first;
    DateTime date = existing?.date ?? DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          title: Text(existing == null ? 'Tambah Ujian / Ulangan' : 'Edit Ujian / Ulangan'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama ujian')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: store.subjects.any((s) => s.id == subjectId) ? subjectId : null,
                decoration: const InputDecoration(labelText: 'Mata pelajaran'),
                items: store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setSt(() => subjectId = v ?? ''),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Jenis ujian'),
                items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setSt(() => type = v ?? types.first),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Tanggal: ${DateFormat('d MMM yyyy', 'id_ID').format(date)}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                  if (picked != null) setSt(() => date = picked);
                },
              ),
              TextField(controller: material, decoration: const InputDecoration(labelText: 'Materi')),
              const SizedBox(height: 10),
              TextField(controller: notes, decoration: const InputDecoration(labelText: 'Catatan')),
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
      store.exams.add(ExamItem(
        id: generateId(),
        name: name.text.trim(),
        subjectId: subjectId,
        type: type,
        date: date,
        material: material.text.trim(),
        notes: notes.text.trim(),
      ));
    } else {
      existing.name = name.text.trim();
      existing.subjectId = subjectId;
      existing.type = type;
      existing.date = date;
      existing.material = material.text.trim();
      existing.notes = notes.text.trim();
    }
    setState(() {});
    store.save();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final list = store.exams.toList()..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Ujian / Ulangan')),
      body: list.isEmpty
          ? const Center(child: Text('Belum ada jadwal ujian.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final e = list[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.fact_check_outlined),
                    title: Text(e.name),
                    subtitle: Text('${e.type} • ${store.subjectName(e.subjectId)}\n${DateFormat('EEEE, d MMM yyyy', 'id_ID').format(e.date)}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _form(existing: e);
                        if (v == 'delete') {
                          setState(() => store.exams.remove(e));
                          store.save();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Hapus')),
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
