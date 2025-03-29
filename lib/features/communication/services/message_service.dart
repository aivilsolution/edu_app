import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_app/features/communication/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_chat_');
  }

  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final timestamp = Timestamp.now();
      final chatId = _getChatId(currentUser.uid, receiverId);

      final messageModel = MessageModel(
        id: '',
        message: message,
        senderId: currentUser.uid,
        receiverId: receiverId,
        senderEmail: currentUser.email ?? 'unknown',
        timestamp: timestamp,
      );

      final docRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageModel.toMap());

      await docRef.update({'id': docRef.id});

      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': message,
        'lastMessageTime': timestamp,
        'participants': [currentUser.uid, receiverId],
        'lastSenderId': currentUser.uid,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String receiverId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    final chatId = _getChatId(currentUser.uid, receiverId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<void> deleteMessage(String receiverId, String messageId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final chatId = _getChatId(currentUser.uid, receiverId);

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      await _updateLastMessageAfterDeletion(chatId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  Future<void> _updateLastMessageAfterDeletion(String chatId) async {
    try {
      final messages =
          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (messages.docs.isNotEmpty) {
        final lastMessage = MessageModel.fromMap(
          messages.docs.first.data(),
          messages.docs.first.id,
        );

        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': lastMessage.message,
          'lastMessageTime': lastMessage.timestamp,
          'lastSenderId': lastMessage.senderId,
        });
      } else {
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': null,
          'lastMessageTime': null,
          'lastSenderId': null,
        });
      }
    } catch (e) {
      throw Exception('Failed to update chat metadata: $e');
    }
  }
}
