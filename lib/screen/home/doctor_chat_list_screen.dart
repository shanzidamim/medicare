import 'package:flutter/material.dart';
import 'package:medicare/services/api_service.dart';
import 'chat/doctor_chat_screen.dart';

class DoctorChatListScreen extends StatefulWidget {
  final int doctorId;

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
    final data = await api.getRecentChats(widget.doctorId); // doctorId = current userId
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
        child: Text("No chats found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
        final userId = int.tryParse(c["partner_id"].toString()) ?? 0;
        final lastMessage = c["message"] ?? "";
        final time = c["created_at"].toString().length > 16
            ? c["created_at"].toString().substring(11, 16)
            : "";

        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : const AssetImage("assets/image/icons8-user-100.png") as ImageProvider,
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorChatScreen(
                  doctorId: widget.doctorId,
                  currentUserId: userId,
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
