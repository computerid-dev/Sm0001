import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../store.dart';
import '../models.dart';
import '../theme.dart';

class FinanceScreen extends StatefulWidget {
  final AppStore store;
  const FinanceScreen({super.key, required this.store});
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  Future<void> _form({FinanceEntry? existing}) async {
    final store = widget.store;
    final allowance = TextEditingController(text: existing?.allowance.toStringAsFixed(0) ?? '');
    final expense = TextEditingController(text: existing?.expense.toStringAsFixed(0) ?? '');
    final desc = TextEditingController(text: existing?.description ?? '');
    DateTime date = existing?.date ?? DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          title: Text(existing == null ? 'Tambah Catatan Keuangan' : 'Edit Catatan Keuangan'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Tanggal: ${DateFormat('d MMM yyyy', 'id_ID').format(date)}'),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                  if (picked != null) setSt(() => date = picked);
                },
              ),
              TextField(controller: allowance, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Uang sangu (Rp)')),
              const SizedBox(height: 10),
              TextField(controller: expense, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pengeluaran (Rp)')),
              const SizedBox(height: 10),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'Keterangan pengeluaran')),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
          ],
        );
      }),
    );

    if (saved != true) return;
    final a = double.tryParse(allowance.text.trim()) ?? 0;
    final e = double.tryParse(expense.text.trim()) ?? 0;
    if (existing == null) {
      store.finance.add(FinanceEntry(id: generateId(), date: date, allowance: a, expense: e, description: desc.text.trim()));
    } else {
      existing.date = date;
      existing.allowance = a;
      existing.expense = e;
      existing.description = desc.text.trim();
    }
    setState(() {});
    store.save();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final list = store.finance.toList()..sort((a, b) => b.date.compareTo(a.date));
    final totalAllowance = list.fold<double>(0, (p, e) => p + e.allowance);
    final totalExpense = list.fold<double>(0, (p, e) => p + e.expense);

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Keuangan Sekolah')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: SMColors.navy, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summary('Total Sangu', currency.format(totalAllowance)),
                _summary('Total Keluar', currency.format(totalExpense)),
                _summary('Sisa', currency.format(totalAllowance - totalExpense)),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Belum ada catatan keuangan.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final f = list[i];
                      return Card(
                        child: ListTile(
                          title: Text(DateFormat('EEEE, d MMM yyyy', 'id_ID').format(f.date)),
                          subtitle: Text('Sangu ${currency.format(f.allowance)} • Keluar ${currency.format(f.expense)}\n'
                              'Sisa ${currency.format(f.remaining)}${f.description.isNotEmpty ? ' • ${f.description}' : ''}'),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _form(existing: f);
                              if (v == 'delete') {
                                setState(() => store.finance.remove(f));
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

  Widget _summary(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      );
}
