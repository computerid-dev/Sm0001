import 'package:flutter/material.dart';
import 'store.dart';
import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/subjects_screen.dart';
import 'screens/homework_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/exams_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/targets_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/ai_assistant_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyMateApp());
}

class StudyMateApp extends StatefulWidget {
  const StudyMateApp({super.key});
  @override
  State<StudyMateApp> createState() => _StudyMateAppState();
}

class _StudyMateAppState extends State<StudyMateApp> {
  final AppStore store = AppStore();

  @override
  void initState() {
    super.initState();
    store.load().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (!store.loaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final mode = store.settings.themeMode == 'dark'
            ? ThemeMode.dark
            : store.settings.themeMode == 'light'
                ? ThemeMode.light
                : ThemeMode.system;
        return MaterialApp(
          title: 'Study Mate',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: mode,
          home: HomeShell(store: store),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  final AppStore store;
  const HomeShell({super.key, required this.store});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final tabs = [
      DashboardScreen(store: store),
      SubjectsScreen(store: store),
      HomeworkScreen(store: store),
      ScheduleScreen(store: store),
    ];
    final titles = ['Dashboard', 'Pelajaran', 'PR / Tugas', 'Jadwal'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_tabIndex])),
      drawer: _buildDrawer(context, store),
      body: tabs[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Pelajaran'),
          NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt), label: 'PR'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Jadwal'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppStore store) {
    Widget item(IconData icon, String title, Widget screen) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: SMColors.navy),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset('assets/icon/app_icon.png', width: 56, height: 56),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Study Mate', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Teman Belajar Digital', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            item(Icons.category_outlined, 'Kategori', CategoriesScreen(store: store)),
            item(Icons.savings_outlined, 'Catatan Keuangan', FinanceScreen(store: store)),
            item(Icons.fact_check_outlined, 'Ujian / Ulangan', ExamsScreen(store: store)),
            item(Icons.sticky_note_2_outlined, 'Catatan Materi', NotesScreen(store: store)),
            item(Icons.calendar_month_outlined, 'Kalender Akademik', CalendarScreen(store: store)),
            item(Icons.flag_outlined, 'Target Belajar', TargetsScreen(store: store)),
            item(Icons.smart_toy_outlined, 'AI Asisten', AiAssistantScreen(store: store)),
            const Divider(),
            item(Icons.settings_outlined, 'Pengaturan', SettingsScreen(store: store)),
            item(Icons.info_outline, 'Info Aplikasi & Developer', const AboutScreen()),
          ],
        ),
      ),
    );
  }
}
