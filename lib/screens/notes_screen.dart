import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../store.dart';
import '../models.dart';

class NotesScreen extends StatefulWidget {
  final AppStore store;
  const NotesScreen({super.key, required this.store});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  Future<void> _form({MaterialNote? existing}) async {
    final store = widget.store;
    final title = TextEditingController(text: existing?.title ?? '');
    final chapter = TextEditingController(text: existing?.chapter ?? '');
    final pages = TextEditingController(text: existing?.pages ?? '');
    final content = TextEditingController(text: existing?.content ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    String subjectId = existing?.subjectId ?? (store.subjects.isNotEmpty ? store.subjects.first.id : '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          title: Text(existing == null ? 'Tambah Catatan Materi' : 'Edit Catatan Materi'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Judul materi')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: store.subjects.any((s) => s.id == subjectId) ? subjectId : null,
                decoration: const InputDecoration(labelText: 'Mata pelajaran'),
                items: store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setSt(() => subjectId = v ?? ''),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(controller: chapter, decoration: const InputDecoration(labelText: 'Bab'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: pages, decoration: const InputDecoration(labelText: 'Halaman'))),
              ]),
              const SizedBox(height: 10),
              TextField(controller: content, maxLines: 4, decoration: const InputDecoration(labelText: 'Isi materi / rangkuman')),
              const SizedBox(height: 10),
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
      store.notes.add(MaterialNote(
        id: generateId(),
        title: title.text.trim(),
        subjectId: subjectId,
        chapter: chapter.text.trim(),
        pages: pages.text.trim(),
        content: content.text.trim(),
        notes: notes.text.trim(),
        createdAt: DateTime.now(),
      ));
    } else {
      existing.title = title.text.trim();
      existing.subjectId = subjectId;
      existing.chapter = chapter.text.trim();
      existing.pages = pages.text.trim();
      existing.content = content.text.trim();
      existing.notes = notes.text.trim();
    }
    setState(() {});
    store.save();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final list = store.notes.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Materi')),
      body: list.isEmpty
          ? const Center(child: Text('Belum ada catatan materi.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final n = list[i];
                return Card(
                  child: ExpansionTile(
                    title: Text(n.title),
                    subtitle: Text('${store.subjectName(n.subjectId)} • Bab ${n.chapter} • Hal ${n.pages}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.content.isEmpty ? 'Belum ada isi materi.' : n.content),
                            if (n.notes.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('Catatan: ${n.notes}', style: const TextStyle(fontStyle: FontStyle.italic)),
                            ],
                            const SizedBox(height: 6),
                            Text(DateFormat('d MMM yyyy', 'id_ID').format(n.createdAt), style: const TextStyle(color: Colors.black45, fontSize: 12)),
                            const SizedBox(height: 8),
                            Row(children: [
                              TextButton.icon(onPressed: () => _form(existing: n), icon: const Icon(Icons.edit_outlined, size: 18), label: const Text('Edit')),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => store.notes.remove(n));
                                  store.save();
                                },
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: const Text('Hapus'),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _form(), child: const Icon(Icons.add)),
    );
  }
}
