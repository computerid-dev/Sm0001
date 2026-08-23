import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Kunci penyimpanan lokal (SharedPreferences) untuk seluruh data Study Mate.
/// Semua data disimpan sebagai satu blok JSON, sehingga struktur ini juga
/// dipakai persis untuk fitur Backup & Import JSON (poin 7 & 8 spesifikasi).
const String kStorageKey = 'study_mate_data_v1';
const String kAppVersion = '1.0.0';

class AppStore extends ChangeNotifier {
  final List<CategoryItem> categories = [];
  final List<Subject> subjects = [];
  final List<Homework> homework = [];
  final List<FinanceEntry> finance = [];
  final List<ExamItem> exams = [];
  final List<ScheduleItem> schedule = [];
  final List<MaterialNote> notes = [];
  final List<CalendarEvent> calendarEvents = [];
  final List<StudyTarget> targets = [];
  AppSettings settings = AppSettings();

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kStorageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _loadFromMap(map);
      } catch (_) {
        _seedDefaults();
      }
    } else {
      _seedDefaults();
    }
    _loaded = true;
    notifyListeners();
  }

  void _seedDefaults() {
    categories.addAll([
      CategoryItem(id: generateId(), name: 'Eksakta'),
      CategoryItem(id: generateId(), name: 'Bahasa'),
      CategoryItem(id: generateId(), name: 'Sosial'),
      CategoryItem(id: generateId(), name: 'Seni'),
      CategoryItem(id: generateId(), name: 'Olahraga'),
      CategoryItem(id: generateId(), name: 'Agama'),
      CategoryItem(id: generateId(), name: 'Lainnya'),
    ]);
  }

  void _loadFromMap(Map<String, dynamic> map) {
    categories
      ..clear()
      ..addAll(((map['categories'] ?? []) as List)
          .map((e) => CategoryItem.fromJson(e)));
    subjects
      ..clear()
      ..addAll(((map['subjects'] ?? []) as List).map((e) => Subject.fromJson(e)));
    homework
      ..clear()
      ..addAll(((map['homework'] ?? []) as List).map((e) => Homework.fromJson(e)));
    finance
      ..clear()
      ..addAll(((map['finance'] ?? []) as List).map((e) => FinanceEntry.fromJson(e)));
    exams
      ..clear()
      ..addAll(((map['exams'] ?? []) as List).map((e) => ExamItem.fromJson(e)));
    schedule
      ..clear()
      ..addAll(((map['schedule'] ?? []) as List).map((e) => ScheduleItem.fromJson(e)));
    notes
      ..clear()
      ..addAll(((map['notes'] ?? []) as List).map((e) => MaterialNote.fromJson(e)));
    calendarEvents
      ..clear()
      ..addAll(((map['calendarEvents'] ?? []) as List)
          .map((e) => CalendarEvent.fromJson(e)));
    targets
      ..clear()
      ..addAll(((map['targets'] ?? []) as List).map((e) => StudyTarget.fromJson(e)));
    settings = map['settings'] != null
        ? AppSettings.fromJson(map['settings'])
        : AppSettings();
  }

  Map<String, dynamic> toMap() => {
        'app': 'Study Mate',
        'shortName': 'SM',
        'version': kAppVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'categories': categories.map((e) => e.toJson()).toList(),
        'subjects': subjects.map((e) => e.toJson()).toList(),
        'homework': homework.map((e) => e.toJson()).toList(),
        'finance': finance.map((e) => e.toJson()).toList(),
        'exams': exams.map((e) => e.toJson()).toList(),
        'schedule': schedule.map((e) => e.toJson()).toList(),
        'notes': notes.map((e) => e.toJson()).toList(),
        'calendarEvents': calendarEvents.map((e) => e.toJson()).toList(),
        'targets': targets.map((e) => e.toJson()).toList(),
        'settings': settings.toJson(),
      };

  String exportJson() => const JsonEncoder.withIndent('  ').convert(toMap());

  /// Mengembalikan data dari string JSON hasil backup sebelumnya.
  /// Melempar FormatException jika JSON tidak valid, sehingga UI bisa
  /// menampilkan peringatan sebelum data lama ditimpa.
  void importFromJsonString(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _loadFromMap(map);
    notifyListeners();
    persist();
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kStorageKey, jsonEncode(toMap()));
  }

  Future<void> resetAll() async {
    categories.clear();
    subjects.clear();
    homework.clear();
    finance.clear();
    exams.clear();
    schedule.clear();
    notes.clear();
    calendarEvents.clear();
    targets.clear();
    settings = AppSettings();
    _seedDefaults();
    notifyListeners();
    await persist();
  }

  // ---------- Helper CRUD generik: dipanggil dari layar masing-masing ----------

  Future<void> save() async {
    notifyListeners();
    await persist();
  }

  String subjectName(String id) {
    final s = subjects.where((e) => e.id == id);
    return s.isEmpty ? '-' : s.first.name;
  }

  String categoryName(String id) {
    final c = categories.where((e) => e.id == id);
    return c.isEmpty ? '-' : c.first.name;
  }
}
