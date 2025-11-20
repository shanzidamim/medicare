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
  List<dynamic> shopArr = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  // ----------------------------------------------------------
  // INITIAL LOAD
  // ----------------------------------------------------------
  Future<void> loadInitialData() async {
    try {
      final categories = await apiService.getCategories();

      await loadDoctors(widget.selectedDivision);
      await loadShops(widget.selectedDivision);

      if (mounted) {
        setState(() {
          categoryArr = categories;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Home load error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ----------------------------------------------------------
  // LOAD DOCTORS
  // ----------------------------------------------------------
  Future<void> loadDoctors(String divisionName) async {
    try {
      final divisions = await apiService.getDivisions();
      if (divisions.isEmpty) return;

      final selected = divisions.firstWhere(
            (d) => d['division_name']
            .toString()
            .toLowerCase()
            .contains(divisionName.toLowerCase()),
        orElse: () => divisions.first,
      );

      final doctors = await apiService.getDoctorsByDivision(selected['id']);

      if (mounted) setState(() => doctorArr = doctors);
    } catch (e) {
      debugPrint("Load doctors error: $e");
    }
  }

  // ----------------------------------------------------------
  // LOAD SHOPS — Uses division_name and fixes image/full_name
  // ----------------------------------------------------------
  Future<void> loadShops(String divisionName) async {
    try {
      final divisions = await apiService.getDivisions();
      if (divisions.isEmpty) return;

      final selected = divisions.firstWhere(
            (d) => d['division_name']
            .toString()
            .toLowerCase()
            .contains(divisionName.toLowerCase()),
        orElse: () => divisions.first,
      );

      // 🔥 Backend expects division_id
      final shops = await apiService.getMedicalShopsByDivision(
        selected["id"].toString(),   // FIXED
      );

      final fixedShops = shops.map((s) {
        final img = (s["image_url"] ?? "").toString();
        final fullImage =
        img.startsWith("http") ? img : "${apiService.baseHost}/$img";

        return {
          ...s,
          "full_name": s["full_name"] ?? "Unknown Shop",
          "image_url": img.isEmpty ? "" : fullImage,
        };
      }).toList();

      if (mounted) setState(() => shopArr = fixedShops);
    } catch (e) {
      debugPrint("Load shops error: $e");
    }
  }


  @override
  void didUpdateWidget(HomeTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDivision != widget.selectedDivision) {
      loadDoctors(widget.selectedDivision);
      loadShops(widget.selectedDivision);
    }
  }

  // ----------------------------------------------------------
  // UI BUILD
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------------
            // CATEGORIES SECTION (STATIC IMAGE)
            // ----------------------------------------------------------
            Padding(
              padding:
              const EdgeInsets.only(left: 20, top: 15, bottom: 5),
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
                separatorBuilder: (_, __) =>
                const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  var obj = categoryArr[index];

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
                            child: Image.asset(
                              "assets/image/default_category.png",
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

            // ----------------------------------------------------------
            // BANNERS
            // ----------------------------------------------------------
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

            // ----------------------------------------------------------
            // DOCTORS SECTION
            // ----------------------------------------------------------
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

                  final img = obj["image_url"]?.toString() ?? "";
                  final fullImg = img.startsWith("http")
                      ? img
                      : "${apiService.baseHost}/$img";

                  return DoctorCell(
                    obj: {...obj, "image_url": fullImg},
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorProfileScreen(
                            doctor: obj,
                            currentUserId:
                            widget.currentUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) =>
                const SizedBox(width: 20),
                itemCount: doctorArr.length,
              ),
            ),

            // ----------------------------------------------------------
            // SHOPS SECTION
            // ----------------------------------------------------------
            SectionRow(
              title: "Medical Shop near you",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedicalShopListScreen(
                      currentUserId: widget.currentUserId,
                      divisionName: widget.selectedDivision,
                    ),
                  ),
                );
              },
            ),

            SizedBox(
              height: 260,
              child: shopArr.isEmpty
                  ? const Center(child: Text("No shops found"))
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var obj = shopArr[index];

                  return ShopCell(
                    obj: obj,
                    onPressed: () {
                      Navigator.push(
                        context,
                          MaterialPageRoute(
                          builder: (_) => MedicalShopProfileScreen(
                        shop: Map<String, dynamic>.from(obj),
                        currentUserId: widget.currentUserId,
                      ),
                          ),
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) =>
                const SizedBox(width: 20),
                itemCount: shopArr.length,
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
          BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}
