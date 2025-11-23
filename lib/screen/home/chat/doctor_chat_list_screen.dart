import 'package:flutter/material.dart';
import 'package:medicare/services/api_service.dart';
import 'doctor_chat_screen.dart';

class DoctorChatListScreen extends StatefulWidget {
  final int doctorId; // logged-in doctor ID

  const DoctorChatListScreen({super.key, required this.doctorId});

  @override
  State<DoctorChatListScreen> createState() => _DoctorChatListScreenState();
}

class _DoctorChatListScreenState extends State<DoctorChatListScreen> {
  final ApiService api = ApiService();
  List<dynamic> list = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await api.getRecentChats(widget.doctorId);
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

          // ---------- OPEN CHAT ----------
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorChatScreen(
                  doctorId: partnerUserId,     // chat partner (USER)
                  currentUserId: widget.doctorId, // doctor = logged in
                  doctorName: name,
                  doctorAvatar: imageUrl,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
