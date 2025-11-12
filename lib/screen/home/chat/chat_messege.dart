import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../common/color_extension.dart';
import '../../../services/api_service.dart';

class ChatMessageScreen extends StatefulWidget {
  final int doctorId;
  final int currentUserId;
  final String doctorName;
  final String? doctorAvatar;

  const ChatMessageScreen({
    super.key,
    required this.doctorId,
    required this.currentUserId,
    required this.doctorName,
    this.doctorAvatar,
  });

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
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
    _loadHistory();
  }

  void _initSocket() async {
    _socket = IO.io('http://192.168.175.243:3002', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.onConnect((_) {
      // bind user socket
      _socket!.emit('UpdateSocket', {
        'user_id': widget.currentUserId,
      });
      // join doctor room
      _socket!.emit('join_room', {
        'room_type': 'doctor',
        'user_id': widget.currentUserId,
        'doctor_id': widget.doctorId,
      });
    });

    _socket!.on('room_message', (data) {
      final d = (data is Map) ? data : Map<String, dynamic>.from(data);
      if (d['room_type'] == 'doctor' &&
          (d['doctor_id']?.toString() ?? '') == widget.doctorId.toString() &&
          (d['user_id']?.toString() ?? '') == widget.currentUserId.toString()) {
        setState(() {
          _messages.add({
            'sender': d['sender'],
            'message': d['message'],
            'created_at': d['created_at']?.toString() ?? '',
          });
        });
      }
    });

    _socket!.connect();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final rows = await _api.getChat(
      doctorId: widget.doctorId,
      userId: widget.currentUserId,
    );
    setState(() {
      _messages.clear();
      for (final m in rows) {
        _messages.add({
          'sender': m['sender'],
          'message': m['message'],
          'created_at': m['created_at']?.toString() ?? '',
        });
      }
      _loading = false;
    });
  }

  Future<void> _send() async {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() => _sending = true);

    // Emit real-time (server will persist and broadcast)
    _socket?.emit('send_message', {
      'room_type': 'doctor',
      'user_id': widget.currentUserId,
      'doctor_id': widget.doctorId,
      'sender': 'user',
      'message': txt,
    });

    _msgCtrl.clear();
    setState(() => _sending = false);
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }

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
          widget.doctorName,
          style: TextStyle(color: TColor.primaryText, fontSize: 14, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: _messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final m = _messages[index];
            final isSender = (m['sender']?.toString() ?? 'user') == 'user';
            return Row(
              mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSender)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: (widget.doctorAvatar ?? '').isNotEmpty
                          ? Image.network(widget.doctorAvatar!, width: 40, height: 40, fit: BoxFit.cover)
                          : Image.asset("assets/image/doctor_image.png", width: 40, height: 40),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: isSender ? const Color(0xffF5F5F5) : TColor.primary,
                    borderRadius: isSender
                        ? const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    )
                        : const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    m['message']?.toString() ?? '',
                    style: TextStyle(color: isSender ? TColor.primaryText : Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        color: TColor.primary,
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xff647EE6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file, color: Colors.white, size: 25),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: TextField(
                      controller: _msgCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type something ...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        contentPadding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sending ? null : _send,
                  icon: _sending
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.send, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
