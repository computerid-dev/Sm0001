import 'package:flutter/material.dart';
import '../store.dart';
import '../models.dart';
import '../theme.dart';

class SubjectsScreen extends StatefulWidget {
  final AppStore store;
  const SubjectsScreen({super.key, required this.store});
  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  Widget build(BuildContext context) {
    final list = widget.store.subjects;
    return Scaffold(
      body: list.isEmpty
          ? const Center(child: Text('Belum ada pelajaran. Tap + untuk menambah.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final s = list[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: SMColors.navy, child: Icon(Icons.menu_book, color: Colors.white, size: 18)),
                    title: Text(s.name),
                    subtitle: Text('${widget.store.categoryName(s.categoryId)} • ${s.teacher.isEmpty ? 'Guru belum diisi' : s.teacher}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(store: widget.store, subject: s)));
                      setState(() {});
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectFormScreen(store: widget.store)));
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SubjectFormScreen extends StatefulWidget {
  final AppStore store;
  final Subject? existing;
  const SubjectFormScreen({super.key, required this.store, this.existing});
  @override
  State<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<SubjectFormScreen> {
  late TextEditingController name, teacher, timeStart, timeEnd, material, chapter, pages, notes;
  String categoryId = '';
  String day = 'Senin';
  static const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    name = TextEditingController(text: e?.name ?? '');
    teacher = TextEditingController(text: e?.teacher ?? '');
    timeStart = TextEditingController(text: e?.timeStart ?? '');
    timeEnd = TextEditingController(text: e?.timeEnd ?? '');
    material = TextEditingController(text: e?.material ?? '');
    chapter = TextEditingController(text: e?.chapter ?? '');
    pages = TextEditingController(text: e?.pages ?? '');
    notes = TextEditingController(text: e?.notes ?? '');
    categoryId = e?.categoryId ?? (widget.store.categories.isNotEmpty ? widget.store.categories.first.id : '');
    day = e?.day.isNotEmpty == true ? e!.day : 'Senin';
  }

  void _save() {
    if (name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama pelajaran wajib diisi')));
      return;
    }
    if (widget.existing == null) {
      widget.store.subjects.add(Subject(
        id: generateId(),
        name: name.text.trim(),
        teacher: teacher.text.trim(),
        categoryId: categoryId,
        day: day,
        timeStart: timeStart.text.trim(),
        timeEnd: timeEnd.text.trim(),
        material: material.text.trim(),
        chapter: chapter.text.trim(),
        pages: pages.text.trim(),
        notes: notes.text.trim(),
      ));
    } else {
      final e = widget.existing!;
      e.name = name.text.trim();
      e.teacher = teacher.text.trim();
      e.categoryId = categoryId;
      e.day = day;
      e.timeStart = timeStart.text.trim();
      e.timeEnd = timeEnd.text.trim();
      e.material = material.text.trim();
      e.chapter = chapter.text.trim();
      e.pages = pages.text.trim();
      e.notes = notes.text.trim();
    }
    widget.store.save();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.store.categories;
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Tambah Pelajaran' : 'Edit Pelajaran')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama pelajaran')),
          const SizedBox(height: 12),
          TextField(controller: teacher, decoration: const InputDecoration(labelText: 'Guru')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: cats.any((c) => c.id == categoryId) ? categoryId : null,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => categoryId = v ?? ''),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: day,
            decoration: const InputDecoration(labelText: 'Hari'),
            items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) => setState(() => day = v ?? 'Senin'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: timeStart, decoration: const InputDecoration(labelText: 'Jam mulai (07.00)'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: timeEnd, decoration: const InputDecoration(labelText: 'Jam selesai (08.30)'))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: material, decoration: const InputDecoration(labelText: 'Materi terakhir')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: chapter, decoration: const InputDecoration(labelText: 'Bab'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: pages, decoration: const InputDecoration(labelText: 'Halaman'))),
          ]),
          const SizedBox(height: 12),
          TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Catatan tambahan')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text('Simpan')),
        ],
      ),
    );
  }
}

class SubjectDetailScreen extends StatefulWidget {
  final AppStore store;
  final Subject subject;
  const SubjectDetailScreen({super.key, required this.store, required this.subject});
  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.black54))),
            Expanded(child: Text(value.isEmpty ? '-' : value)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.subject;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectFormScreen(store: widget.store, existing: s)));
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Pelajaran'),
                  content: Text('Yakin ingin menghapus "${s.name}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
                  ],
                ),
              );
              if (ok == true) {
                widget.store.subjects.remove(s);
                widget.store.save();
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Kategori', widget.store.categoryName(s.categoryId)),
                  _row('Guru', s.teacher),
                  _row('Hari', s.day),
                  _row('Jam', '${s.timeStart} - ${s.timeEnd}'),
                  _row('Materi', s.material),
                  _row('Bab', s.chapter),
                  _row('Halaman', s.pages),
                  _row('Catatan', s.notes),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
