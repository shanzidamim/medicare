import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../common/color_extension.dart';
import '../../../services/api_service.dart';

class DoctorChatScreen extends StatefulWidget {
  final int doctorId;
  final int currentUserId;
  final String doctorName;
  final String? doctorAvatar;

  const DoctorChatScreen({
    super.key,
    required this.doctorId,
    required this.currentUserId,
    required this.doctorName,
    this.doctorAvatar,
  });

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ImagePicker picker = ImagePicker();

  late IO.Socket _socket;

  List<dynamic> _messages = [];
  bool _loading = true;

  late String socketUrl;

  @override
  void initState() {
    super.initState();
    socketUrl = _api.baseHost; // use ApiService URL
    _connectSocket();
    _loadHistory();
  }

  // ================= SOCKET CONNECT =================
  void _connectSocket() {
    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      print("🔌 SOCKET CONNECTED (doctor chat)");

      _socket.emit("join_room", {
        "sender_id": widget.currentUserId,
        "receiver_id": widget.doctorId,
      });

      _socket.on("room_message", (data) {
        setState(() => _messages.add(data));
        _scrollToBottom();
      });
    });
  }

  // ================= LOAD HISTORY =================
  Future<void> _loadHistory() async {
    setState(() => _loading = true);

    final rows = await _api.loadMessages(
      widget.currentUserId,
      widget.doctorId,
    );

    setState(() {
      _messages = (rows ?? []).map((msg) {
        msg["sender_type"] ??= msg["sender_type"];
        return msg;
      }).toList();

      _loading = false;
    });

    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
  }

  // ================= SEND TEXT =================
  Future<void> _sendText() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _msgCtrl.clear();

    final localMsg = {
      "sender_id": widget.currentUserId,
      "sender_type": "user",
      "receiver_id": widget.doctorId,
      "receiver_type": "doctor",
      "message": text,
      "message_type": "text",
      "created_at": DateTime.now().toString(),
    };

    setState(() => _messages.add(localMsg));
    _scrollToBottom();

    _socket.emit("send_message", {
      "sender_id": widget.currentUserId,
      "receiver_id": widget.doctorId,
      "sender_type": "user",
      "receiver_type": "doctor",
      "message": text,
    });
  }

  // ================= SEND IMAGE =================
  Future<void> _sendImage() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final bytes = await img.readAsBytes();
    final base64Image = base64Encode(bytes);

    final localImg = {
      "sender_id": widget.currentUserId,
      "receiver_id": widget.doctorId,
      "message_type": "image",
      "file_url": base64Image,
      "created_at": DateTime.now().toString(),
    };

    setState(() => _messages.add(localImg));
    _scrollToBottom();

    _socket.emit("send_image", {
      "sender_id": widget.currentUserId,
      "receiver_id": widget.doctorId,
      "sender_type": "user",
      "receiver_type": "doctor",
      "image_url": base64Image,
    });
  }

  // ================= SCROLL TO BOTTOM =================
  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  // ================= CHAT BUBBLE (SAME STYLE AS SHOP) =================
  Widget _chatBubble(dynamic m) {
    final bool isUser =
        m["sender_id"].toString() == widget.currentUserId.toString();

    final bool isImage = m["message_type"] == "image";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xff647EE6) : const Color(0xffE8E8E8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(18),
          ),
        ),
        child: isImage
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(m["image_url"] ?? m["file_url"]),
            width: 180,
            fit: BoxFit.cover,
          ),
        )
            : Text(
          m["message"] ?? "",
          style: TextStyle(
            fontSize: 15,
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }



  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.doctorName)),

      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _chatBubble(_messages[i]),
            ),
          ),

          // INPUT BAR (BLUE BOX, SAME AS SHOP)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _sendImage,
                    child: Icon(Icons.attach_file,
                        size: 26, color: TColor.primary),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xff647EE6),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgCtrl,
                              decoration: const InputDecoration(
                                hintText: "Type a message...",
                                hintStyle: TextStyle(color: Colors.white70),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          GestureDetector(
                            onTap: _sendText,
                            child: const Icon(Icons.send, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
