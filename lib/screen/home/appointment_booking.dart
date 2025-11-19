import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

import '../../common/color_extension.dart';
import '../../services/api_service.dart';
import '../shared_prefs_helper.dart';   // <-- REQUIRED to load user_id


class AppointmentBookingScreen extends StatefulWidget {
  final int doctorId;
  final int currentUserId; // will be ignored (kept for compatibility)

  const AppointmentBookingScreen({
    super.key,
    required this.doctorId,
    required this.currentUserId,
  });

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final ApiService _api = ApiService();

  DateTime? _date;
  int _realUserId = 0;   // <-- NEW
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _msgCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();   // <-- NEW
  }

  Future<void> _loadUserId() async {
    final session = await SPrefs.readSession();
    setState(() {
      _realUserId = session?['user_id'] ?? 0;
    });

    print("🔥 Loaded REAL USER ID = $_realUserId");
  }

  Future<void> _pickDate() async {
    final results = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        firstDayOfWeek: 1,
        calendarType: CalendarDatePicker2Type.single,
        selectedDayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        selectedDayHighlightColor: TColor.primary,
        centerAlignModePicker: true,
        customModePickerIcon: const SizedBox(),
      ),
      dialogSize: const Size(325, 400),
      value: [],
      borderRadius: BorderRadius.circular(15),
    );
    if (results != null && results.isNotEmpty) {
      setState(() => _date = results.first);
    }
  }

  Future<void> _submit() async {
    if (_realUserId == 0) {
      _snack('User not logged in. Please login again.');
      return;
    }
    if (_date == null) {
      _snack('Please select a date');
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      _snack('Please enter a reason');
      return;
    }

    setState(() => _submitting = true);

    final ok = await _api.bookAppointment(
      doctorId: widget.doctorId,
      userId: _realUserId,      // <-- FIXED (Correct user_id)
      date: "${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}",
      reason: _reasonCtrl.text.trim(),
      message: _msgCtrl.text.trim(),
    );

    print("📤 Sending Appointment with user_id = $_realUserId");

    setState(() => _submitting = false);

    if (ok) {
      _snack('Appointment booked successfully');
      Navigator.pop(context);
    } else {
      _snack('Failed to book appointment');
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white, size: 25),
        ),
        title: Text(
          "Appointment Booking",
          style: TextStyle(color: TColor.primaryTextW, fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 35,
              decoration: BoxDecoration(
                color: TColor.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _label('Date'),
            _box(
              onTap: _pickDate,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _date == null
                          ? "Select Date"
                          : _date!.toIso8601String().split('T').first,
                      style: TextStyle(
                        color: _date == null ? TColor.secondaryText : TColor.primaryText,
                      ),
                    ),
                  ),
                  Icon(Icons.date_range, color: TColor.primary, size: 30),
                ],
              ),
            ),

            _label('Reason For Visit'),
            _box(
              child: TextField(
                controller: _reasonCtrl,
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Enter Reason For Visit",
                  hintStyle: TextStyle(color: TColor.secondaryText, fontSize: 14),
                ),
              ),
            ),

            _label('Message'),
            _box(
              child: TextField(
                controller: _msgCtrl,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Enter Your Message",
                  hintStyle: TextStyle(color: TColor.secondaryText, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _submitting
                    ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2,
                  ),
                )
                    : const Text("Book Appointment"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Text(t, style: TextStyle(color: TColor.black, fontSize: 14, fontWeight: FontWeight.w600)),
  );

  Widget _box({Widget? child, VoidCallback? onTap}) => InkWell(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
      ),
      height: 50,
      alignment: Alignment.centerLeft,
      child: child,
    ),
  );
}
