class Chat {
  final String id;
  final String title;

  const Chat({required this.id, required this.title});

  factory Chat.fromJson(Map<String, dynamic> json) =>
      Chat(id: json['id'] as String, title: json['title'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  Chat copyWith({String? title}) => Chat(id: id, title: title ?? this.title);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chat && id == other.id && title == other.title;

  @override
  int get hashCode => Object.hash(id, title);
}
