import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartx/dartx.dart';
import 'package:edu_app/features/auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:uuid/uuid.dart';
import '../models/chat.dart';

class ChatRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final AppUser? _user;
  final List<Chat> _chats;

  static const newChatTitle = 'Untitled';
  static const _chatsCollectionPrefix = 'users';

  ChatRepository._({
    required FirebaseFirestore firestore,
    required AppUser? user,
    required List<Chat> chats,
  }) : _firestore = firestore,
       _user = user,
       _chats = chats;

  List<Chat> get chats => List.unmodifiable(_chats);
  CollectionReference get _chatsCollection =>
      _firestore.collection('$_chatsCollectionPrefix/${_user!.uid}/chats');

  CollectionReference historyCollection(Chat chat) =>
      _chatsCollection.doc(chat.id).collection('history');

  static AppUser? _currentUser;
  static ChatRepository? _currentUserRepository;

  static bool get hasCurrentUser => _currentUser != null;
  static AppUser? get user => _currentUser;

  static set user(AppUser? newUser) {
    if (newUser == null) {
      _currentUser = null;
      _currentUserRepository = null;
      return;
    }

    if (newUser.uid != _currentUser?.uid) {
      _currentUser = newUser;
      _currentUserRepository = null;
    }
  }

  static Future<ChatRepository> get forCurrentUser async {
    if (_currentUser == null) {
      throw StateError('No user logged in');
    }

    _currentUserRepository ??= await _createRepositoryForCurrentUser();
    return _currentUserRepository!;
  }

  static Future<ChatRepository> _createRepositoryForCurrentUser() async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection(
      '$_chatsCollectionPrefix/${_currentUser!.uid}/chats',
    );

    final chats = await _loadChats(collection);

    return ChatRepository._(
      firestore: firestore,
      user: _currentUser!,
      chats: chats,
    );
  }

  static Future<List<Chat>> _loadChats(CollectionReference collection) async {
    try {
      final querySnapshot = await collection.get();
      return querySnapshot.docs.map((doc) {
        return Chat.fromJson(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Chat createTemporaryChat() {
    return Chat(id: const Uuid().v4(), title: newChatTitle);
  }

  Future<Chat> addChat({Chat? temporaryChat}) async {
    final chat =
        temporaryChat ?? Chat(id: const Uuid().v4(), title: newChatTitle);

    try {
      await _chatsCollection.doc(chat.id).set(chat.toJson());
      _chats.add(chat);
      notifyListeners();
      return chat;
    } catch (e) {
      throw StateError('Failed to add chat');
    }
  }

  Future<void> updateChat(Chat chat) async {
    final index = _chats.indexWhere((c) => c.id == chat.id);
    if (index < 0) {
      throw StateError('Chat not found');
    }

    try {
      await _chatsCollection.doc(chat.id).update(chat.toJson());
      _chats[index] = chat;
      notifyListeners();
    } catch (e) {
      throw StateError('Failed to update chat');
    }
  }

  Future<void> deleteChat(Chat chat) async {
    if (!_chats.contains(chat)) {
      throw StateError('Chat not found');
    }

    try {
      final batch = _firestore.batch();
      batch.delete(_chatsCollection.doc(chat.id));

      final historySnapshot = await historyCollection(chat).get();
      for (final doc in historySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _chats.remove(chat);
      notifyListeners();

      if (_chats.isEmpty) {
        await addChat();
      }
    } catch (e) {
      throw StateError('Failed to delete chat');
    }
  }

  Future<List<ChatMessage>> getHistory(Chat chat) async {
    try {
      final querySnapshot = await historyCollection(chat).get();
      final indexedMessages = <int, ChatMessage>{};

      for (final doc in querySnapshot.docs) {
        final index = int.parse(doc.id);
        final message = ChatMessage.fromJson(
          doc.data()! as Map<String, dynamic>,
        );
        indexedMessages[index] = message;
      }

      return indexedMessages.entries
          .sortedBy((e) => e.key)
          .map((e) => e.value)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateHistory(Chat chat, List<ChatMessage> history) async {
    try {
      final batch = _firestore.batch();
      bool hasChanges = false;

      for (var i = 0; i < history.length; i++) {
        final id = i.toString().padLeft(3, '0');
        final docRef = historyCollection(chat).doc(id);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          batch.set(docRef, history[i].toJson());
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await batch.commit();
      }
    } catch (e) {
      throw StateError('Failed to update chat history');
    }
  }

  static void clearCache() {
    _currentUserRepository = null;
  }

  @override
  void dispose() {
    if (_currentUserRepository == this) {
      _currentUserRepository = null;
    }
    super.dispose();
  }
}
