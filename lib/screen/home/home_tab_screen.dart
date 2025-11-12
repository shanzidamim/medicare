import 'package:flutter/material.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/common_widget/section_row.dart';
import 'package:medicare/services/api_service.dart';
import 'all_division_doctors_screen.dart';
import 'doctor_cell.dart';
import 'doctor_profile_screen.dart';
import 'medical_shop/medical_shop_list_screen.dart';
import 'medical_shop/medical_shop_profile_screen.dart';
import 'shop_cell.dart';

class HomeTabScreen extends StatefulWidget {
  final String selectedDivision;
  final int currentUserId;

  const HomeTabScreen({
    super.key,
    required this.selectedDivision,
    required this.currentUserId,
  });

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final ApiService apiService = ApiService();

  List<dynamic> categoryArr = [];
  List<dynamic> doctorArr = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      final catRes = await apiService.getCategories();
      await loadDoctors(widget.selectedDivision);
      if (mounted) {
        setState(() {
          categoryArr = catRes;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading home data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> loadDoctors(String divisionName) async {
    try {
      final divRes = await apiService.getDivisions();
      if (divRes.isEmpty) return;
      final selectedDivision = divRes.firstWhere(
            (d) => (d['division_name'] as String)
            .toLowerCase()
            .contains(divisionName.toLowerCase()),
        orElse: () => divRes.first,
      );
      final docRes = await apiService.getDoctorsByDivision(selectedDivision['id']);
      if (mounted) setState(() => doctorArr = docRes);
    } catch (e) {
      debugPrint("Error loading doctors: $e");
    }
  }

  @override
  void didUpdateWidget(HomeTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDivision != widget.selectedDivision) {
      loadDoctors(widget.selectedDivision);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 15, bottom: 5),
              child: Text(
                "Categories",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categoryArr.length,
                separatorBuilder: (context, index) =>
                const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  var obj = categoryArr[index];
                  final imageUrl = obj["image_url"] ?? "";
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllDivisionDoctorsScreen(
                            divisionId: null,
                            divisionName: widget.selectedDivision,
                            selectedCategory: obj,
                            currentUserId: widget.currentUserId,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageUrl.startsWith('http')
                                ? Image.network(
                              imageUrl,
                              width: 55,
                              height: 55,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  Image.asset(
                                    "assets/image/default_category.png",
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.contain,
                                  ),
                            )
                                : Image.asset(
                              imageUrl.isNotEmpty
                                  ? imageUrl
                                  : "assets/image/default_category.png",
                              width: 55,
                              height: 55,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            obj["category_name"] ?? "",
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Banners
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                children: [
                  _buildBannerItem("assets/image/ad_1.png"),
                  const SizedBox(width: 15),
                  _buildBannerItem("assets/image/ad_2.png"),
                ],
              ),
            ),

            // Doctors Near
            SectionRow(
              title: "Doctors near you (${widget.selectedDivision})",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllDivisionDoctorsScreen(
                      divisionId: null,
                      divisionName: widget.selectedDivision,
                      currentUserId: widget.currentUserId,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: 220,
              child: doctorArr.isEmpty
                  ? const Center(child: Text("No doctors found"))
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var obj = doctorArr[index];
                  return DoctorCell(
                    obj: obj,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorProfileScreen(
                            doctor: obj,
                            currentUserId: widget.currentUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) =>
                const SizedBox(width: 20),
                itemCount: doctorArr.length,
              ),
            ),

            // Medical Shops – Static for now
            SectionRow(
              title: "Medical Shop near you",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MedicalShopListScreen(currentUserId: widget.currentUserId,)),
                );
              },
            ),
            SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var obj = {
                    "id": 1,
                    "full_name": "World Mart Pharmacy",
                    "address":
                    "7 No., Mannan Steel Corporation, Dhaka - Mymensingh Rd",
                    "image_url": "assets/image/medical_shop.png",
                    "timing": "Sat-Fri (8:00am - 11:00pm)",
                    "contact": "01710-120768",
                  };

                  return ShopCell(
                    obj: obj,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MedicalShopProfileScreen(
                            shop: obj,
                            currentUserId: widget.currentUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) =>
                const SizedBox(width: 20),
                itemCount: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerItem(String imagePath) {
    return Container(
      width: 320,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}
