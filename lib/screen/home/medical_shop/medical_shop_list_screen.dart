import 'package:flutter/material.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/screen/home/medical_shop/shop_row.dart';
import 'package:medicare/screen/home/medical_shop/medical_shop_profile_screen.dart';
import 'package:medicare/services/api_service.dart';

class MedicalShopListScreen extends StatefulWidget {
  final int currentUserId;
  final String divisionName;

  const MedicalShopListScreen({
    super.key,
    this.divisionName = "Dhaka",
    required this.currentUserId,
  });

  @override
  State<MedicalShopListScreen> createState() =>
      _MedicalShopListScreenState();
}

class _MedicalShopListScreenState extends State<MedicalShopListScreen> {
  final ApiService apiService = ApiService();
  bool isLoading = true;
  List<dynamic> shopList = [];

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    try {
      // 1. Load all divisions
      final divisions = await apiService.getDivisions();
      if (divisions.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // 2. Match divisionName to division_id
      final selected = divisions.firstWhere(
            (d) => d['division_name']
            .toString()
            .toLowerCase()
            .contains(widget.divisionName.toLowerCase()),
        orElse: () => divisions.first,
      );

      final divisionId = selected["id"].toString();
      debugPrint(" Calling shops for division_id = $divisionId");

      // 3. Call shop API with division_id
      final list = await apiService.getMedicalShopsByDivision(divisionId);

      // 4. Fix image URLs
      final fixed = list.map((shop) {
        final img = shop["image_url"]?.toString() ?? "";
        final full = img.startsWith("http")
            ? img
            : (img.isNotEmpty ? "${apiService.baseHost}/$img" : "");

        return {...shop, "image_url": full};
      }).toList();

      setState(() {
        shopList = fixed;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Shop load error: $e");
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical shop near you"),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : shopList.isEmpty
          ? const Center(child: Text("No shops found"))
          : ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (_, index) {
          final shop = shopList[index];
          return ShopRow(
            obj: {
              ...shop,
              "image_url": shop["image_url"]?.toString() ?? "",
            },

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MedicalShopProfileScreen(
                    shop: Map<String, dynamic>.from(shop),
                    currentUserId: widget.currentUserId,
                  ),

                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: shopList.length,
      ),
    );
  }
}
