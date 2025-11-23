import 'package:flutter/material.dart';
import 'package:medicare/services/api_service.dart';

import 'doctor_chat_screen.dart';
import 'shop_chat_screen.dart';

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

  // ----------- CHECK DOCTOR OR SHOP ----------
  Future<String> detectPartnerType(int id) async {
    try {
      final d = await api.getDoctorProfile(id);
      if (d.isNotEmpty) return "doctor";

      final s = await api.getShopProfile(id);
      if (s.isNotEmpty) return "shop";
    } catch (_) {}

    return "user";
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

        final String name = c["name"]?.toString() ?? "Unknown";
        final String lastMessage = c["last_message"]?.toString() ?? "";
        final String imageUrl = c["image_url"]?.toString() ?? "";
        final int partnerId = int.tryParse(c["partner_id"]?.toString() ?? "") ?? 0;

        final String createdAt = c["created_at"]?.toString() ?? "";
        String timeText = createdAt.length >= 16 ? createdAt.substring(11, 16) : "";

        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : const AssetImage("assets/image/icons8-user-100.png") as ImageProvider,
          ),

          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(timeText, style: const TextStyle(fontSize: 12, color: Colors.grey)),

          onTap: () async {
            String type = await detectPartnerType(partnerId);

            if (type == "doctor") {
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
            } else if (type == "shop") {
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
