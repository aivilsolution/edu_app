import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_app/features/communication/models/chat.dart';
import 'package:edu_app/features/communication/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<UserModel>> getUsersStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: currentUser.uid)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => UserModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
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
          final List<ChatModel> chats = [];
          final userIds = <String>{};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants'] ?? []);
            final otherUserId = participants.firstWhere(
              (id) => id != currentUser.uid,
              orElse: () => '',
            );
            if (otherUserId.isNotEmpty) {
              userIds.add(otherUserId);
            }
          }

          final userDocs =
              await _firestore
                  .collection('users')
                  .where(FieldPath.documentId, whereIn: userIds.toList())
                  .get();
          final userCache = <String, Map<String, dynamic>>{};
          for (final userDoc in userDocs.docs) {
            userCache[userDoc.id] = userDoc.data();
          }

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants'] ?? []);

            final otherUserId = participants.firstWhere(
              (id) => id != currentUser.uid,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) continue;

            final userData = userCache[otherUserId];
            if (userData == null) continue;

            chats.add(
              ChatModel(
                uid: otherUserId,
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
                photoUrl: userData['photoUrl'],
              ),
            );
          }

          chats.sort((a, b) {
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });

          return chats;
        });
  }

  Future<void> updateUserProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No authenticated user found');
    }

    try {
      final updateData = {
        'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
