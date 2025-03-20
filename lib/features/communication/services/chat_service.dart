import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_app/features/communication/models/chat.dart';
import 'package:edu_app/features/communication/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<UserModel>> getUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();
        });
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<List<ChatModel>> getChatsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
          List<ChatModel> chats = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants'] ?? []);

            final otherUserId = participants.firstWhere(
              (id) => id != currentUser.uid,
              orElse: () => '',
            );

            if (otherUserId.isNotEmpty) {
              final userDoc =
                  await _firestore.collection('users').doc(otherUserId).get();
              if (userDoc.exists) {
                final userData = userDoc.data()!;

                final isUnread = await _checkUnreadMessages(
                  doc.id,
                  otherUserId,
                );

                chats.add(
                  ChatModel(
                    userId: otherUserId,
                    email: userData['email'] ?? '',
                    username:
                        userData['displayName'] ??
                        userData['email']?.split('@')[0] ??
                        'User',
                    lastMessage: data['lastMessage'],
                    lastMessageTime:
                        data['lastMessageTime'] != null
                            ? (data['lastMessageTime'] as Timestamp).toDate()
                            : null,
                    isUnread: isUnread,
                    photoUrl: userData['photoUrl'],
                  ),
                );
              }
            }
          }

          chats.sort((a, b) {
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });

          return chats;
        });
  }

  Future<bool> _checkUnreadMessages(String chatId, String senderId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final querySnapshot =
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('senderId', isEqualTo: senderId)
            .where('isRead', isEqualTo: false)
            .limit(1)
            .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> updateUserProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDoc = _firestore.collection('users').doc(currentUser.uid);

    await userDoc.update({
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }
}
