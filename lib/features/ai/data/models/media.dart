import 'package:equatable/equatable.dart';

class Media extends Equatable {
  final String id;
  final DateTime timestamp;
  final String? content;

  const Media({required this.id, required this.timestamp, this.content});

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    content: json['content'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'content': content,
  };

  Media copyWith({String? id, DateTime? timestamp, String? content}) => Media(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    content: content ?? this.content,
  );

  @override
  List<Object?> get props => [id, timestamp, content];

  @override
  String toString() =>
      'Media(id: $id,timestamp: $timestamp, content: $content)';
}
