import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/services/api_service.dart';
import 'appointment_booking.dart';
import 'chat/chat_messege.dart';

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
    final id = (widget.doctor['id'] as int?) ?? 0;
    _feedbacks = id == 0 ? [] : await _api.getDoctorFeedbacks(id);
    setState(() => _loadingFb = false);
  }

  Future<void> _addFeedback() async {
    final txt = _fbCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() => _addingFb = true);
    final ok = await _api.addDoctorFeedback(
      doctorId: widget.doctor['id'] as int,
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
    final d = widget.doctor;
    final name = d['full_name'] ?? "Unknown Doctor";
    final degrees = d['degrees'] ?? "";
    final specialty = d['specialty_detail'] ?? "";
    final experience = d['years_experience']?.toString() ?? "0";
    final visitDays = d['visit_days'] ?? "Not available";
    final visitingTime = d['visiting_time'] ?? "Not available";
    final chamber = d['clinic_or_hospital'] ?? "Not specified";
    final address = d['address'] ?? "Not provided";
    final contact = d['contact']?.toString() ?? "";
    final imageUrl = d['image_url'] ?? "";
    final rating = double.tryParse(d['rating']?.toString() ?? "4.0") ?? 4.0;
    final doctorId = (d['id'] as int?) ?? 0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 25),
          ),
          title: Text("Doctor's Profile",
            style: TextStyle(color: TColor.primaryTextW, fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // TOP
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: TColor.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 80, left: 40, right: 40),
                    padding: const EdgeInsets.only(top: 80, bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Text(name, textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(specialty, style: TextStyle(color: TColor.secondaryText, fontSize: 14)),
                        Text(degrees, textAlign: TextAlign.center, style: TextStyle(color: TColor.secondaryText, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RatingStars(
                              value: rating, starCount: 5, starSize: 14,
                              starOffColor: TColor.placeholder, starColor: const Color(0xffDE6732),
                              valueLabelVisibility: false, onValueChanged: (_) {},
                            ),
                            const SizedBox(width: 4),
                            Text("(${rating.toStringAsFixed(1)})",
                                style: TextStyle(color: TColor.secondaryText, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text("$experience Years Experience",
                            style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    child: Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
                      ),
                      child: imageUrl.toString().isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset("assets/image/default_doctor.png"))
                          : Image.asset("assets/image/default_doctor.png"),
                    ),
                  ),
                ],
              ),

              // DETAILS / FEEDBACK
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _info("Visit Days", visitDays),
                    _info("Visiting Time", visitingTime),
                    _info("Chamber", chamber),

                    const SizedBox(height: 6),
                    const Divider(color: Colors.black26, height: 1),
                    const SizedBox(height: 6),

                    const Text("Feedback", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),

                    if (_loadingFb)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 6),
                          child: Center(child: CircularProgressIndicator()))
                    else if (_feedbacks.isEmpty)
                      Padding(padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text("No feedback yet.", style: TextStyle(color: TColor.unselect)))
                    else
                      ListView.separated(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) {
                          final f = _feedbacks[i];
                          return Text("• ${f['message'] ?? ''}",
                              style: TextStyle(color: TColor.primaryText));
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemCount: _feedbacks.length,
                      ),

                    const SizedBox(height: 10),

                    // feedback input + actions
                    Container(
                      height: 50,
                      decoration: BoxDecoration(color: const Color(0xffEDEDED), borderRadius: BorderRadius.circular(25)),
                      child: Row(children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: TextField(
                              controller: _fbCtrl,
                              decoration: const InputDecoration(border: InputBorder.none, hintText: "Write feedback…"),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _addingFb ? null : _addFeedback,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(color: TColor.primary, borderRadius: BorderRadius.circular(25)),
                            child: _addingFb
                                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("Send", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _openChat(doctorId, name),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: TColor.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text("Chat", style: TextStyle(color: TColor.primary)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _openBooking(doctorId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColor.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Book"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    const Divider(color: Colors.black26, height: 1),
                    _info("Address", address),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.black26, height: 1),
                    const SizedBox(height: 10),
                    const Text("Contact", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 22, color: TColor.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            contact.isEmpty ? "Not available" : contact,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                        ),
                        _smallIconBtn(Icons.phone, TColor.green, () {
                          if (contact.isNotEmpty) {
                            launchUrl(Uri.parse('tel:$contact'));
                          }
                        }),
                        const SizedBox(width: 6),
                        _smallIconBtn(Icons.message, const Color(0xffF8A370), () {
                          _openChat(doctorId, name);
                        }),
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

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: TColor.unselect, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _smallIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}
