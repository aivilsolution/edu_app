import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String userId;
  final String email;
  final String username;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? photoUrl;

  ChatModel({
    required this.userId,
    required this.email,
    required this.username,
    this.lastMessage,
    this.lastMessageTime,
    this.photoUrl,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String userId) {
    return ChatModel(
      userId: userId,
      email: map['email'] ?? '',
      username: map['displayName'] ?? map['email']?.split('@')[0] ?? 'User',
      lastMessage: map['lastMessage'],
      lastMessageTime:
          map['lastMessageTime'] != null
              ? (map['lastMessageTime'] as Timestamp).toDate()
              : null,
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'photoUrl': photoUrl,
    };
  }

  String get initials {
    final nameParts = username.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return username[0].toUpperCase();
  }
}
