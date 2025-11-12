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
  String _division = "Dhaka";
  bool _saving = false;

  String? _imageUrl; // saved image from server
  File? _pickedImage; // new image to upload

  final List<String> divisions = [
    "Dhaka",
    "Chattogram",
    "Rajshahi",
    "Khulna",
    "Barishal",
    "Sylhet",
    "Rangpur",
    "Mymensingh"
  ];

  @override
  void initState() {
    super.initState();
    _loadShopProfile();
  }

  // 🔹 Load existing profile
  Future<void> _loadShopProfile() async {
    final session = await SPrefs.readSession();
    if (session == null) return;

    try {
      final res = await ApiService().getShopProfile(session['user_id']);
      if (res['status'] == true && res['data'] != null) {
        final d = res['data'];
        setState(() {
          _shopName.text = d['full_name'] ?? '';
          _address.text = d['address'] ?? '';
          _timing.text = d['timing'] ?? '';
          _contact.text = d['contact'] ?? '';
          _division = d['division'] ?? "Dhaka";
          _imageUrl = d['image_url'];
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading shop profile: $e");
    }
  }

  // 🔹 Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _pickedImage = File(pickedFile.path));
    }
  }

  // 🔹 Upload new image to server
  Future<void> _uploadImage(int shopId) async {
    if (_pickedImage == null) return;
    try {
      final imageUrl = await ApiService().uploadShopImage(shopId, _pickedImage!.path);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        setState(() => _imageUrl = imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Image uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Image upload failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  // 🔹 Save profile info
  Future<void> _saveProfile() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final session = await SPrefs.readSession();
      final userId = session?['user_id'];

      final payload = {
        'shop_id': userId,
        'full_name': _shopName.text.trim(),
        'address': _address.text.trim(),
        'timing': _timing.text.trim(),
        'contact': _contact.text.trim(),
        'division': _division,
      };

      final res = await ApiService().updateShopProfile(payload);
      if (res['status'] == true) {
        if (_pickedImage != null) await _uploadImage(userId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Shop profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Update failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Shop Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ Image section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_imageUrl != null
                            ? NetworkImage(_imageUrl!)
                            : const AssetImage('assets/image/shop_placeholder.png'))
                        as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TColor.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🏪 Shop Info Fields
                TextFormField(
                  controller: _shopName,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter shop name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter address' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _timing,
                  decoration: const InputDecoration(
                    labelText: 'Timing (e.g. Sat–Fri 8.00am–10.00pm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter shop timing' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _contact,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter contact number' : null,
                ),
                const SizedBox(height: 14),

                // 📍 Division Dropdown
                DropdownButtonFormField<String>(
                  value: _division,
                  decoration: const InputDecoration(
                    labelText: 'Division',
                    border: OutlineInputBorder(),
                  ),
                  items: divisions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _division = v ?? "Dhaka"),
                ),
                const SizedBox(height: 30),

                // 💾 Save Button
                Center(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      minimumSize: const Size(120, 45),
                    ),
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save', style: TextStyle(color: Colors.white)),
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
