import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/domain/providers/auth_provider.dart';
import '../../domain/providers/session_provider.dart';
import '../../data/models/session_model.dart';
import 'session_timer_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final SessionModel session;
  const ChatScreen({super.key, required this.session});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).connectAndJoin(widget.session);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // ListView is reversed
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      ref.read(sessionProvider.notifier).sendMessage(text, 'text');
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _onTyping(String value) {
    if (value.isNotEmpty) {
      ref.read(sessionProvider.notifier).sendTyping();
    }
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Logic for uploading image and sending image message URL goes here
      // Normally upload to S3 first, then get URL and send as type 'image'
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengunggah gambar...')));
    }
  }

  void _onTimerFinished() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Berakhir'),
        content: const Text('Waktu konsultasi Anda telah habis. Apakah Anda ingin memperpanjang sesi ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // leave chat
            },
            child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              Navigator.pop(context);
              // Logic perpanjang sesi (contoh: buka bottom sheet bayar lagi)
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permintaan perpanjangan dikirim')));
            },
            child: const Text('Perpanjang (30 Menit)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final user = ref.watch(authProvider.notifier).currentUser;
    final currentUserId = user?.id ?? '';
    
    final currentSession = sessionState.session ?? widget.session;
    final messages = currentSession.messages.reversed.toList(); // Reverse for bottom-up scrolling

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: currentSession.consultant.photoUrl.isNotEmpty 
                ? CachedNetworkImageProvider(currentSession.consultant.photoUrl) 
                : null,
              child: currentSession.consultant.photoUrl.isEmpty ? const Icon(Icons.person, size: 16) : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentSession.consultant.name, style: const TextStyle(fontSize: 14)),
                  if (sessionState.isTyping)
                    const Text('sedang mengetik...', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SessionTimerWidget(
            startedAt: currentSession.startedAt,
            durationMin: currentSession.durationMin,
            onTimerFinished: _onTimerFinished,
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // Newest at bottom
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == currentUserId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primaryGreen : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                    ),
                    child: msg.type == 'image'
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(imageUrl: msg.content),
                        )
                      : Text(
                          msg.content,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                  ),
                );
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -1))]
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_camera, color: Colors.grey),
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onTyping,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryGreen,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
