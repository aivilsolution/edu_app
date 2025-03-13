
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/media.dart';

class MediaRepository extends ChangeNotifier {
  MediaRepository._({
    required FirebaseFirestore firestore,
    required User user,
    required List<Media> media,
  }) : _firestore = firestore,
       _user = user,
       _media = media;

  static User? _currentUser;
  static MediaRepository? _currentUserRepository;
  final FirebaseFirestore _firestore;
  final User _user;
  final List<Media> _media;

  CollectionReference get _mediaCollection =>
      _firestore.collection('users/${_user.uid}/media');

  List<Media> get media => List.unmodifiable(_media);

  static bool get hasCurrentUser => _currentUser != null;
  static User? get user => _currentUser;

  static set user(User? user) {
    if (user == null) {
      _currentUser = null;
      _currentUserRepository = null;
      return;
    }

    if (user.uid == _currentUser?.uid) return;

    _currentUser = user;
    _currentUserRepository = null;
  }

  static Future<MediaRepository> get forCurrentUser async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    if (_currentUserRepository == null) {
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection(
        'users/${_currentUser!.uid}/media',
      );

      final mediaList = await _loadMedia(collection);

      _currentUserRepository = MediaRepository._(
        firestore: firestore,
        user: _currentUser!,
        media: mediaList,
      );
    }

    return _currentUserRepository!;
  }

  static Future<List<Media>> _loadMedia(CollectionReference collection) async {
    try {
      final querySnapshot =
          await collection.orderBy('timestamp', descending: true).get();

      return querySnapshot.docs
          .map((doc) => Media.fromJson(doc.data()! as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading media: $e');
      return [];
    }
  }

  Future<Media> addMedia({String? content}) async {
    final mediaItem = Media(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      content: content,
    );

    try {
      await _mediaCollection.doc(mediaItem.id).set(mediaItem.toJson());
      _media.insert(0, mediaItem);
      notifyListeners();
      return mediaItem;
    } catch (e) {
      debugPrint('Error adding media: $e');
      throw Exception('Failed to add media');
    }
  }

  Future<void> updateMedia(Media mediaItem) async {
    final index = _media.indexWhere((m) => m.id == mediaItem.id);
    if (index < 0) {
      throw Exception('Media not found');
    }

    try {
      await _mediaCollection.doc(mediaItem.id).update(mediaItem.toJson());
      _media[index] = mediaItem;
      _sortMediaByTimestamp();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating media: $e');
      throw Exception('Failed to update media');
    }
  }

  Future<void> deleteMedia(Media mediaItem) async {
    if (!_media.contains(mediaItem)) {
      throw Exception('Media not found');
    }

    try {
      await _mediaCollection.doc(mediaItem.id).delete();
      _media.remove(mediaItem);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting media: $e');
      throw Exception('Failed to delete media');
    }
  }

  void _sortMediaByTimestamp() =>
      _media.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  Future<void> batchDeleteMedia(List<Media> mediaItems) async {
    if (mediaItems.isEmpty) return;

    final batch = _firestore.batch();
    final idsToRemove = mediaItems.map((m) => m.id).toSet();

    for (final id in idsToRemove) {
      batch.delete(_mediaCollection.doc(id));
    }

    try {
      await batch.commit();
      _media.removeWhere((m) => idsToRemove.contains(m.id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error batch deleting media: $e');
      throw Exception('Failed to batch delete media');
    }
  }

  Future<List<Media>> refreshMediaList() async {
    try {
      final mediaList = await _loadMedia(_mediaCollection);
      _media.clear();
      _media.addAll(mediaList);
      notifyListeners();
      return mediaList;
    } catch (e) {
      debugPrint('Error refreshing media list: $e');
      throw Exception('Failed to refresh media list');
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
