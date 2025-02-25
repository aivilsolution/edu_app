import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartx/dartx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:uuid/uuid.dart';
import '../models/chat.dart';

/// Repository for managing chat data in Firestore
class ChatRepository extends ChangeNotifier {
  ChatRepository._({
    required FirebaseFirestore firestore,
    required User user,
    required List<Chat> chats,
  }) : _firestore = firestore,
       _user = user,
       _chats = chats;

  static const newChatTitle = 'Untitled';
  static User? _currentUser;
  static ChatRepository? _currentUserRepository;
  final FirebaseFirestore _firestore;
  final User _user;
  final List<Chat> _chats;

  /// Returns the collection reference for the current user's chats
  CollectionReference get _chatsCollection =>
      _firestore.collection('users/${_user.uid}/chats');

  /// Returns the collection reference for a chat's history
  CollectionReference _historyCollection(Chat chat) =>
      _chatsCollection.doc(chat.id).collection('history');

  /// Returns a read-only list of chats
  List<Chat> get chats => List.unmodifiable(_chats);

  /// Returns true if a user is currently logged in
  static bool get hasCurrentUser => _currentUser != null;

  /// Returns the currently logged in user
  static User? get user => _currentUser;

  /// Sets the current user and clears the repository cache when necessary
  static set user(User? user) {
    if (user == null) {
      _currentUser = null;
      _currentUserRepository = null;
      return;
    }

    // Ignore if the same user is already logged in
    if (user.uid == _currentUser?.uid) return;

    // Clear the repository cache to load the user's chats on demand
    _currentUser = user;
    _currentUserRepository = null;
  }

  /// Returns the repository for the current user
  static Future<ChatRepository> get forCurrentUser async {
    // No user, no repository
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    // Load the repository for the current user if it's not already loaded
    if (_currentUserRepository == null) {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(
        'users/${_currentUser!.uid}/chats',
      );

      // Load the chats from the database
      final chats = await _loadChats(collection);

      _currentUserRepository = ChatRepository._(
        firestore: firestore,
        user: _currentUser!,
        chats: chats,
      );

      // If there are no chats, add a new one
      if (chats.isEmpty) {
        await _currentUserRepository!.addChat();
      }
    }

    return _currentUserRepository!;
  }

  /// Loads chats from Firestore
  static Future<List<Chat>> _loadChats(CollectionReference collection) async {
    try {
      final querySnapshot = await collection.get();
      return querySnapshot.docs
          .map((doc) => Chat.fromJson(doc.data()! as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading chats: $e');
      return [];
    }
  }

  /// Adds a new chat and returns it
  Future<Chat> addChat() async {
    final chat = Chat(id: const Uuid().v4(), title: newChatTitle);

    try {
      await _chatsCollection.doc(chat.id).set(chat.toJson());
      _chats.add(chat);
      notifyListeners();
      return chat;
    } catch (e) {
      debugPrint('Error adding chat: $e');
      throw Exception('Failed to add chat');
    }
  }

  /// Updates an existing chat
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
      debugPrint('Error updating chat: $e');
      throw Exception('Failed to update chat');
    }
  }

  /// Deletes a chat and its history
  Future<void> deleteChat(Chat chat) async {
    if (!_chats.contains(chat)) {
      throw Exception('Chat not found');
    }

    try {
      // Use a batch to delete the chat and its history
      final batch = _firestore.batch();

      // Mark the chat document for deletion
      batch.delete(_chatsCollection.doc(chat.id));

      // Get history documents to delete
      final querySnapshot = await _historyCollection(chat).get();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Execute the batch
      await batch.commit();

      // Update the in-memory list
      _chats.remove(chat);
      notifyListeners();

      // If we've deleted the last chat, add a new one
      if (_chats.isEmpty) await addChat();
    } catch (e) {
      debugPrint('Error deleting chat: $e');
      throw Exception('Failed to delete chat');
    }
  }

  /// Retrieves the message history for a chat
  Future<List<ChatMessage>> getHistory(Chat chat) async {
    try {
      final querySnapshot = await _historyCollection(chat).get();

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
      debugPrint('Error getting chat history: $e');
      return [];
    }
  }

  /// Updates the message history for a chat
  Future<void> updateHistory(Chat chat, List<ChatMessage> history) async {
    try {
      // Use a batch for better performance and atomicity
      final batch = _firestore.batch();
      bool hasChanges = false;

      for (var i = 0; i < history.length; i++) {
        final id = i.toString().padLeft(3, '0');
        final docRef = _historyCollection(chat).doc(id);
        final docSnapshot = await docRef.get();

        // Only add new messages
        if (!docSnapshot.exists) {
          batch.set(docRef, history[i].toJson());
          hasChanges = true;
        }
      }

      // Only commit if there are changes
      if (hasChanges) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error updating chat history: $e');
      throw Exception('Failed to update chat history');
    }
  }

  /// Disposes the repository and clears any references
  @override
  void dispose() {
    if (_currentUserRepository == this) {
      _currentUserRepository = null;
    }
    super.dispose();
  }
}
