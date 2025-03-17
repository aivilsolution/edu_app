import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '/features/ai/data/models/media.dart';

@immutable
abstract class MediaState extends Equatable {
  const MediaState();

  @override
  bool get stringify => true;
}

class MediaInitialState extends MediaState {
  const MediaInitialState();

  @override
  List<Object?> get props => [];
}

class MediaLoadingState extends MediaState {
  final List<Media>? allMedia;

  const MediaLoadingState({this.allMedia});

  @override
  List<Object?> get props => [allMedia];
}

class MediaLoadedState extends MediaState {
  final List<Media> allMedia;

  bool get isEmpty => allMedia.isEmpty;

  const MediaLoadedState({required this.allMedia});

  MediaLoadedState copyWith({List<Media>? allMedia}) {
    return MediaLoadedState(allMedia: allMedia ?? this.allMedia);
  }

  @override
  List<Object?> get props => [allMedia];

  @override
  String toString() =>
      'MediaLoadedState(count: ${allMedia.length},isEmpty: $isEmpty)';
}

class MediaGeneratingState extends MediaState {
  final String prompt;
  final List<Media> allMedia;
  final double? progress;

  const MediaGeneratingState({
    required this.prompt,
    required this.allMedia,
    this.progress,
  });

  MediaGeneratingState copyWith({double? progress}) {
    return MediaGeneratingState(
      prompt: prompt,
      allMedia: allMedia,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [prompt, allMedia, progress];

  @override
  String toString() => 'MediaGeneratingState(progress: $progress)';
}

class MediaErrorState extends MediaState {
  final String message;
  final List<Media>? allMedia;
  final Object? error;
  final StackTrace? stackTrace;

  const MediaErrorState(
    this.message, {
    this.allMedia,
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, allMedia, error, stackTrace];

  @override
  String toString() => 'MediaErrorState(message: $message, error: $error)';
}
