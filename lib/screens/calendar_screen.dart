import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../store.dart';
import '../models.dart';

class CalendarScreen extends StatefulWidget {
  final AppStore store;
  const CalendarScreen({super.key, required this.store});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const categories = ['Ujian', 'Ulangan', 'Libur sekolah', 'Acara sekolah', 'Kegiatan sekolah', 'Deadline tugas', 'Lainnya'];

  Future<void> _form({CalendarEvent? existing}) async {
    final store = widget.store;
    final name = TextEditingController(text: existing?.name ?? '');
    final desc = TextEditingController(text: existing?.description ?? '');
    String category = existing?.category ?? categories.first;
    DateTime date = existing?.date ?? DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          title: Text(existing == null ? 'Tambah Acara' : 'Edit Acara'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama acara')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setSt(() => category = v ?? categories.first),
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
              TextField(controller: desc, maxLines: 2, decoration: const InputDecoration(labelText: 'Deskripsi')),
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
      store.calendarEvents.add(CalendarEvent(id: generateId(), name: name.text.trim(), date: date, description: desc.text.trim(), category: category));
    } else {
      existing.name = name.text.trim();
      existing.date = date;
      existing.description = desc.text.trim();
      existing.category = category;
    }
    setState(() {});
    store.save();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final list = store.calendarEvents.toList()..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Akademik')),
      body: list.isEmpty
          ? const Center(child: Text('Belum ada acara di kalender.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final e = list[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: Text(e.name),
                    subtitle: Text('${e.category} • ${DateFormat('EEEE, d MMM yyyy', 'id_ID').format(e.date)}'
                        '${e.description.isNotEmpty ? '\n${e.description}' : ''}'),
                    isThreeLine: e.description.isNotEmpty,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _form(existing: e);
                        if (v == 'delete') {
                          setState(() => store.calendarEvents.remove(e));
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
