import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommunityChatMessageModel extends Equatable {
  final String messageId;
  final String donationId;
  final String senderUid;
  final String senderName;
  final String text;
  final DateTime sentAt;

  const CommunityChatMessageModel({
    required this.messageId,
    required this.donationId,
    required this.senderUid,
    required this.senderName,
    required this.text,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'donationId': donationId,
      'senderUid': senderUid,
      'senderName': senderName,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    };
  }

  factory CommunityChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityChatMessageModel(
      messageId: id,
      donationId: map['donationId'] as String? ?? '',
      senderUid: map['senderUid'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'User',
      text: map['text'] as String? ?? '',
      sentAt: map['sentAt'] is Timestamp
          ? (map['sentAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        messageId,
        donationId,
        senderUid,
        senderName,
        text,
        sentAt,
      ];
}
