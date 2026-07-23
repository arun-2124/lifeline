import 'package:equatable/equatable.dart';

class NotificationModel extends Equatable {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String type; // donation_accepted, pickup_update, SystemAlert
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'payload': payload,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      notificationId: map['notificationId'] as String? ?? id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: map['type'] as String? ?? 'info',
      isRead: map['isRead'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      payload: map['payload'] != null ? Map<String, dynamic>.from(map['payload']) : null,
    );
  }

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? payload,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [
        notificationId,
        userId,
        title,
        body,
        type,
        isRead,
        createdAt,
        payload,
      ];
}
