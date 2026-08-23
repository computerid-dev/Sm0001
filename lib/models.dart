import 'dart:math';

/// Generator ID sederhana, tidak butuh package tambahan.
String generateId() {
  final rnd = Random();
  final ts = DateTime.now().microsecondsSinceEpoch;
  final rand = rnd.nextInt(999999);
  return '$ts-$rand';
}

class CategoryItem {
  String id;
  String name;
  CategoryItem({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory CategoryItem.fromJson(Map<String, dynamic> j) =>
      CategoryItem(id: j['id'], name: j['name']);
}

class Subject {
  String id;
  String name;
  String teacher;
  String categoryId;
  String day; // hari default (bisa juga diatur lewat Jadwal)
  String timeStart;
  String timeEnd;
  String material; // materi terakhir
  String chapter; // bab
  String pages; // nomor halaman
  String notes;

  Subject({
    required this.id,
    required this.name,
    this.teacher = '',
    this.categoryId = '',
    this.day = '',
    this.timeStart = '',
    this.timeEnd = '',
    this.material = '',
    this.chapter = '',
    this.pages = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'teacher': teacher,
        'categoryId': categoryId,
        'day': day,
        'timeStart': timeStart,
        'timeEnd': timeEnd,
        'material': material,
        'chapter': chapter,
        'pages': pages,
        'notes': notes,
      };

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
        id: j['id'],
        name: j['name'] ?? '',
        teacher: j['teacher'] ?? '',
        categoryId: j['categoryId'] ?? '',
        day: j['day'] ?? '',
        timeStart: j['timeStart'] ?? '',
        timeEnd: j['timeEnd'] ?? '',
        material: j['material'] ?? '',
        chapter: j['chapter'] ?? '',
        pages: j['pages'] ?? '',
        notes: j['notes'] ?? '',
      );
}

class Homework {
  String id;
  String title;
  String subjectId;
  String description;
  DateTime createdAt;
  DateTime? deadline;
  bool done;
  String notes;

  Homework({
    required this.id,
    required this.title,
    this.subjectId = '',
    this.description = '',
    required this.createdAt,
    this.deadline,
    this.done = false,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subjectId': subjectId,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'done': done,
        'notes': notes,
      };

  factory Homework.fromJson(Map<String, dynamic> j) => Homework(
        id: j['id'],
        title: j['title'] ?? '',
        subjectId: j['subjectId'] ?? '',
        description: j['description'] ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
        deadline: j['deadline'] != null ? DateTime.tryParse(j['deadline']) : null,
        done: j['done'] ?? false,
        notes: j['notes'] ?? '',
      );
}

class FinanceEntry {
  String id;
  DateTime date;
  double allowance; // uang sangu
  double expense; // pengeluaran
  String description;

  FinanceEntry({
    required this.id,
    required this.date,
    this.allowance = 0,
    this.expense = 0,
    this.description = '',
  });

  double get remaining => allowance - expense;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'allowance': allowance,
        'expense': expense,
        'description': description,
      };

  factory FinanceEntry.fromJson(Map<String, dynamic> j) => FinanceEntry(
        id: j['id'],
        date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
        allowance: (j['allowance'] ?? 0).toDouble(),
        expense: (j['expense'] ?? 0).toDouble(),
        description: j['description'] ?? '',
      );
}

class ExamItem {
  String id;
  String name;
  String subjectId;
  String type; // Ulangan harian, UTS, UAS, dll
  DateTime date;
  String material;
  String notes;

  ExamItem({
    required this.id,
    required this.name,
    this.subjectId = '',
    this.type = 'Ulangan harian',
    required this.date,
    this.material = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subjectId': subjectId,
        'type': type,
        'date': date.toIso8601String(),
        'material': material,
        'notes': notes,
      };

  factory ExamItem.fromJson(Map<String, dynamic> j) => ExamItem(
        id: j['id'],
        name: j['name'] ?? '',
        subjectId: j['subjectId'] ?? '',
        type: j['type'] ?? 'Ulangan harian',
        date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
        material: j['material'] ?? '',
        notes: j['notes'] ?? '',
      );
}

class ScheduleItem {
  String id;
  String day; // Senin..Minggu
  String timeStart;
  String timeEnd;
  String subjectId;
  String notes;

  ScheduleItem({
    required this.id,
    required this.day,
    required this.timeStart,
    required this.timeEnd,
    required this.subjectId,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'timeStart': timeStart,
        'timeEnd': timeEnd,
        'subjectId': subjectId,
        'notes': notes,
      };

  factory ScheduleItem.fromJson(Map<String, dynamic> j) => ScheduleItem(
        id: j['id'],
        day: j['day'] ?? 'Senin',
        timeStart: j['timeStart'] ?? '',
        timeEnd: j['timeEnd'] ?? '',
        subjectId: j['subjectId'] ?? '',
        notes: j['notes'] ?? '',
      );
}

class MaterialNote {
  String id;
  String title;
  String subjectId;
  String chapter;
  String pages;
  String content;
  String notes;
  DateTime createdAt;

  MaterialNote({
    required this.id,
    required this.title,
    this.subjectId = '',
    this.chapter = '',
    this.pages = '',
    this.content = '',
    this.notes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subjectId': subjectId,
        'chapter': chapter,
        'pages': pages,
        'content': content,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MaterialNote.fromJson(Map<String, dynamic> j) => MaterialNote(
        id: j['id'],
        title: j['title'] ?? '',
        subjectId: j['subjectId'] ?? '',
        chapter: j['chapter'] ?? '',
        pages: j['pages'] ?? '',
        content: j['content'] ?? '',
        notes: j['notes'] ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
      );
}

class CalendarEvent {
  String id;
  String name;
  DateTime date;
  String description;
  String category; // Ujian, Libur, Acara, Deadline, Lainnya

  CalendarEvent({
    required this.id,
    required this.name,
    required this.date,
    this.description = '',
    this.category = 'Lainnya',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'description': description,
        'category': category,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> j) => CalendarEvent(
        id: j['id'],
        name: j['name'] ?? '',
        date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
        description: j['description'] ?? '',
        category: j['category'] ?? 'Lainnya',
      );
}

class StudyTarget {
  String id;
  String name;
  String description;
  String targetValue; // target waktu / jumlah, teks bebas
  double progress; // 0..100
  String status; // Berjalan, Selesai, Tertunda

  StudyTarget({
    required this.id,
    required this.name,
    this.description = '',
    this.targetValue = '',
    this.progress = 0,
    this.status = 'Berjalan',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'targetValue': targetValue,
        'progress': progress,
        'status': status,
      };

  factory StudyTarget.fromJson(Map<String, dynamic> j) => StudyTarget(
        id: j['id'],
        name: j['name'] ?? '',
        description: j['description'] ?? '',
        targetValue: j['targetValue'] ?? '',
        progress: (j['progress'] ?? 0).toDouble(),
        status: j['status'] ?? 'Berjalan',
      );
}

class AppSettings {
  String themeMode; // 'system', 'light', 'dark'
  String userName;
  String geminiApiKey;

  AppSettings({
    this.themeMode = 'system',
    this.userName = '',
    this.geminiApiKey = '',
  });

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'userName': userName,
        'geminiApiKey': geminiApiKey,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
        themeMode: j['themeMode'] ?? 'system',
        userName: j['userName'] ?? '',
        geminiApiKey: j['geminiApiKey'] ?? '',
      );
}
