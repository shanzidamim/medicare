import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../common/color_extension.dart';
import '../../../services/api_service.dart';

class ShopChatMessageScreen extends StatefulWidget {
  final int currentUserId;
  final int shopId;
  final String shopName;
  final String? shopAvatar;

  const ShopChatMessageScreen({
    super.key,
    required this.currentUserId,
    required this.shopId,
    required this.shopName,
    this.shopAvatar,
  });

  @override
  State<ShopChatMessageScreen> createState() => _ShopChatMessageScreenState();
}

class _ShopChatMessageScreenState extends State<ShopChatMessageScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final ImagePicker picker = ImagePicker();

  late IO.Socket _socket;
  List<dynamic> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _loadHistory();
  }

  // ================= SOCKET CONNECT =================
  void _connectSocket() {
    final socketUrl = _api.baseHost;

    _socket = IO.io(
      socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .enableForceNew()
          .setPath("/socket.io/")
          .build(),
    );

    _socket.onConnect((_) {
      print("🟢 SHOP SOCKET CONNECTED");

      _socket.emit("join_room", {
        "sender_id": widget.currentUserId,
        "receiver_id": widget.shopId,
      });
    });

    _socket.on("room_message", (data) {
      setState(() => _messages.add(data));
      _scrollToBottom();
    });
  }

  // ================= LOAD HISTORY =================
  Future<void> _loadHistory() async {
    setState(() => _loading = true);

    final rows = await _api.loadMessages(
      widget.currentUserId,
      widget.shopId,
    );

    setState(() {
      _messages = rows ?? [];
      _loading = false;
    });

    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
  }

  // ================= SEND TEXT =================
  void _sendText() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _msgCtrl.clear();

    final localMsg = {
      "sender_id": widget.currentUserId,
      "receiver_id": widget.shopId,
      "message": text,
      "message_type": "text",
      "created_at": DateTime.now().toString(),
    };

    setState(() => _messages.add(localMsg));
    _scrollToBottom();

    _socket.emit("send_message", {
      "sender_id": widget.currentUserId,
      "receiver_id": widget.shopId,
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
      "receiver_id": widget.shopId,
      "message_type": "image",
      "image_url": base64Image,
      "created_at": DateTime.now().toString(),
    };

    setState(() => _messages.add(localImg));
    _scrollToBottom();

    _socket.emit("send_image", {
      "sender_id": widget.currentUserId,
      "receiver_id": widget.shopId,
      "image_url": base64Image,
    });
  }

  // ================= SCROLL TO BOTTOM =================
  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // ================= CHAT BUBBLE =================
  Widget _chatBubble(dynamic m) {
    final bool isMine =
        m["sender_id"].toString() == widget.currentUserId.toString();

    final bool isImage = m["message_type"] == "image";

    String? raw = m["image_url"] ?? m["file_url"];

    // ⭐ FIX: ensure path starts with /
    if (raw != null && !raw.startsWith("http") && !raw.startsWith("/")) {
      raw = "/$raw";
    }

    Widget content;

    if (isImage && raw != null) {
      final bool isBase64 = raw.length > 150;

      if (isBase64) {
        content = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(raw),
            width: 180,
            fit: BoxFit.cover,
          ),
        );
      } else {
        final String url = _api.fixImage(raw);
        content = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: 180,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      content = Text(
        m["message"] ?? "",
        style: TextStyle(
          fontSize: 15,
          color: isMine ? Colors.white : Colors.black,
        ),
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xff647EE6) : const Color(0xffE8E8E8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMine ? const Radius.circular(18) : Radius.zero,
            bottomRight: isMine ? Radius.zero : const Radius.circular(18),
          ),
        ),
        child: content,
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.shopName)),

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

          // INPUT
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
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.white70),
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
