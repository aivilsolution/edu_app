import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_app/features/communication/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_chat_');
  }

  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final timestamp = Timestamp.now();

    final messageModel = MessageModel(
      id: '',
      message: message,
      senderId: currentUser.uid,
      receiverId: receiverId,
      senderEmail: currentUser.email!,
      timestamp: timestamp,
      isRead: false,
    );

    final standardChatId = _getChatId(currentUser.uid, receiverId);

    final docRef = await _firestore
        .collection('chats')
        .doc(standardChatId)
        .collection('messages')
        .add(messageModel.toMap());
    await _firestore.collection('chats').doc(standardChatId).set({
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'participants': [currentUser.uid, receiverId],
      'lastSenderId': currentUser.uid,
    }, SetOptions(merge: true));

    await docRef.update({'id': docRef.id});

    await _firestore
        .collection('chats')
        .doc(currentUser.uid)
        .collection('messages')
        .add(messageModel.toMap());

    await _firestore
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .add(messageModel.toMap());
  }

  Stream<List<MessageModel>> getMessagesStream(String receiverId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    String chatId = _getChatId(currentUser.uid, receiverId); 

    return _firestore
        .collection('chats')
        .doc(chatId) 
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> markMessagesAsRead(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final standardChatId = _getChatId(currentUser.uid, receiverId);
    await _markMessagesAsRead(standardChatId, receiverId);

    final batch = _firestore.batch();
    final messages =
        await _firestore
            .collection('chats')
            .doc(currentUser.uid)
            .collection('messages')
            .where('senderId', isEqualTo: receiverId)
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> _markMessagesAsRead(String chatId, String senderId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final batch = _firestore.batch();
    final messages =
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('senderId', isEqualTo: senderId)
            .where('isRead', isEqualTo: false)
            .get();

    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteMessage(String receiverId, String messageId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final standardChatId = _getChatId(currentUser.uid, receiverId);

    await _firestore
        .collection('chats')
        .doc(standardChatId)
        .collection('messages')
        .doc(messageId)
        .delete();

    try {
      final directMessages =
          await _firestore
              .collection('chats')
              .doc(currentUser.uid)
              .collection('messages')
              .where('id', isEqualTo: messageId)
              .limit(1)
              .get();

      if (directMessages.docs.isNotEmpty) {
        await directMessages.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }

    await _updateLastMessageAfterDeletion(standardChatId);
  }

  Future<void> _updateLastMessageAfterDeletion(String chatId) async {
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
  }
}
