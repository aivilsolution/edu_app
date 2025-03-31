import 'package:equatable/equatable.dart';

class Media extends Equatable {
  final String uid;
  final DateTime timestamp;
  final String? content;

  const Media({required this.uid, required this.timestamp, this.content});

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    uid: json['uid'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    content: json['content'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'timestamp': timestamp.toIso8601String(),
    'content': content,
  };

  Media copyWith({String? uid, DateTime? timestamp, String? content}) => Media(
    uid: uid ?? this.uid,
    timestamp: timestamp ?? this.timestamp,
    content: content ?? this.content,
  );

  @override
  List<Object?> get props => [uid, timestamp, content];

  @override
  String toString() =>
      'Media(uid: $uid,timestamp: $timestamp, content: $content)';
}
