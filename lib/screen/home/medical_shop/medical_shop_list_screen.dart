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
  State<MedicalShopListScreen> createState() => _MedicalShopListScreenState();
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
      final res = await apiService.getMedicalShopsByDivision(widget.divisionName);
      setState(() {
        shopList = res;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading shops: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: false,
        title: const Text(
          "Medical shop near by you",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: TColor.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : shopList.isEmpty
                ? const Center(child: Text("No shops found"))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemBuilder: (context, index) {
                var shop = shopList[index];
                return ShopRow(
                  obj: shop,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedicalShopProfileScreen(
                          shop: shop,
                          currentUserId: widget.currentUserId,
                        ),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(color: Colors.black12, height: 1),
              ),
              itemCount: shopList.length,
            ),
          ),
        ],
      ),
    );
  }
}
