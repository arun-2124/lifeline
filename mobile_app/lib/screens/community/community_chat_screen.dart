import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/community_chat_message_model.dart';
import 'package:mobile_app/models/community_donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';

class CommunityChatScreen extends ConsumerStatefulWidget {
  final CommunityDonationModel donation;

  const CommunityChatScreen({super.key, required this.donation});

  @override
  ConsumerState<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends ConsumerState<CommunityChatScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final repo = ref.read(communitySharingRepositoryProvider);
    final msg = CommunityChatMessageModel(
      messageId: '',
      donationId: widget.donation.donationId,
      senderUid: user.uid,
      senderName: user.fullName,
      text: text,
      sentAt: DateTime.now(),
    );

    repo.sendChatMessage(msg);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final repo = ref.watch(communitySharingRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.donation.donorName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Food: ${widget.donation.foodName}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pickup Window: ${widget.donation.pickupWindow}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Stream Chat Messages
          Expanded(
            child: StreamBuilder<List<CommunityChatMessageModel>>(
              stream: repo.streamChatMessages(widget.donation.donationId),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [
                  CommunityChatMessageModel(
                    messageId: '1',
                    donationId: widget.donation.donationId,
                    senderUid: widget.donation.donorUid,
                    senderName: widget.donation.donorName,
                    text: 'Hello! Your food reservation is confirmed. Let me know when you arrive at ${widget.donation.pickupAddress}.',
                    sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
                  ),
                ];

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderUid == user?.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type pickup coordinate message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
