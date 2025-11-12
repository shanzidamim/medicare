import 'package:flutter/material.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/services/api_service.dart';
import 'doctor_profile_screen.dart';
import 'doctor_row.dart';

class AllDivisionDoctorsScreen extends StatefulWidget {
  final int? divisionId;
  final String divisionName;
  final Map<String, dynamic>? selectedCategory;
  final int currentUserId;

  const AllDivisionDoctorsScreen({
    super.key,
    required this.divisionId,
    required this.divisionName,
    this.selectedCategory,
    required this.currentUserId,
  });

  @override
  State<AllDivisionDoctorsScreen> createState() =>
      _AllDivisionDoctorsScreenState();
}

class _AllDivisionDoctorsScreenState extends State<AllDivisionDoctorsScreen> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadDoctors();
  }

  Future<void> loadDoctors() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      int? divisionId = widget.divisionId;

      if (divisionId == null) {
        final divisions = await _api.getDivisions();
        final selectedDiv = divisions.firstWhere(
              (d) => (d['division_name'] as String)
              .toLowerCase()
              .contains(widget.divisionName.toLowerCase()),
          orElse: () => divisions.first,
        );
        divisionId = selectedDiv['id'];
      }

      if (widget.selectedCategory != null) {
        doctors = List<Map<String, dynamic>>.from(
          await _api.getDoctorsByDivisionAndCategory(
            divisionId!,
            widget.selectedCategory!['id'],
          ),
        );
      } else {
        doctors = List<Map<String, dynamic>>.from(
          await _api.getDoctorsByDivision(divisionId!),
        );
      }

      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.selectedCategory != null
        ? "${widget.selectedCategory!['category_name']} Doctors"
        : "Doctors in ${widget.divisionName}";

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(pageTitle, style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: TColor.primary,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadDoctors,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
              ? _errorWidget()
              : doctors.isEmpty
              ? const Center(
              child: Text("No doctors found", style: TextStyle(fontSize: 16, color: Colors.black54)))
              : ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
            separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Colors.black12),
          ),
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 10),
          const Text("Failed to load doctors", style: TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: loadDoctors,
            style: ElevatedButton.styleFrom(backgroundColor: TColor.primary),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }
}
