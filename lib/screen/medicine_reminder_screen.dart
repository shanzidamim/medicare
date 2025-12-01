import 'package:flutter/material.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/services/api_service.dart';
import 'package:medicare/services/notification_service.dart';

class MedicineReminderScreen extends StatefulWidget {
  final int userId;

  const MedicineReminderScreen({super.key, required this.userId});

  @override
  State<MedicineReminderScreen> createState() =>
      _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final ApiService api = ApiService();

  final TextEditingController _medicineCtrl = TextEditingController();
  final TextEditingController _doseCtrl = TextEditingController();

  TimeOfDay? _selectedTime;
  DateTime? _startDate;
  DateTime? _endDate;
  String _timeOfDayLabel = "morning";
  String _repeatType = "daily";

  bool _loading = false;
  List<dynamic> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _loading = true);
    final data = await api.getReminders(widget.userId);
    setState(() {
      _reminders = data;
      _loading = false;
    });
  }

  // -------------------------------------------------------
  // TIME PICKER WITH APP COLOR
  // -------------------------------------------------------
  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TColor.primary, // OK button, dial hand
              onPrimary: Colors.white, // text on primary
              onSurface: Colors.black, // normal text
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (t != null) {
      setState(() => _selectedTime = t);
    }
  }

  Future<void> _pickStartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() => _startDate = d);
    }
  }

  Future<void> _pickEndDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() => _endDate = d);
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return "Select";
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(TimeOfDay? t) {
    if (t == null) return "Pick time";
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  // -------------------------------------------------------
  // SAVE REMINDER
  // -------------------------------------------------------
  Future<void> _saveReminder() async {
    if (_medicineCtrl.text.trim().isEmpty ||
        _selectedTime == null ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    final time = _selectedTime!;
    final start = _startDate!;
    final end = _endDate!;

    final reminderTimeStr =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";

    final body = {
      "user_id": widget.userId,
      "medicine_name": _medicineCtrl.text.trim(),
      "dose": _doseCtrl.text.trim(),
      "time_of_day": _timeOfDayLabel,
      "reminder_time": reminderTimeStr,
      "start_date": _formatDate(start),
      "end_date": _formatDate(end),
      "repeat_type": _repeatType,
    };

    setState(() => _loading = true);

    final res = await api.addReminder(body);

    setState(() => _loading = false);

    if (res["status"] == 1) {
      final int reminderId = res["id"];

      // local notification
      await NotificationService.scheduleDailyReminder(
        id: reminderId,
        title: "Take your medicine",
        body:
        "${_medicineCtrl.text.trim()} ${_doseCtrl.text.isNotEmpty ? "– ${_doseCtrl.text}" : ""}",
        hour: time.hour,
        minute: time.minute,
      );

      _medicineCtrl.clear();
      _doseCtrl.clear();
      _selectedTime = null;
      _startDate = null;
      _endDate = null;

      await _loadReminders();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reminder saved")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save reminder")),
      );
    }
  }

  Future<void> _deleteReminder(dynamic item) async {
    final int id = item["id"];
    final ok = await api.deleteReminder(id);

    if (ok) {
      await NotificationService.cancelReminder(id);
      await _loadReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reminder deleted")),
      );
    }
  }

  // -------------------------------------------------------
  // BUILD UI
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medicine Reminders")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // INPUTS
            TextField(
              controller: _medicineCtrl,
              decoration: const InputDecoration(
                labelText: "Medicine name *",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _doseCtrl,
              decoration: const InputDecoration(
                labelText: "Dose (e.g. 1 tablet)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // TIME + TIME OF DAY
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _timeOfDayLabel,
                    decoration: const InputDecoration(
                      labelText: "Time of day",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "morning", child: Text("Morning")),
                      DropdownMenuItem(value: "afternoon", child: Text("Afternoon")),
                      DropdownMenuItem(value: "evening", child: Text("Evening")),
                      DropdownMenuItem(value: "night", child: Text("Night")),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _timeOfDayLabel = v);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _pickTime,
                    child: Text(_formatTime(_selectedTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // DATE RANGE
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _pickStartDate,
                    child: Text("Start: ${_formatDate(_startDate)}"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _pickEndDate,
                    child: Text("End: ${_formatDate(_endDate)}"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // REPEAT TYPE
            DropdownButtonFormField<String>(
              value: _repeatType,
              decoration: const InputDecoration(
                labelText: "Repeat",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "daily", child: Text("Daily")),
                DropdownMenuItem(value: "custom", child: Text("Custom (future)")),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _repeatType = v);
              },
            ),

            const SizedBox(height: 16),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _loading ? null : _saveReminder,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Reminder"),
              ),
            ),


            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Reminders",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            _loading
                ? const Center(child: CircularProgressIndicator())
                : _reminders.isEmpty
                ? const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("No reminders yet"),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reminders.length,
              itemBuilder: (_, i) {
                final m = _reminders[i];
                final name = m["medicine_name"] ?? "";
                final dose = m["dose"] ?? "";
                final rt = (m["reminder_time"] ?? "").toString();
                final tod = (m["time_of_day"] ?? "").toString();

                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(
                        "${dose.isNotEmpty ? "$dose • " : ""}$tod • $rt"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReminder(m),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
