import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/services/api_service.dart';
import '../shared_prefs_helper.dart';

class DoctorProfileEditScreen extends StatefulWidget {
  const DoctorProfileEditScreen({super.key});

  @override
  State<DoctorProfileEditScreen> createState() => _DoctorProfileEditScreenState();
}

class _DoctorProfileEditScreenState extends State<DoctorProfileEditScreen> {
  final _form = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _degree = TextEditingController();
  final _specialty = TextEditingController();
  final _clinic = TextEditingController();
  final _address = TextEditingController();
  final _experience = TextEditingController();
  final _visitDays = TextEditingController();
  final _visitTime = TextEditingController();

  bool _saving = false;

  // ------------------ IMAGE ------------------
  String? _imageUrl;
  File? _pickedImage;

  // ------------------ DROPDOWNS ------------------
  String? _selectedDivision;
  String? _selectedCategory;

  List<dynamic> _divisions = [];
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    _loadDoctor();
  }

  // ---------------- LOAD CATEGORY & DIVISIONS ----------------
  Future<void> _loadDropdownData() async {
    final div = await ApiService().getDivisions();
    final cat = await ApiService().getCategories();

    setState(() {
      _divisions = div;
      _categories = cat;
    });
  }

  // ---------------- LOAD EXISTING PROFILE ----------------
  Future<void> _loadDoctor() async {
    final session = await SPrefs.readSession();
    if (session == null) return;

    final userId = session['user_id'];

    // FIXED: API returns ONLY the doctor object
    final d = await ApiService().getDoctorProfile(userId);

    if (d.isNotEmpty) {
      setState(() {
        _name.text = d['full_name'] ?? '';
        _contact.text = d['contact'] ?? '';
        _degree.text = d['degrees'] ?? '';
        _specialty.text = d['specialty_detail'] ?? '';
        _clinic.text = d['clinic_or_hospital'] ?? '';
        _address.text = d['address'] ?? '';
        _experience.text = d['years_experience']?.toString() ?? '';
        _visitDays.text = d['visit_days'] ?? '';
        _visitTime.text = d['visiting_time'] ?? '';

        _imageUrl = d['image_url'];

        _selectedDivision = d['division_id']?.toString();
        _selectedCategory = d['category_id']?.toString();
      });
    }
  }

  // ---------------- PICK IMAGE ----------------
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  // ---------------- UPLOAD IMAGE ----------------
  Future<void> _uploadImage(int doctorId) async {
    if (_pickedImage == null) return;

    final res = await ApiService().uploadDoctorImage(
      doctorId,
      _pickedImage!.path,
    );

    if (res['status'] == true) {
      setState(() => _imageUrl = res['image_url']);
    }
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> _saveProfile() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final session = await SPrefs.readSession();
      final doctorId = session?['user_id'];

      final payload = {
        'doctor_id': doctorId,
        'full_name': _name.text.trim(),
        'contact': _contact.text.trim(),
        'degrees': _degree.text.trim(),
        'specialty_detail': _specialty.text.trim(),
        'clinic_or_hospital': _clinic.text.trim(),
        'address': _address.text.trim(),
        'years_experience': _experience.text.trim(),
        'visit_days': _visitDays.text.trim(),
        'visiting_time': _visitTime.text.trim(),

        'division_id': int.parse(_selectedDivision!),
        'category_id': int.parse(_selectedCategory!),
      };

      final res = await ApiService().updateDoctorProfile(payload);

      if (res['status'] == true) {
        if (_pickedImage != null) {
          await _uploadImage(doctorId);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Doctor profile updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Update failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Network or server error")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Profile"),
        backgroundColor: TColor.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],

                        // FIXED: type-safe ImageProvider
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_imageUrl != null && _imageUrl!.isNotEmpty
                            ? NetworkImage(_imageUrl!) as ImageProvider
                            : const AssetImage('assets/image/default_doctor.png')),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ---------- DIVISION ----------
                DropdownButtonFormField(
                  value: _selectedDivision,
                  decoration: const InputDecoration(
                      labelText: "Division", border: OutlineInputBorder()),
                  items: _divisions
                      .map(
                        (e) => DropdownMenuItem(
                      value: e['id'].toString(),
                      child: Text(e['division_name']),
                    ),
                  )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedDivision = v as String),
                ),

                const SizedBox(height: 14),

                // ---------- CATEGORY ----------
                DropdownButtonFormField(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                      labelText: "Category", border: OutlineInputBorder()),
                  items: _categories
                      .map(
                        (e) => DropdownMenuItem(
                      value: e['id'].toString(),
                      child: Text(e['category_name']),
                    ),
                  )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedCategory = v as String),
                ),

                const SizedBox(height: 14),

                // -------- OTHER FIELDS ----------
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'Full Name', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Enter doctor name' : null,
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _contact,
                  decoration: const InputDecoration(
                      labelText: 'Contact', border: OutlineInputBorder()),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _degree,
                  decoration: const InputDecoration(
                      labelText: 'Degree / Qualification',
                      border: OutlineInputBorder()),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _specialty,
                  decoration: const InputDecoration(
                      labelText: 'Specialty Detail',
                      border: OutlineInputBorder()),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _clinic,
                  decoration: const InputDecoration(
                      labelText: 'Clinic / Hospital',
                      border: OutlineInputBorder()),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                      labelText: 'Address', border: OutlineInputBorder()),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _experience,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder()),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _visitDays,
                  decoration: const InputDecoration(
                      labelText: 'Visit Days', border: OutlineInputBorder()),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _visitTime,
                  decoration: const InputDecoration(
                      labelText: 'Visiting Time', border: OutlineInputBorder()),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                    minimumSize: const Size(140, 48),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
