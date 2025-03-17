import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartx/dartx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:uuid/uuid.dart';
import '../models/chat.dart';

class ChatRepository extends ChangeNotifier {
  ChatRepository._({
    required FirebaseFirestore firestore,
    required User user,
    required List<Chat> chats,
  }) : _firestore = firestore,
       _user = user,
       _chats = chats,
       super();

  static const newChatTitle = 'Untitled';
  static User? _currentUser;
  static ChatRepository? _currentUserRepository;
  final FirebaseFirestore _firestore;
  final User _user;
  final List<Chat> _chats;

  CollectionReference get _chatsCollection =>
      _firestore.collection('users/${_user.uid}/chats');

  CollectionReference historyCollection(Chat chat) =>
      _chatsCollection.doc(chat.id).collection('history');

  List<Chat> get chats => List.unmodifiable(_chats);

  static bool get hasCurrentUser => _currentUser != null;

  static User? get user => _currentUser;

  static set user(User? user) {
    if (user == null) {
      _currentUser = null;
      _currentUserRepository = null;
      return;
    }

    if (user.uid == _currentUser?.uid) {
      return;
    }

    _currentUser = user;
    _currentUserRepository = null;
  }

  static Future<ChatRepository> get forCurrentUser async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    if (_currentUserRepository == null) {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(
        'users/${_currentUser!.uid}/chats',
      );

      final chats = await _loadChats(collection);

      _currentUserRepository = ChatRepository._(
        firestore: firestore,
        user: _currentUser!,
        chats: chats,
      );

      if (chats.isEmpty) {
        await _currentUserRepository!.addChat();
      }
    }

    return _currentUserRepository!;
  }

  static Future<List<Chat>> _loadChats(CollectionReference collection) async {
    try {
      final querySnapshot = await collection.get();
      final chats =
          querySnapshot.docs
              .map((doc) => Chat.fromJson(doc.data()! as Map<String, dynamic>))
              .toList();
      return chats;
    } catch (e) {
      return [];
    }
  }

  Future<Chat> addChat() async {
    final chat = Chat(id: const Uuid().v4(), title: newChatTitle);

    try {
      await _chatsCollection.doc(chat.id).set(chat.toJson());
      _chats.add(chat);
      notifyListeners();
      return chat;
    } catch (e) {
      throw Exception('Failed to add chat');
    }
  }

  Future<void> updateChat(Chat chat) async {
    final index = _chats.indexWhere((c) => c.id == chat.id);
    if (index < 0) {
      throw Exception('Chat not found');
    }

    try {
      await _chatsCollection.doc(chat.id).update(chat.toJson());
      _chats[index] = chat;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update chat');
    }
  }

  Future<void> deleteChat(Chat chat) async {
    if (!_chats.contains(chat)) {
      throw Exception('Chat not found');
    }

    try {
      final batch = _firestore.batch();

      batch.delete(_chatsCollection.doc(chat.id));

      final querySnapshot = await historyCollection(chat).get();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      _chats.remove(chat);
      notifyListeners();

      if (_chats.isEmpty) {
        await addChat();
      }
    } catch (e) {
      throw Exception('Failed to delete chat');
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

      final history =
          indexedMessages.entries
              .sortedBy((e) => e.key)
              .map((e) => e.value)
              .toList();
      return history;
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
      throw Exception('Failed to update chat history');
    }
  }

  @override
  void dispose() {
    if (_currentUserRepository == this) {
      _currentUserRepository = null;
    }
    super.dispose();
  }
}
