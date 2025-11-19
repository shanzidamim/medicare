import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../../common/color_extension.dart';
import '../../services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  final int itemId;
  final String itemType; // "doctor" or "shop"
  final int currentUserId;

  const FeedbackScreen({
    super.key,
    required this.itemId,
    required this.itemType,
    required this.currentUserId,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _ctrl = TextEditingController();

  List<dynamic> feedbackList = [];
  bool loading = true;
  double givenRating = 0.0;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    loadFeedbacks();
  }

  Future<void> loadFeedbacks() async {
    setState(() => loading = true);

    if (widget.itemType == "doctor") {
      feedbackList = await _api.getDoctorFeedbacks(widget.itemId);
    } else {
      feedbackList = await _api.getShopFeedbacks(widget.itemId);
    }

    setState(() => loading = false);
  }

  Future<void> submitFeedback() async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty || givenRating == 0) return;

    setState(() => sending = true);

    bool ok = false;

    if (widget.itemType == "doctor") {
      ok = await _api.addDoctorFeedback(
        doctorId: widget.itemId,
        userId: widget.currentUserId,
        message: txt,
        rating: givenRating,
      );
    } else {
      ok = await _api.addShopFeedback(
        shopId: widget.itemId,
        userId: widget.currentUserId,
        message: txt,
        rating: givenRating,
      );
    }

    if (ok) {
      feedbackList.insert(0, {
        'first_name': "You",
        'rating': givenRating,
        'message': txt,
        'created_at': 'Just now'
      });

      _ctrl.clear();
      givenRating = 0;
    }

    setState(() => sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ⭐ fixes input going down
      appBar: AppBar(title: const Text("Feedback")),
      body: Column(
        children: [
          // ⭐ FEEDBACK LIST
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              padding: const EdgeInsets.all(15),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (_, i) {
                final f = feedbackList[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 3)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f['first_name'] ?? 'User',
                        style:
                        const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      RatingStars(
                        value: double.tryParse(
                            f['rating']?.toString() ?? "0") ??
                            0.0,
                        starCount: 5,
                        starSize: 16,
                        valueLabelVisibility: false,
                        starColor: const Color(0xffDE6732),
                      ),
                      const SizedBox(height: 6),
                      Text(f['message'] ?? ""),
                      const SizedBox(height: 4),
                      Text(
                        f['created_at'] ?? "",
                        style: TextStyle(
                            fontSize: 12, color: TColor.secondaryText),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: feedbackList.length,
            ),
          ),

          // ⭐ ⭐ FIXED BOTTOM INPUT ⭐ ⭐
          SafeArea(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xffF4F4F4),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingStars(
                    value: givenRating,
                    starCount: 5,
                    starSize: 28,
                    valueLabelVisibility: false,
                    starColor: const Color(0xffDE6732),
                    onValueChanged: (v) {
                      setState(() => givenRating = v);
                    },
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          decoration: const InputDecoration(
                            hintText: "Write feedback...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: sending ? null : submitFeedback,
                        child: sending
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text("Send"),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
