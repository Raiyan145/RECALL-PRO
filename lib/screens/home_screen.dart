import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'add_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = StorageService();
  final auth = AuthService();
  List<Reminder> reminders = [];
  bool darkMode = false;
  ReminderPriority? filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await storage.loadReminders();
    final d = await storage.loadDarkMode();
    if (mounted) setState(() {
      reminders = r;
      darkMode = d;
    });
  }

  Future<void> _saveAll() => storage.saveReminders(reminders);

  Future<void> _addOrEdit([Reminder? old]) async {
    final result = await Navigator.push<Reminder>(
      context,
      MaterialPageRoute(builder: (_) => AddReminderScreen(existing: old)),
    );
    if (result == null) return;

    if (old != null) {
      await NotificationService.instance.cancel(old.id);
      reminders = reminders.map((r) => r.id == result.id ? result : r).toList();
    } else {
      reminders = [result, ...reminders];
    }

    await _saveAll();
    await NotificationService.instance.schedule(result);
    if (mounted) setState(() {});
  }

  Future<void> _delete(Reminder r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('Delete "${r.title}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    await NotificationService.instance.cancel(r.id);
    reminders.removeWhere((x) => x.id == r.id);
    await _saveAll();
    if (mounted) setState(() {});
  }

  Future<void> _toggleComplete(Reminder r) async {
    final updated = r.copyWith(completed: !r.completed);
    reminders = reminders.map((x) => x.id == r.id ? updated : x).toList();
    await _saveAll();
    if (mounted) setState(() {});
  }

  Future<void> _toggleTheme(bool value) async {
    setState(() => darkMode = value);
    await storage.saveDarkMode(value);
  }

  Future<void> _googleSignIn() async {
    try {
      final account = await auth.signIn();
      if (!mounted || account == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${account.email}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In needs Android OAuth configuration.')),
      );
    }
  }

  List<Reminder> get visible {
    final list = reminders.where((r) {
      if (filter == null) return true;
      return r.priority == filter;
    }).toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final normal = reminders.where((r) => r.priority == ReminderPriority.normal).length;
    final emergency = reminders.where((r) => r.priority == ReminderPriority.emergency).length;

    return Theme(
      data: darkMode ? ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF635BFF), brightness: Brightness.dark),
      ) : ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF635BFF),
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RecallPro', style: TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            IconButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (_) => StatefulBuilder(
                  builder: (context, setSheet) => SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const ListTile(
                          leading: Icon(Icons.auto_awesome),
                          title: Text('RecallPro'),
                          subtitle: Text('MADE BY ARVION'),
                        ),
                        SwitchListTile(
                          title: const Text('Night mode'),
                          subtitle: Text(darkMode ? 'Dark appearance' : 'Day appearance'),
                          value: darkMode,
                          onChanged: (v) {
                            setSheet(() {});
                            Navigator.pop(context);
                            _toggleTheme(v);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.login),
                          title: const Text('Continue with Google'),
                          onTap: () {
                            Navigator.pop(context);
                            _googleSignIn();
                          },
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addOrEdit(),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Reminder'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF635BFF), Color(0xFF8B83FF)]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your day, remembered.', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Set it once. Recall it when it matters.', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(children: [
              _stat('Normal', normal),
              const SizedBox(width: 10),
              _stat('Upcoming', reminders.length),
              const SizedBox(width: 10),
              _stat('Emergency', emergency, danger: true),
            ]),
            const SizedBox(height: 16),
            SegmentedButton<ReminderPriority?>(
              segments: const [
                ButtonSegment(value: null, label: Text('All')),
                ButtonSegment(value: ReminderPriority.normal, label: Text('Normal')),
                ButtonSegment(value: ReminderPriority.emergency, label: Text('Emergency')),
              ],
              selected: {filter},
              onSelectionChanged: (s) => setState(() => filter = s.first),
            ),
            const SizedBox(height: 22),
            const Text('Upcoming', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (visible.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No reminders yet. Tap + Reminder to add one.')),
              ),
            ...visible.map(_card),
            const SizedBox(height: 10),
            const Center(
              child: Text('MADE BY ARVION', style: TextStyle(fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, int count, {bool danger = false}) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Column(children: [
          Text('$count', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: danger ? Colors.red : null)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    ),
  );

  Widget _card(Reminder r) {
    final emergency = r.priority == ReminderPriority.emergency;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: emergency ? Colors.red.withOpacity(.12) : const Color(0xFFECEBFF),
          child: Icon(emergency ? Icons.priority_high : Icons.notifications_none, color: emergency ? Colors.red : const Color(0xFF635BFF)),
        ),
        title: Text(r.title, style: TextStyle(fontWeight: FontWeight.w800, decoration: r.completed ? TextDecoration.lineThrough : null)),
        subtitle: Text('${r.note.isEmpty ? 'No notes' : r.note}\n${_date(r.dateTime)}${r.repeat != RepeatType.none ? ' • ${r.repeat.name}' : ''}'),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _addOrEdit(r);
            if (v == 'delete') _delete(r);
            if (v == 'done') _toggleComplete(r);
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'done', child: Text(r.completed ? 'Mark active' : 'Mark done')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  String _date(DateTime d) =>
      '${d.day}/${d.month}/${d.year} • ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
