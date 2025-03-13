import 'package:flutter/foundation.dart';


@immutable
class MediaDeckData {
  final String version;
  final String? deckTitle;
  final String? author;
  final String? createdAt;
  final List<SlideData> slides;

  const MediaDeckData({
    this.version = '1.0',
    this.deckTitle,
    this.author,
    this.createdAt,
    this.slides = const [],
  });

  factory MediaDeckData.fromJson(Map<String, dynamic> json) {
    return MediaDeckData(
      version: json['version'] as String? ?? '1.0',
      deckTitle: json['deckTitle'] as String?,
      author: json['author'] as String?,
      createdAt: json['createdAt'] as String?,
      slides: _parseSlidesFromJson(json['slides']),
    );
  }

  static List<SlideData> _parseSlidesFromJson(dynamic slidesJson) {
    if (slidesJson == null) return const [];

    if (slidesJson is! List) {
      throw FormatException(
        'Expected slides to be a List but got ${slidesJson.runtimeType}',
      );
    }

    try {
      return slidesJson
          .cast<Map<String, dynamic>>()
          .map((slideJson) => SlideData.fromJson(slideJson))
          .toList();
    } catch (e) {
      throw FormatException('Error parsing slides: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      if (deckTitle != null) 'deckTitle': deckTitle,
      if (author != null) 'author': author,
      if (createdAt != null) 'createdAt': createdAt,
      'slides': slides.map((slide) => slide.toJson()).toList(),
    };
  }

  MediaDeckData copyWith({
    String? version,
    String? deckTitle,
    String? author,
    String? createdAt,
    List<SlideData>? slides,
  }) {
    return MediaDeckData(
      version: version ?? this.version,
      deckTitle: deckTitle ?? this.deckTitle,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      slides: slides ?? this.slides,
    );
  }

  @override
  String toString() {
    return 'MediaDeckData{version: $version, deckTitle: $deckTitle, '
        'author: $author, createdAt: $createdAt, slides: ${slides.length} slides}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaDeckData &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          deckTitle == other.deckTitle &&
          author == other.author &&
          createdAt == other.createdAt &&
          listEquals(slides, other.slides);

  @override
  int get hashCode => Object.hash(
    version,
    deckTitle,
    author,
    createdAt,
    Object.hashAll(slides),
  );
}


@immutable
class SlideData {
  final int? slideNumber;
  final String title;
  final String contentType;
  final String content;
  final String? speakerNotes;
  final ImageInfo? image;

  const SlideData({
    this.slideNumber,
    required this.title,
    this.contentType = 'markdown',
    required this.content,
    this.speakerNotes,
    this.image,
  });

  factory SlideData.fromJson(Map<String, dynamic> json) {
    return SlideData(
      slideNumber: json['slideNumber'] as int?,
      title: json['title'] as String? ?? 'Untitled Slide',
      contentType: json['contentType'] as String? ?? 'markdown',
      content: json['content'] as String? ?? '',
      speakerNotes: json['speakerNotes'] as String?,
      image:
          json['image'] != null
              ? ImageInfo.fromJson(json['image'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (slideNumber != null) 'slideNumber': slideNumber,
      'title': title,
      'contentType': contentType,
      'content': content,
      if (speakerNotes != null) 'speakerNotes': speakerNotes,
      if (image != null) 'image': image!.toJson(),
    };
  }

  SlideData copyWith({
    int? slideNumber,
    String? title,
    String? contentType,
    String? content,
    String? speakerNotes,
    ImageInfo? image,
  }) {
    return SlideData(
      slideNumber: slideNumber ?? this.slideNumber,
      title: title ?? this.title,
      contentType: contentType ?? this.contentType,
      content: content ?? this.content,
      speakerNotes: speakerNotes ?? this.speakerNotes,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'SlideData{slideNumber: $slideNumber, title: $title, contentType: $contentType}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlideData &&
          runtimeType == other.runtimeType &&
          slideNumber == other.slideNumber &&
          title == other.title &&
          contentType == other.contentType &&
          content == other.content &&
          speakerNotes == other.speakerNotes &&
          image == other.image;

  @override
  int get hashCode => Object.hash(
    slideNumber,
    title,
    contentType,
    content,
    speakerNotes,
    image,
  );
}


@immutable
class ImageInfo {
  final String url;
  final String? altText;

  const ImageInfo({required this.url, this.altText});

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    if (json['url'] == null) {
      throw FormatException('ImageInfo requires a url field');
    }

    return ImageInfo(
      url: json['url'] as String,
      altText: json['altText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      if (altText != null) 'altText': altText,
    };
  }

  ImageInfo copyWith({String? url, String? altText}) {
    return ImageInfo(url: url ?? this.url, altText: altText ?? this.altText);
  }

  @override
  String toString() {
    return 'ImageInfo{url: $url}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageInfo &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          altText == other.altText;

  @override
  int get hashCode => Object.hash(url, altText);
}
