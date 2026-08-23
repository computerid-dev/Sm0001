import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../store.dart';
import '../models.dart';
import '../theme.dart';

class HomeworkScreen extends StatefulWidget {
  final AppStore store;
  const HomeworkScreen({super.key, required this.store});
  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  String statusFilter = 'Semua';
  String subjectFilter = 'Semua';

  Future<void> _form({Homework? existing}) async {
    final store = widget.store;
    final title = TextEditingController(text: existing?.title ?? '');
    final desc = TextEditingController(text: existing?.description ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    String subjectId = existing?.subjectId ?? (store.subjects.isNotEmpty ? store.subjects.first.id : '');
    DateTime deadline = existing?.deadline ?? DateTime.now().add(const Duration(days: 1));

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          title: Text(existing == null ? 'Tambah Tugas' : 'Edit Tugas'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Nama tugas')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: store.subjects.any((s) => s.id == subjectId) ? subjectId : null,
                decoration: const InputDecoration(labelText: 'Mata pelajaran'),
                items: store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setSt(() => subjectId = v ?? ''),
              ),
              const SizedBox(height: 10),
              TextField(controller: desc, maxLines: 2, decoration: const InputDecoration(labelText: 'Deskripsi tugas')),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Deadline: ${DateFormat('d MMM yyyy', 'id_ID').format(deadline)}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: deadline,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setSt(() => deadline = picked);
                },
              ),
              TextField(controller: notes, decoration: const InputDecoration(labelText: 'Catatan tambahan')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
          ],
        );
      }),
    );

    if (saved != true || title.text.trim().isEmpty) return;
    if (existing == null) {
      store.homework.add(Homework(
        id: generateId(),
        title: title.text.trim(),
        subjectId: subjectId,
        description: desc.text.trim(),
        createdAt: DateTime.now(),
        deadline: deadline,
        notes: notes.text.trim(),
      ));
    } else {
      existing.title = title.text.trim();
      existing.subjectId = subjectId;
      existing.description = desc.text.trim();
      existing.deadline = deadline;
      existing.notes = notes.text.trim();
    }
    setState(() {});
    store.save();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    var list = store.homework.toList();
    if (statusFilter == 'Belum selesai') list = list.where((h) => !h.done).toList();
    if (statusFilter == 'Selesai') list = list.where((h) => h.done).toList();
    if (subjectFilter != 'Semua') list = list.where((h) => h.subjectId == subjectFilter).toList();
    list.sort((a, b) {
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: statusFilter,
                  decoration: const InputDecoration(labelText: 'Status', isDense: true),
                  items: ['Semua', 'Belum selesai', 'Selesai'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => statusFilter = v ?? 'Semua'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: subjectFilter,
                  decoration: const InputDecoration(labelText: 'Mapel', isDense: true),
                  items: [
                    const DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                    ...store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                  ],
                  onChanged: (v) => setState(() => subjectFilter = v ?? 'Semua'),
                ),
              ),
            ]),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Tidak ada tugas.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final h = list[i];
                      final dl = h.deadline != null ? DateFormat('d MMM yyyy', 'id_ID').format(h.deadline!) : '-';
                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: h.done,
                            activeColor: SMColors.green,
                            onChanged: (v) {
                              setState(() => h.done = v ?? false);
                              store.save();
                            },
                          ),
                          title: Text(h.title, style: TextStyle(decoration: h.done ? TextDecoration.lineThrough : null)),
                          subtitle: Text('${store.subjectName(h.subjectId)} • Deadline: $dl'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _form(existing: h);
                              if (v == 'delete') {
                                setState(() => store.homework.remove(h));
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _form(), child: const Icon(Icons.add)),
    );
  }
}
