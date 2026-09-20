import 'package:flutter/material.dart';
import '../models/reminder.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? existing;
  const AddReminderScreen({super.key, this.existing});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  late final TextEditingController title;
  late final TextEditingController note;
  late DateTime selected;
  late ReminderPriority priority;
  late RepeatType repeat;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    title = TextEditingController(text: r?.title ?? '');
    note = TextEditingController(text: r?.note ?? '');
    selected = r?.dateTime ?? DateTime.now().add(const Duration(hours: 1));
    priority = r?.priority ?? ReminderPriority.normal;
    repeat = r?.repeat ?? RepeatType.none;
  }

  @override
  void dispose() {
    title.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New reminder' : 'Edit reminder'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: title,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'What do you need to remember?',
              prefixIcon: Icon(Icons.edit_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: note,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Priority', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SegmentedButton<ReminderPriority>(
            segments: const [
              ButtonSegment(
                value: ReminderPriority.normal,
                label: Text('Normal'),
                icon: Icon(Icons.notifications_none),
              ),
              ButtonSegment(
                value: ReminderPriority.emergency,
                label: Text('Emergency'),
                icon: Icon(Icons.priority_high),
              ),
            ],
            selected: {priority},
            onSelectionChanged: (s) => setState(() => priority = s.first),
          ),
          const SizedBox(height: 20),
          const Text('Repeat', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          DropdownButtonFormField<RepeatType>(
            value: repeat,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: RepeatType.none, child: Text('Does not repeat')),
              DropdownMenuItem(value: RepeatType.daily, child: Text('Every day')),
              DropdownMenuItem(value: RepeatType.weekly, child: Text('Every week')),
              DropdownMenuItem(value: RepeatType.monthly, child: Text('Every month')),
            ],
            onChanged: (v) => setState(() => repeat = v ?? RepeatType.none),
          ),
          const SizedBox(height: 18),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('When', style: TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(_formatDate(selected)),
            trailing: FilledButton.tonalIcon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.schedule),
              label: const Text('Set'),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(widget.existing == null
                  ? 'Create reminder'
                  : 'Save changes'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: selected.isBefore(DateTime.now()) ? DateTime.now() : selected,
    );
    if (!mounted || d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selected),
    );
    if (t != null) {
      setState(() {
        selected = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      });
    }
  }

  void _save() {
    final value = title.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reminder title.')),
      );
      return;
    }

    Navigator.pop(
      context,
      Reminder(
        id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: value,
        note: note.text.trim(),
        dateTime: selected,
        priority: priority,
        repeat: repeat,
        completed: widget.existing?.completed ?? false,
      ),
    );
  }
}
