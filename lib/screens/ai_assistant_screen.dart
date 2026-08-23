import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../store.dart';
import '../theme.dart';
import 'settings_screen.dart';

const String kGeminiModel = 'gemini-flash-latest';

const String kSystemInstruction = '''
Kamu adalah AI Asisten di aplikasi Study Mate bernama "SM Tutor".
Kamu BUKAN mesin pemberi jawaban instan untuk PR atau ujian.
Tugas utamamu adalah membantu pengguna (pelajar) memahami materi pelajaran mereka sendiri.

Aturan gaya bicara:
- Gunakan bahasa Indonesia yang sederhana dan mudah dipahami.
- Jelaskan secara bertahap, tidak bertele-tele.
- Utamakan pemahaman konsep, bukan jawaban akhir.
- Berikan contoh sederhana bila diperlukan.
- Ajak pengguna berpikir dengan pertanyaan pemandu, contoh:
  "Menurutmu bagian mana yang paling sulit?", "Coba perhatikan konsep ini...",
  "Kita pahami dari dasar dulu.", "Apa yang kamu sudah pahami dari materi tersebut?"
- Jika pengguna hanya meminta jawaban akhir PR/ujian secara langsung, jangan berikan jawaban
  instan; arahkan mereka memahami konsepnya dulu.
- Kamu boleh menggunakan konteks pelajaran/materi yang diberikan pengguna dari data Study Mate mereka.
''';

class AiAssistantScreen extends StatefulWidget {
  final AppStore store;
  const AiAssistantScreen({super.key, required this.store});
  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _ChatMessage {
  final String role; // 'user' atau 'model'
  final String text;
  _ChatMessage(this.role, this.text);
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _input = TextEditingController();
  bool _loading = false;
  String? _contextSubjectId;

  bool get _hasKey => widget.store.settings.geminiApiKey.trim().isNotEmpty;

  String _buildContext() {
    if (_contextSubjectId == null) return '';
    final store = widget.store;
    final subject = store.subjects.where((s) => s.id == _contextSubjectId);
    if (subject.isEmpty) return '';
    final s = subject.first;
    final relatedNotes = store.notes.where((n) => n.subjectId == s.id).toList();
    final buffer = StringBuffer();
    buffer.writeln('Konteks pelajaran dari data pengguna di Study Mate:');
    buffer.writeln('Mata Pelajaran: ${s.name}');
    if (s.chapter.isNotEmpty) buffer.writeln('Bab: ${s.chapter}');
    if (s.pages.isNotEmpty) buffer.writeln('Halaman: ${s.pages}');
    if (s.material.isNotEmpty) buffer.writeln('Materi: ${s.material}');
    if (s.notes.isNotEmpty) buffer.writeln('Catatan: ${s.notes}');
    for (final n in relatedNotes.take(3)) {
      buffer.writeln('---');
      buffer.writeln('Catatan Materi: ${n.title} (Bab ${n.chapter}, Hal ${n.pages})');
      if (n.content.isNotEmpty) buffer.writeln(n.content);
    }
    return buffer.toString();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || !_hasKey) return;
    setState(() {
      _messages.add(_ChatMessage('user', text));
      _loading = true;
    });
    _input.clear();

    try {
      final apiKey = widget.store.settings.geminiApiKey.trim();
      final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$kGeminiModel:generateContent?key=$apiKey');

      final context = _buildContext();
      final contents = <Map<String, dynamic>>[];
      for (final m in _messages) {
        contents.add({
          'role': m.role == 'user' ? 'user' : 'model',
          'parts': [
            {'text': m.text}
          ],
        });
      }

      final body = {
        'systemInstruction': {
          'parts': [
            {'text': context.isEmpty ? kSystemInstruction : '$kSystemInstruction\n\n$context'}
          ]
        },
        'contents': contents,
      };

      final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'Maaf, tidak ada respons.';
        setState(() => _messages.add(_ChatMessage('model', reply)));
      } else {
        String errMsg = 'Terjadi kesalahan (${res.statusCode}).';
        try {
          final data = jsonDecode(res.body);
          errMsg = data['error']?['message'] ?? errMsg;
        } catch (_) {}
        setState(() => _messages.add(_ChatMessage('model', '⚠️ $errMsg')));
      }
    } catch (e) {
      setState(() => _messages.add(_ChatMessage('model', '⚠️ Gagal menghubungi AI: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    if (!_hasKey) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Asisten')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_toy_outlined, size: 64, color: SMColors.navy),
              const SizedBox(height: 16),
              const Text('AI Asisten belum aktif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'Pasang API key Gemini kamu dari Google AI Studio dulu di menu Pengaturan sebelum bisa memakai AI Asisten.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(store: store)));
                  setState(() {});
                },
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Asisten')),
      body: Column(
        children: [
          if (store.subjects.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                initialValue: _contextSubjectId,
                decoration: const InputDecoration(labelText: 'Gunakan konteks pelajaran (opsional)', isDense: true),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tanpa konteks khusus')),
                  ...store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
                ],
                onChanged: (v) => setState(() => _contextSubjectId = v),
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Halo! Aku SM Tutor 🤖\nAku di sini buat bantu kamu memahami materi, bukan buat kasih jawaban instan.\nCoba ceritakan bagian mana yang masih membingungkan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final m = _messages[i];
                      final isUser = m.role == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                          decoration: BoxDecoration(
                            color: isUser ? SMColors.navy : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: isUser ? null : Border.all(color: Colors.black12),
                          ),
                          child: Text(m.text, style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator(color: SMColors.green)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Tulis pertanyaanmu di sini...'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _loading ? null : _send,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(backgroundColor: SMColors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
