import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  List<dynamic> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ======================= LOAD MESSAGE HISTORY =======================
  Future<void> _loadHistory() async {
    setState(() => _loading = true);

    final rows = await _api.loadMessages(
      widget.currentUserId,
      widget.shopId,
    );

    // Do not reassign sender_type, backend already sends correctly
    _messages = (rows ?? []).map((msg) {
      msg["sender_type"] = msg["sender_type"];
      return msg;
    }).toList();

    setState(() => _loading = false);

    Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
  }

  // ======================= SEND TEXT MESSAGE =======================
  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    _msgCtrl.clear();

    // Local message instantly
    setState(() {
      _messages.add({
        "sender_id": widget.currentUserId,
        "receiver_id": widget.shopId,
        "sender_type": "user",
        "receiver_type": "shop",
        "message": text,
        "message_type": "text",
        "created_at": DateTime.now().toString(),
      });
    });

    _scrollToBottom();

    await _api.sendMessage({
      "sender_id": widget.currentUserId,
      "receiver_id": widget.shopId,
      "sender_type": "user",
      "receiver_type": "shop",
      "message_type": "text",
      "message": text,
    });

    setState(() => _sending = false);
  }

  // ======================= SEND IMAGE MESSAGE =======================
  Future<void> sendImage() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final bytes = await img.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Local preview
    setState(() {
      _messages.add({
        "sender_id": widget.currentUserId,
        "receiver_id": widget.shopId,
        "sender_type": "user",
        "receiver_type": "shop",
        "message_type": "image",
        "image_url": base64Image,
        "created_at": DateTime.now().toString(),
      });
    });

    _scrollToBottom();

    await _api.sendMessage({
      "sender_id": widget.currentUserId,
      "receiver_id": widget.shopId,
      "sender_type": "user",
      "receiver_type": "shop",
      "message_type": "image",
      "image_url": base64Image,
    });
  }

  // ======================= SCROLL TO END =======================
  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  // ======================= CHAT BUBBLE (FIXED) =======================
  Widget _chatBubble(dynamic m) {
    final bool isUser =
        m["sender_id"].toString() == widget.currentUserId.toString();

    final bool isImage = m["message_type"] == "image";

    // image_url or file_url (socket sends file_url)
    final String? imgData = m["image_url"] ?? m["file_url"];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xff647EE6)
              : const Color(0xffE8E8E8),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
            isUser ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
            isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: isImage && imgData != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(imgData),
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

  // ======================= BUILD UI =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(title: Text(widget.shopName)),

      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              controller: _scrollCtrl,
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemBuilder: (c, i) => _chatBubble(_messages[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 3),
              itemCount: _messages.length,
            ),
          ),

          // ================= INPUT AREA =================
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: sendImage,
                    child:
                    Icon(Icons.attach_file, color: TColor.primary, size: 25),
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
                              maxLines: null,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Type a message...",
                                hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.7)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: _sending ? null : _send,
                            child: _sending
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.send, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
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
