import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/services/api_service.dart';

import 'appointment_booking.dart';
import 'chat/chat_messege.dart';
import 'feedback_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final int currentUserId;

  const DoctorProfileScreen({
    super.key,
    required this.doctor,
    required this.currentUserId,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final ApiService _api = ApiService();
  int _feedbackCount = 0;
  double _rating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final id = widget.doctor['id'] as int?;
    if (id == null) return;

    try {
      final profile = await _api.getDoctorProfile(id);

      setState(() {
        _rating = double.tryParse((profile['rating'] ?? '0').toString()) ?? 0.0;
        _feedbackCount =
            int.tryParse((profile['feedback_count'] ?? '0').toString()) ?? 0;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.doctor;

    final doctorId = d['id'] ?? 0;
    final name = d['full_name'] ?? "Unknown Doctor";
    final degrees = d['degrees'] ?? "";
    final specialty = d['specialty_detail'] ?? "";
    final experience = d['years_experience']?.toString() ?? "0";
    final visitDays = d['visit_days'] ?? "Not available";
    final visitingTime = d['visiting_time'] ?? "Not available";
    final chamber = d['clinic_or_hospital'] ?? "Not specified";
    final address = d['address'] ?? "Not provided";
    final contact = d['contact']?.toString() ?? "";
    final imageUrl = d['image_url']?.toString() ?? "";

    final fullImageUrl = imageUrl.isNotEmpty
        ? (imageUrl.startsWith("http")
        ? imageUrl
        : "${ApiService().baseHost}/$imageUrl")
        : "";

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 25),
          ),
          title: Text(
            "Doctor's Profile",
            style: TextStyle(
              color: TColor.primaryTextW,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // TOP SECTION
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: TColor.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),

                  // Doctor Info Card
                  Container(
                    margin: const EdgeInsets.only(top: 80, left: 40, right: 40),
                    padding: const EdgeInsets.only(top: 80, bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(specialty,
                            style: TextStyle(
                                color: TColor.secondaryText, fontSize: 14)),
                        Text(degrees,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: TColor.secondaryText, fontSize: 13)),
                        const SizedBox(height: 6),

// ⭐⭐ RESTORED RATING SECTION ⭐⭐
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RatingStars(
                              value: _rating.toDouble(),
                              maxValue: 5,
                              starCount: 5,
                              starSize: 16,
                              valueLabelVisibility: false,
                              starColor: Color(0xffDE6732),
                              starOffColor: Colors.grey,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "($_feedbackCount)",
                              style: TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),


                        const SizedBox(height: 6),

// Experience
                        Text("$experience Years Experience",
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 13)),

                      ],
                    ),
                  ),

                  // Doctor Image
                  Positioned(
                    top: 20,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: fullImageUrl.isNotEmpty
                          ? Image.network(fullImageUrl, fit: BoxFit.contain)
                          : Image.asset("assets/image/default_doctor.png"),
                    ),
                  ),
                ],
              ),

              // DETAILS SECTION
              Container(
                margin: const EdgeInsets.all(20),
                padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _info("Visit Days", visitDays),
                    _info("Visiting Time", visitingTime),
                    _info("Chamber", chamber),
                    const Divider(color: Colors.black26, height: 15),

                    // ⭐⭐⭐ FEEDBACK BUTTON ONLY ⭐⭐⭐
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FeedbackScreen(
                              itemId: doctorId,
                              itemType: "doctor",
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

                    const SizedBox(height: 15),

                    // ⭐⭐⭐ CHAT & BOOK BUTTONS ⭐⭐⭐
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _openChat(doctorId, name),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: TColor.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text("Chat",
                                style: TextStyle(color: TColor.primary)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _openBooking(doctorId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColor.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Book"),
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.black26, height: 25),

                    _info("Address", address),
                    const Divider(color: Colors.black26, height: 25),

                    const Text("Contact",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black)),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.phone, size: 22, color: TColor.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            contact.isEmpty ? "Not available" : contact,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ),
                        _smallIconBtn(Icons.phone, TColor.green, () {
                          if (contact.isNotEmpty) {
                            launchUrl(Uri.parse('tel:$contact'));
                          }
                        }),
                        const SizedBox(width: 6),
                        _smallIconBtn(Icons.message, const Color(0xffF8A370),
                                () => _openChat(doctorId, name)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Info Row
  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(color: TColor.unselect, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _smallIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }

  void _openChat(int doctorId, String doctorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatMessageScreen(
          doctorId: doctorId,
          doctorName: doctorName,
          currentUserId: widget.currentUserId,
          doctorAvatar: widget.doctor['image_url']?.toString(),
        ),
      ),
    );
  }

  void _openBooking(int doctorId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentBookingScreen(
          doctorId: doctorId,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }
}
