import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../store.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  final AppStore store;
  const DashboardScreen({super.key, required this.store});

  static const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  Widget build(BuildContext context) {
    final today = _days[DateTime.now().weekday - 1];
    final todaySchedule = store.schedule.where((s) => s.day == today).toList()
      ..sort((a, b) => a.timeStart.compareTo(b.timeStart));

    final upcomingHomework = store.homework.where((h) => !h.done).toList()
      ..sort((a, b) {
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });

    final now = DateTime.now();
    final upcomingExams = store.exams.where((e) => e.date.isAfter(now.subtract(const Duration(days: 1)))).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final lastNote = store.notes.isNotEmpty
        ? (store.notes.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt))).first
        : null;

    FinanceEntry? todayFinance;
    for (final f in store.finance) {
      if (f.date.year == now.year && f.date.month == now.month && f.date.day == now.day) {
        todayFinance = f;
      }
    }

    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    final activeTargets = store.targets.where((t) => t.status != 'Selesai').toList();

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Halo, ${store.settings.userName.isEmpty ? 'Pelajar' : store.settings.userName} 👋',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now), style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),

          _sectionCard(
            icon: Icons.schedule,
            title: 'Jadwal Hari Ini ($today)',
            child: todaySchedule.isEmpty
                ? const Text('Tidak ada jadwal pelajaran hari ini.')
                : Column(
                    children: todaySchedule
                        .map((s) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.circle, size: 10, color: SMColors.green),
                              title: Text(store.subjectName(s.subjectId)),
                              subtitle: Text('${s.timeStart} - ${s.timeEnd}'),
                            ))
                        .toList(),
                  ),
          ),

          _sectionCard(
            icon: Icons.task_alt,
            title: 'PR / Tugas Terdekat',
            child: upcomingHomework.isEmpty
                ? const Text('Tidak ada PR yang belum selesai. Mantap! 🎉')
                : Column(
                    children: upcomingHomework.take(3).map((h) {
                      final dl = h.deadline != null ? DateFormat('d MMM yyyy', 'id_ID').format(h.deadline!) : '-';
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.assignment_outlined, color: SMColors.navy),
                        title: Text(h.title),
                        subtitle: Text('Deadline: $dl'),
                      );
                    }).toList(),
                  ),
          ),

          _sectionCard(
            icon: Icons.fact_check,
            title: 'Ujian / Ulangan Terdekat',
            child: upcomingExams.isEmpty
                ? const Text('Belum ada jadwal ujian mendatang.')
                : Column(
                    children: upcomingExams.take(3).map((e) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_note, color: SMColors.navy),
                        title: Text('${e.name} (${e.type})'),
                        subtitle: Text(DateFormat('d MMM yyyy', 'id_ID').format(e.date)),
                      );
                    }).toList(),
                  ),
          ),

          _sectionCard(
            icon: Icons.sticky_note_2,
            title: 'Materi Terakhir',
            child: lastNote == null
                ? const Text('Belum ada catatan materi.')
                : ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(lastNote.title),
                    subtitle: Text('${store.subjectName(lastNote.subjectId)} • Bab ${lastNote.chapter}'),
                  ),
          ),

          _sectionCard(
            icon: Icons.savings,
            title: 'Uang Sangu Hari Ini',
            child: todayFinance == null
                ? const Text('Belum ada catatan keuangan hari ini.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Uang sangu: ${currency.format(todayFinance.allowance)}'),
                      Text('Pengeluaran: ${currency.format(todayFinance.expense)}'),
                      Text('Sisa uang: ${currency.format(todayFinance.remaining)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: SMColors.green)),
                    ],
                  ),
          ),

          _sectionCard(
            icon: Icons.flag,
            title: 'Target Belajar',
            child: activeTargets.isEmpty
                ? const Text('Belum ada target belajar aktif.')
                : Column(
                    children: activeTargets.take(3).map((t) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name),
                            LinearProgressIndicator(
                              value: (t.progress.clamp(0, 100)) / 100,
                              color: SMColors.green,
                              backgroundColor: Colors.black12,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required IconData icon, required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: SMColors.navy, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
