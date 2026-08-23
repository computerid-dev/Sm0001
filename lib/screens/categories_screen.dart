import 'package:flutter/material.dart';
import '../store.dart';
import '../models.dart';

class CategoriesScreen extends StatefulWidget {
  final AppStore store;
  const CategoriesScreen({super.key, required this.store});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Future<void> _addOrEdit({CategoryItem? existing}) async {
    final controller = TextEditingController(text: existing?.name ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nama kategori'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    setState(() {
      if (existing == null) {
        widget.store.categories.add(CategoryItem(id: generateId(), name: result));
      } else {
        existing.name = result;
      }
    });
    widget.store.save();
  }

  Future<void> _delete(CategoryItem c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus kategori "${c.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => widget.store.categories.remove(c));
      widget.store.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.store.categories;
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: list.isEmpty
          ? const Center(child: Text('Belum ada kategori. Tap + untuk menambah.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final c = list[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: Text(c.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _addOrEdit(existing: c)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(c)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => _addOrEdit(), child: const Icon(Icons.add)),
    );
  }
}
