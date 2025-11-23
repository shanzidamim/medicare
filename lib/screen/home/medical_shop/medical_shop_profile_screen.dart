import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/screen/home/chat/shop_chat_screen.dart';
import 'package:medicare/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../feedback_screen.dart';

class MedicalShopProfileScreen extends StatefulWidget {
  final Map<String, dynamic> shop;
  final int currentUserId;

  const MedicalShopProfileScreen({
    super.key,
    required this.shop,
    required this.currentUserId,
  });

  @override
  State<MedicalShopProfileScreen> createState() =>
      _MedicalShopProfileScreenState();
}

class _MedicalShopProfileScreenState extends State<MedicalShopProfileScreen> {
  final ApiService _api = ApiService();

  int _feedbackCount = 0;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  Future<void> _loadShopData() async {
    final id = widget.shop['id'] as int?;
    if (id == null) return;

    try {
      final info = await _api.getShopProfile(id);  // ⭐ create endpoint
      setState(() {
        _rating = double.tryParse((info['rating'] ?? '0').toString()) ?? 0.0;
        _feedbackCount =
            int.tryParse((info['feedback_count'] ?? '0').toString()) ?? 0;
      });
    } catch (_) {}
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

    final fullImage = imageUrl.startsWith("http")
        ? imageUrl
        : "${ApiService().baseHost}/$imageUrl";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          _topImage(imageUrl),
          Container(
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.only(left: 20, right: 20, top: 160, bottom: 20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      "$address\n$division",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: TColor.secondaryText),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ⭐ Shop Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingStars(
                        value: _rating.toDouble(),
                        starCount: 5,
                        starSize: 16,
                        valueLabelVisibility: false,
                        starColor: Color(0xffDE6732),
                        starOffColor: Colors.grey,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "($_feedbackCount)",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),



                  const Divider(height: 25),

                  _info("Timings", timing),
                  _info("Services", "Home Delivery"),
                  _info("Payment Modes", "Cash"),

                  const Divider(height: 25),

                  // ⭐⭐⭐ FEEDBACK BUTTON ONLY ⭐⭐⭐
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FeedbackScreen(
                              itemId: widget.shop['id'],
                              itemType: "shop",
                              currentUserId: widget.currentUserId,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Feedback (${_feedbackCount})",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),


                  const Divider(height: 25),

                  // ⭐ Contact Section
                  const Text("Contact",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.phone, color: TColor.primary),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(
                            contact,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          )),
                      _iconBtn(Icons.phone, TColor.green, () {
                        launchUrl(Uri.parse("tel:$contact"));
                      }),
                      const SizedBox(width: 6),
                      _iconBtn(Icons.message, Colors.orange, () {
                        _openChat(
                          widget.shop['id'] as int,
                          name,
                        );
                      }),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ***** Helping Widgets *****

  Widget _topImage(String? url) {
    if (url == null || url.isEmpty) {
      return Image.asset("assets/image/medical_shop.png",
          width: double.infinity, height: 180, fit: BoxFit.cover);
    }
    return Image.network(url,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          "assets/image/medical_shop.png",
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ));
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: TColor.unselect)),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 15, color: Colors.white)),
    );
  }

  void _openChat(int shopId, String shopName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopChatMessageScreen(
          shopId: shopId,
          shopName: shopName,
          currentUserId: widget.currentUserId,
          shopAvatar: widget.shop['image_url'],
        ),
      ),
    );
  }
}
