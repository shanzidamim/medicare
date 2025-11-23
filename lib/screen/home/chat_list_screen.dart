import 'package:flutter/material.dart';
import 'package:medicare/services/api_service.dart';

import 'chat/doctor_chat_screen.dart';
import 'medical_shop/shop_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final int userId;

  const ChatListScreen({super.key, required this.userId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiService api = ApiService();

  List<dynamic> list = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await api.getRecentChats(widget.userId);

    setState(() {
      list = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(
        child: Text(
          "No chats yet",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(15),
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final c = list[i];

        // ---------- FIELDS COMING FROM API ----------
        final String name = c["name"]?.toString() ?? "Unknown";
        final String lastMessage = c["message"]?.toString() ?? "";
        final String imageUrl = c["image_url"]?.toString() ?? "";
        final String partnerType = c["partner_type"]?.toString() ?? "";
        final int partnerId = int.tryParse(
          c["partner_id"]?.toString() ?? "",
        ) ??
            0;
        final String createdAt = c["created_at"]?.toString() ?? "";

        // Time only (HH:mm) – safe substring
        String timeText = "";
        if (createdAt.length >= 16) {
          timeText = createdAt.substring(11, 16);
        }

        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: (imageUrl.isNotEmpty)
                ? NetworkImage(imageUrl)
                : const AssetImage("assets/image/icons8-user-100.png")
            as ImageProvider,
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            timeText,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),

          // ----------- OPEN CHAT BY PARTNER TYPE ----------
          onTap: () {
            if (partnerType == "doctor") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorChatScreen(
                    doctorId: partnerId,
                    currentUserId: widget.userId,
                    doctorName: name,
                    doctorAvatar: imageUrl,
                  ),
                ),
              );
            } else if (partnerType == "shop") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShopChatMessageScreen(
                    currentUserId: widget.userId,
                    shopId: partnerId,
                    shopName: name,
                    shopAvatar: imageUrl,
                  ),
                ),
              );
            } else {
              // future: user-to-user chat etc.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Unknown chat type")),
              );
            }
          },
        );
      },
    );
  }
}
