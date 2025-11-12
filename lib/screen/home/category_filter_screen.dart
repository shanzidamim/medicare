import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../services/api_service.dart';
import 'doctor_list_screen.dart';

class CategoryFilterScreen extends StatefulWidget {
  final int currentUserId; // ✅ Added parameter

  const CategoryFilterScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
  final ApiService _api = ApiService();
  List divisions = [];
  List categories = [];

  int? selectedDivisionId;
  String? selectedDivisionName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final divs = await _api.getDivisions();
      final cats = await _api.getCategories();

      if (mounted) {
        setState(() {
          divisions = divs;
          categories = cats;
          if (divs.isNotEmpty) {
            selectedDivisionId = divs.first['id'];
            selectedDivisionName = divs.first['division_name'];
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error loading data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.primary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white, size: 25),
        ),
        title: Text(
          "Select Doctor Category",
          style: TextStyle(
            color: TColor.primaryTextW,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Division Dropdown =====
          Container(
            color: TColor.primary,
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedDivisionId,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.white),
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: divisions.map<DropdownMenuItem<int>>((div) {
                  return DropdownMenuItem<int>(
                    value: div['id'],
                    child: Text(div['division_name']),
                  );
                }).toList(),
                onChanged: (val) {
                  final sel = divisions.firstWhere(
                        (e) => e['id'] == val,
                    orElse: () => divisions.first,
                  );
                  setState(() {
                    selectedDivisionId = val;
                    selectedDivisionName = sel['division_name'];
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== Category Header =====
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              "Categories",
              style: TextStyle(
                color: TColor.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ===== Category List =====
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                var cat = categories[index];
                final imageUrl = cat['image_url'] ?? "";

                return GestureDetector(
                  onTap: () {
                    if (selectedDivisionId == null) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorsListScreen(
                          selectedDivisionId: selectedDivisionId!,
                          selectedDivisionName:
                          selectedDivisionName ?? 'Unknown',
                          selectedCategory: cat,
                          currentUserId: widget.currentUserId, // ✅ Added
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🩺 Category Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.startsWith('http')
                              ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                Image.asset(
                                  "assets/image/default_category.png",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                          )
                              : Image.asset(
                            imageUrl.isNotEmpty
                                ? imageUrl
                                : "assets/image/default_category.png",
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 🩵 Category Title
                        Text(
                          cat['category_name'] ?? "Unknown",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
              const SizedBox(width: 15),
              itemCount: categories.length,
            ),
          ),

          const SizedBox(height: 30),

          // ===== Footer Text =====
          Center(
            child: Text(
              "Select a category to view doctors in ${selectedDivisionName ?? ''}",
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
