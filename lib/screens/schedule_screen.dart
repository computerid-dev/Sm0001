import 'package:flutter/material.dart';
import '../store.dart';
import '../models.dart';
import '../theme.dart';

class ScheduleScreen extends StatefulWidget {
  final AppStore store;
  const ScheduleScreen({super.key, required this.store});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  static const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: days.length, vsync: this, initialIndex: (DateTime.now().weekday - 1).clamp(0, 6));
  }

  Future<void> _form(String day, {ScheduleItem? existing}) async {
    final store = widget.store;
    final start = TextEditingController(text: existing?.timeStart ?? '');
    final end = TextEditingController(text: existing?.timeEnd ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    String subjectId = existing?.subjectId ?? (store.subjects.isNotEmpty ? store.subjects.first.id : '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          title: Text(existing == null ? 'Tambah Jadwal - $day' : 'Edit Jadwal - $day'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: store.subjects.any((s) => s.id == subjectId) ? subjectId : null,
                decoration: const InputDecoration(labelText: 'Mata pelajaran'),
                items: store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setSt(() => subjectId = v ?? ''),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(controller: start, decoration: const InputDecoration(labelText: 'Jam mulai'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: end, decoration: const InputDecoration(labelText: 'Jam selesai'))),
              ]),
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

    if (saved != true || subjectId.isEmpty) return;
    if (existing == null) {
      store.schedule.add(ScheduleItem(
        id: generateId(), day: day, timeStart: start.text.trim(), timeEnd: end.text.trim(), subjectId: subjectId, notes: notes.text.trim(),
      ));
    } else {
      existing.timeStart = start.text.trim();
      existing.timeEnd = end.text.trim();
      existing.subjectId = subjectId;
      existing.notes = notes.text.trim();
    }
    setState(() {});
    store.save();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return Column(
      children: [
        TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: SMColors.navy,
          indicatorColor: SMColors.green,
          tabs: days.map((d) => Tab(text: d)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: days.map((day) {
              final items = store.schedule.where((s) => s.day == day).toList()..sort((a, b) => a.timeStart.compareTo(b.timeStart));
              return items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Belum ada jadwal.'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(onPressed: () => _form(day), icon: const Icon(Icons.add), label: const Text('Tambah Jadwal')),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final s = items[i];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.schedule_outlined, color: SMColors.navy),
                            title: Text(store.subjectName(s.subjectId)),
                            subtitle: Text('${s.timeStart} - ${s.timeEnd}${s.notes.isNotEmpty ? ' • ${s.notes}' : ''}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'edit') _form(day, existing: s);
                                if (v == 'delete') {
                                  setState(() => store.schedule.remove(s));
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
                    );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _form(days[_tab.index]),
              icon: const Icon(Icons.add),
              label: Text('Tambah Jadwal ${days[_tab.index]}'),
            ),
          ),
        ),
      ],
    );
  }
}
