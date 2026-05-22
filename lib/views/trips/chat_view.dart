import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/chat_message_model.dart';
import '../../../services/firestore_service.dart';
import '../../../core/utils/input_formatters.dart';

class ChatView extends StatefulWidget {
  final String tripId;

  const ChatView({super.key, required this.tripId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _firestoreService = FirestoreService();
  final _msgCtrl = TextEditingController();
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _currentName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    if (_currentUid.isNotEmpty) {
      final u = await _firestoreService.getUser(_currentUid);
      if (!mounted) return;
      if (u != null) {
        setState(() => _currentName = u.name);
      }
    }
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    if (text.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message is too long.')),
      );
      return;
    }
    if (_currentUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to send messages.')),
      );
      return;
    }

    _firestoreService.sendMessage(
      tripId: widget.tripId,
      senderId: _currentUid,
      senderName: _currentName,
      text: text,
    );
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessageModel>>(
            stream: _firestoreService.streamMessages(widget.tripId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.amber));
              }

              final messages = snapshot.data ?? [];
              if (messages.isEmpty) {
                return Center(
                  child: Text('Start the conversation!',
                      style: GoogleFonts.inter(color: AppColors.slate400)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == _currentUid;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.amber : AppColors.glassBg,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 0),
                          bottomRight: Radius.circular(isMe ? 0 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              msg.senderName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate400,
                              ),
                            ),
                          if (!isMe) const SizedBox(height: 4),
                          Text(
                            msg.text,
                            style: GoogleFonts.inter(
                              color:
                                  isMe ? AppColors.navyDeep : AppColors.white,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm').format(msg.sentAt),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe
                                  ? AppColors.navyDeep.withValues(alpha: 0.5)
                                  : AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.glassBg,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  style: const TextStyle(color: AppColors.white),
                  onSubmitted: (_) => _send(),
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [
                    LeadingSpaceFormatter(),
                    LengthLimitingTextInputFormatter(500),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: AppColors.slate400),
                    filled: true,
                    fillColor: AppColors.navyDeep,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: AppColors.amber,
                child: IconButton(
                  icon:
                      const Icon(Icons.send_rounded, color: AppColors.navyDeep),
                  onPressed: _send,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
