import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String message;
  final String senderId;
  final String receiverId;
  final String senderEmail;
  final Timestamp timestamp;

  MessageModel({
    required this.id,
    required this.message,
    required this.senderId,
    required this.timestamp,
    required this.receiverId,
    required this.senderEmail,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id: docId,
      message: map['message'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderId': senderId,
      'timestamp': timestamp,
      'receiverId': receiverId,
      'senderEmail': senderEmail,
    };
  }

  MessageModel copyWith({
    String? id,
    String? message,
    String? senderId,
    String? receiverId,
    String? senderEmail,
    Timestamp? timestamp,
  }) {
    return MessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderEmail: senderEmail ?? this.senderEmail,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
