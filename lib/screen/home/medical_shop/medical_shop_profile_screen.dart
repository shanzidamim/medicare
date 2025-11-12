import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/services/api_service.dart';

class MedicalShopProfileScreen extends StatefulWidget {
  final Map<String, dynamic> shop;
  final int currentUserId;

  const MedicalShopProfileScreen({
    super.key,
    required this.shop,
    required this.currentUserId,
  });

  @override
  State<MedicalShopProfileScreen> createState() => _MedicalShopProfileScreenState();
}

class _MedicalShopProfileScreenState extends State<MedicalShopProfileScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _feedbacks = [];
  final TextEditingController _fbCtrl = TextEditingController();
  bool _loadingFb = true;
  bool _addingFb = false;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() => _loadingFb = true);
    final id = (widget.shop['id'] as int?) ?? 0;
    _feedbacks = id == 0 ? [] : await _api.getShopFeedbacks(id);
    setState(() => _loadingFb = false);
  }

  Future<void> _addFeedback() async {
    final txt = _fbCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() => _addingFb = true);
    final ok = await _api.addShopFeedback(
      shopId: widget.shop['id'] as int,
      userId: widget.currentUserId,
      message: txt,
    );
    if (ok) {
      _fbCtrl.clear();
      _loadFeedbacks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit feedback')),
      );
    }
    setState(() => _addingFb = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.shop;
    final name = s['full_name'] ?? "Medical Shop";
    final address = s['address'] ?? "Not provided";
    final timing = s['timing'] ?? "Sat–Fri (08:00 AM – 11:00 PM)";
    final contact = s['contact']?.toString() ?? "N/A";
    final division = s['division'] ?? "Dhaka";
    final imageUrl = s['image_url'] ?? "";
    final rating = double.tryParse(s['rating']?.toString() ?? "4.0") ?? 4.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset("assets/image/medical_shop.png", width: double.infinity),
          Container(
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.only(left: 20, right: 20, top: 160, bottom: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 SHOP NAME
                    Center(
                      child: Text(name,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        "$address\n$division",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TColor.secondaryText, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingStars(
                          value: rating,
                          onValueChanged: (_) {},
                          starCount: 5,
                          starSize: 16,
                          valueLabelVisibility: false,
                          starOffColor: const Color(0xff7c7c7c),
                          starColor: const Color(0xffDE6732),
                        ),
                        const SizedBox(width: 5),
                        Text("(${rating.toStringAsFixed(1)})",
                            style: TextStyle(color: TColor.secondaryText, fontSize: 12))
                      ],
                    ),
                    const Divider(color: Colors.black26),

                    _infoRow("Timings", timing),
                    const Divider(color: Colors.black26),
                    _infoRow("Services", "Home Delivery"),
                    const Divider(color: Colors.black26),
                    _infoRow("Payment Modes", "Cash"),
                    const Divider(color: Colors.black26),

                    // 🔹 FEEDBACK SECTION
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Feedback",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          if (_loadingFb)
                            const Center(child: CircularProgressIndicator())
                          else if (_feedbacks.isEmpty)
                            Text("No feedback yet.",
                                style: TextStyle(color: TColor.unselect, fontSize: 13))
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (_, i) {
                                final f = _feedbacks[i];
                                return Text("• ${f['message'] ?? ''}",
                                    style: TextStyle(color: TColor.primaryText));
                              },
                              separatorBuilder: (_, __) => const SizedBox(height: 4),
                              itemCount: _feedbacks.length,
                            ),
                          const SizedBox(height: 10),

                          // feedback input
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xffEDEDED),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: TextField(
                                      controller: _fbCtrl,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Write feedback…",
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _addingFb ? null : _addFeedback,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: TColor.primary,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: _addingFb
                                        ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white))
                                        : const Text("Send",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black26),

                    // 🔹 CONTACT INFO
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Contact",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 20, color: TColor.primary),
                              const SizedBox(width: 8),
                              Text(contact,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: TColor.unselect, fontSize: 13)),
        ],
      ),
    );
  }
}
