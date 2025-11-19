import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../common/color_extension.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  final int doctorId;
  const DoctorAppointmentsScreen({super.key, required this.doctorId});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _api.getDoctorAppointments(widget.doctorId);
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _changeStatus(int id, String status) async {
    final ok = await _api.updateAppointmentStatus(
      appointmentId: id,
      status: status,
    );
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment $status")),
      );
      _load();
    }
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
                  Text("Patient ID: ${a['user_id']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Date: ${a['appointment_date']}"),
                  Text("Reason: ${a['reason']}"),
                  if (a['message'] != null)
                    Text("Message: ${a['message']}"),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(a['status']),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          a['status'].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      if (a['status'] == 'pending') ...[
                        TextButton(
                          onPressed: () => _changeStatus(a['id'], 'approved'),
                          child: const Text("Approve"),
                        ),
                        TextButton(
                          onPressed: () => _changeStatus(a['id'], 'cancelled'),
                          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                        ),
                      ]
                    ],
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
