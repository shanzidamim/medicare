import 'package:flutter/material.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/services/api_service.dart';
import 'doctor_profile_screen.dart';
import 'doctor_row.dart';

class DoctorsListScreen extends StatefulWidget {
  final int selectedDivisionId;
  final String selectedDivisionName;
  final Map<String, dynamic> selectedCategory;
  final int currentUserId;

  const DoctorsListScreen({
    super.key,
    required this.selectedDivisionId,
    required this.selectedDivisionName,
    required this.selectedCategory,
    required this.currentUserId,
  });

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final ApiService _api = ApiService();
  List doctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => isLoading = true);
    try {
      doctors = await _api.getDoctorsByDivisionAndCategory(
        widget.selectedDivisionId,
        widget.selectedCategory['id'],
      );
    } catch (_) {}
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primary,
        centerTitle: true,
        title: Text(
          widget.selectedCategory['category_name'] ?? "Doctors List",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(children: [
        Container(
          width: double.infinity,
          color: TColor.primary,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Text("Division: ${widget.selectedDivisionName}",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : doctors.isEmpty
              ? const Center(child: Text("No doctors found"))
              : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return DoctorRow(
                doctor: doctor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorProfileScreen(
                        doctor: doctor,
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
          ),
        ),
      ]),
    );
  }
}
