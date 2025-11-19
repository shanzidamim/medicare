import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;

  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _loadChatHistory();
  }

  // ---------------- SOCKET INITIALIZATION ----------------
  void _initSocket() async {
    _socket = IO.io(_api.baseHost, {
      "transports": ["websocket"],
      "autoConnect": false,
    });

    _socket!.onConnect((_) {
      // bind user socket
      _socket!.emit("UpdateSocket", {
        "user_id": widget.currentUserId,
      });

      // JOIN SHOP ROOM
      _socket!.emit("join_room", {
        "room_type": "shop",
        "user_id": widget.currentUserId,
        "shop_id": widget.shopId,
      });
    });

    // LISTEN MESSAGES
    _socket!.on("room_message", (data) {
      final d = Map<String, dynamic>.from(data);

      if (d["room_type"] == "shop" &&
          d["shop_id"]?.toString() == widget.shopId.toString() &&
          d["user_id"]?.toString() == widget.currentUserId.toString()) {
        setState(() {
          _messages.add({
            "sender": d["sender"],
            "message": d["message"],
            "created_at": d["created_at"],
          });
        });
      }
    });

    _socket!.connect();
  }

  // ---------------- LOAD HISTORY ----------------
  Future<void> _loadChatHistory() async {
    setState(() => _loading = true);

    final rows = await _api.getChat(
      doctorId: widget.shopId, // YOU ARE USING SAME ENDPOINT → doctorId works as shopId
      userId: widget.currentUserId,
    );

    setState(() {
      _messages.clear();
      for (var m in rows) {
        _messages.add({
          "sender": m["sender"],
          "message": m["message"],
          "created_at": m["created_at"],
        });
      }
      _loading = false;
    });
  }

  // ---------------- SEND MESSAGE ----------------
  Future<void> _sendMessage() async {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;

    setState(() => _sending = true);

    final payload = {
      "room_type": "shop",
      "user_id": widget.currentUserId,
      "shop_id": widget.shopId,
      "sender": "user",
      "message": txt,
    };

    _socket?.emit("send_message", payload);

    _msgCtrl.clear();

    setState(() => _sending = false);
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: TColor.primaryText),
        ),
        title: Text(
          widget.shopName,
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),

      // ---------------- MESSAGE LIST ----------------
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: _messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) {
            final msg = _messages[index];
            final isSender = msg["sender"] == "user";

            return Row(
              mainAxisAlignment: isSender
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!isSender)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: widget.shopAvatar != null
                        ? Image.network(widget.shopAvatar!,
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover)
                        : Image.asset(
                      "assets/image/medical_shop.png",
                      width: 35,
                      height: 35,
                    ),
                  ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  constraints: BoxConstraints(
                    maxWidth:
                    MediaQuery.of(context).size.width * 0.65,
                  ),
                  decoration: BoxDecoration(
                    color: isSender
                        ? const Color(0xffF5F5F5)
                        : TColor.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    msg["message"],
                    style: TextStyle(
                        color:
                        isSender ? Colors.black : Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      // ---------------- INPUT BOX ----------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: TColor.primary,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xff647EE6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    maxLines: null,
                    style:
                    const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Type message…",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sending ? null : _sendMessage,
                  icon: _sending
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.send,
                      color: Colors.white, size: 22),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
