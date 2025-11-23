import 'package:flutter/material.dart';
import 'package:medicare/services/api_service.dart';
import 'shop_chat_screen.dart';

class ShopChatListScreen extends StatefulWidget {
  final int shopId; // logged in shop ID

  const ShopChatListScreen({super.key, required this.shopId});

  @override
  State<ShopChatListScreen> createState() => _ShopChatListScreenState();
}

class _ShopChatListScreenState extends State<ShopChatListScreen> {
  final ApiService api = ApiService();
  List<dynamic> list = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await api.getRecentChats(widget.shopId);
    setState(() {
      list = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (list.isEmpty) {
      return const Center(
        child: Text("No chats found", style: TextStyle(fontSize: 16)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(15),
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final c = list[i];

        final name = c["name"] ?? "Unknown User";
        final imageUrl = c["image_url"] ?? "";
        final partnerUserId = int.tryParse(c["partner_id"].toString()) ?? 0;

        final lastMsg = c["last_message"] ?? "";
        final createdAt = c["created_at"].toString();
        final time = createdAt.length >= 16 ? createdAt.substring(11, 16) : "";

        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : const AssetImage("assets/image/icons8-user-100.png")
            as ImageProvider,
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(time, style: const TextStyle(color: Colors.grey)),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShopChatMessageScreen(
                  currentUserId: widget.shopId, // shop = logged in
                  shopId: partnerUserId,        // user = chat partner
                  shopName: name,
                  shopAvatar: imageUrl,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
