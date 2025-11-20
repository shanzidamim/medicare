import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/services/api_service.dart';
import '../../shared_prefs_helper.dart';

class ShopProfileEditScreen extends StatefulWidget {
  const ShopProfileEditScreen({super.key});

  @override
  State<ShopProfileEditScreen> createState() => _ShopProfileEditScreenState();
}

class _ShopProfileEditScreenState extends State<ShopProfileEditScreen> {
  final _form = GlobalKey<FormState>();

  final _shopName = TextEditingController();
  final _address = TextEditingController();
  final _timing = TextEditingController();
  final _contact = TextEditingController();

  bool _saving = false;

  String? _imageUrl;
  File? _pickedImage;

  // Divisions
  List<dynamic> _divisions = [];
  String? _selectedDivisionId;

  @override
  void initState() {
    super.initState();
    _loadDivisions();
    _loadShop();
  }

  // ---------------- LOAD DIVISIONS ----------------
  Future<void> _loadDivisions() async {
    final div = await ApiService().getDivisions();
    setState(() => _divisions = div);
  }

  // ---------------- LOAD SHOP PROFILE ----------------
  Future<void> _loadShop() async {
    final session = await SPrefs.readSession();
    if (session == null) return;

    // 🔥 call your same function name (but updated inside ApiService)
    final shop = await ApiService().getMyShop();

    if (shop == null) return;

    setState(() {
      _shopName.text = shop['full_name'] ?? '';
      _address.text = shop['address'] ?? '';
      _timing.text = shop['timing'] ?? '';
      _contact.text = shop['contact'] ?? '';

      _imageUrl = shop['image_url'];
      _selectedDivisionId = shop['division_id']?.toString();
    });
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
  Future<void> _uploadImage(int shopId) async {
    if (_pickedImage == null) return;

    final formData = await ApiService().uploadShopImage(
      shopId,
      _pickedImage!.path,
    );

    if (formData is Map && formData['status'] == true) {
      setState(() => _imageUrl = (formData['image_url'] ?? '').toString());
    }
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> _saveProfile() async {
    if (!_form.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final session = await SPrefs.readSession();
      final shopId = int.tryParse(session?['user_id'].toString() ?? '') ?? 0;

      final payload = {
        'shop_id': shopId,                         // 🔥 MUST SEND shop_id
        'full_name': _shopName.text.trim(),
        'address': _address.text.trim(),
        'timing': _timing.text.trim(),
        'contact': _contact.text.trim(),
        'division_id': int.tryParse(_selectedDivisionId ?? "0") ?? 0,
      };

      // 🔥 SAME FUNCTION NAME
      final response = await ApiService().updateShop(shopId, payload);

      if (response['status'] == true) {
        if (_pickedImage != null) {
          await _uploadImage(shopId);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Medical shop updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Update failed')),
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
        title: const Text("Medical Shop Profile"),
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
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_imageUrl != null && _imageUrl!.isNotEmpty
                            ? NetworkImage(_imageUrl!) as ImageProvider
                            : const AssetImage('assets/image/default_shop.png')),
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
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // DIVISION
                DropdownButtonFormField(
                  value: _selectedDivisionId,
                  decoration: const InputDecoration(
                    labelText: "Division",
                    border: OutlineInputBorder(),
                  ),
                  items: _divisions
                      .map(
                        (e) => DropdownMenuItem(
                      value: e['id'].toString(),
                      child: Text(e['division_name']),
                    ),
                  )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedDivisionId = v as String),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _shopName,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  v!.isEmpty ? 'Enter shop name' : null,
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _timing,
                  decoration: const InputDecoration(
                    labelText: 'Timing',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _contact,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                  ),
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
                      : const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
