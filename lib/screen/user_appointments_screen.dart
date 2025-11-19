import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../common/color_extension.dart';

class UserAppointmentsScreen extends StatefulWidget {
  final int userId;
  const UserAppointmentsScreen({super.key, required this.userId});

  @override
  State<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _api.getUserAppointments(widget.userId);
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'approved': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: TColor.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final a = _items[i];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Doctor ID: ${a['doctor_id']}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("Date: ${a['appointment_date']}"),
                  Text("Reason: ${a['reason']}"),
                  if (a['message'] != null && a['message'].toString().isNotEmpty)
                    Text("Message: ${a['message']}"),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusColor(a['status']),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      a['status'].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
