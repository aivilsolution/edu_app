import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_app/features/auth/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/media.dart';

class MediaRepository extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final AppUser _user;
  final List<Media> _media;

  static const _mediaCollectionPrefix = 'users';

  MediaRepository._({
    required FirebaseFirestore firestore,
    required AppUser user,
    required List<Media> media,
  }) : _firestore = firestore,
       _user = user,
       _media = media {
    if (kDebugMode) {}
  }

  List<Media> get media => List.unmodifiable(_media);
  CollectionReference get _mediaCollection =>
      _firestore.collection('$_mediaCollectionPrefix/${_user.id}/media');

  static AppUser? _currentUser;
  static MediaRepository? _currentUserRepository;

  static bool get hasCurrentUser => _currentUser != null;
  static AppUser? get user => _currentUser;

  static set user(AppUser? newUser) {
    if (newUser == null) {
      _currentUser = null;
      _currentUserRepository = null;
      return;
    }

    if (newUser.id != _currentUser?.id) {
      _currentUser = newUser;
      _currentUserRepository = null;
    }
  }

  static Future<MediaRepository> get forCurrentUser async {
    if (_currentUser == null) {
      throw StateError('No user logged in');
    }

    _currentUserRepository ??= await _createRepositoryForCurrentUser();
    return _currentUserRepository!;
  }

  static Future<MediaRepository> _createRepositoryForCurrentUser() async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection(
      '$_mediaCollectionPrefix/${_currentUser!.id}/media',
    );

    final mediaList = await _loadMedia(collection);

    return MediaRepository._(
      firestore: firestore,
      user: _currentUser!,
      media: mediaList,
    );
  }

  static Future<List<Media>> _loadMedia(CollectionReference collection) async {
    try {
      final querySnapshot =
          await collection.orderBy('timestamp', descending: true).get();

      return querySnapshot.docs.map((doc) {
        return Media.fromJson(doc.data()! as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {}
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
      if (kDebugMode) {}
      throw StateError('Failed to add media');
    }
  }

  Future<void> updateMedia(Media mediaItem) async {
    final index = _media.indexWhere((m) => m.id == mediaItem.id);
    if (index < 0) {
      throw StateError('Media not found');
    }

    try {
      await _mediaCollection.doc(mediaItem.id).update(mediaItem.toJson());
      _media[index] = mediaItem;
      _sortMediaByTimestamp();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {}
      throw StateError('Failed to update media');
    }
  }

  Future<void> deleteMedia(Media mediaItem) async {
    if (!_media.contains(mediaItem)) {
      throw StateError('Media not found');
    }

    try {
      await _mediaCollection.doc(mediaItem.id).delete();
      _media.remove(mediaItem);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {}
      throw StateError('Failed to delete media');
    }
  }

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
      if (kDebugMode) {}
      throw StateError('Failed to batch delete media');
    }
  }

  void _sortMediaByTimestamp() {
    _media.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<Media>> refreshMediaList() async {
    try {
      final mediaList = await _loadMedia(_mediaCollection);
      _media.clear();
      _media.addAll(mediaList);
      notifyListeners();
      return mediaList;
    } catch (e) {
      if (kDebugMode) {}
      throw StateError('Failed to refresh media list');
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
