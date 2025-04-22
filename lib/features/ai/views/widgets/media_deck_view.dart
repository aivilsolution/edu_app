import 'dart:convert';
import 'package:edu_app/features/ai/data/models/media.dart';
import 'package:edu_app/features/ai/data/models/media_deck_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MediaDeckView extends StatefulWidget {
  final Media media;
  final bool needAppBar;

  const MediaDeckView({this.needAppBar = true, super.key, required this.media});

  @override
  State<MediaDeckView> createState() => _MediaDeckViewState();
}

class _MediaDeckViewState extends State<MediaDeckView> {
  List<SlideData> _slides = [];
  int _currentSlideIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMediaDeck();
  }

  Future<void> _loadMediaDeck() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _slides = [];
    });

    final mediaContent = widget.media.content;

    if (mediaContent == null || mediaContent.isEmpty) {
      _setError("Media content is empty.");
      return;
    }

    try {
      final cleanedJsonString = _cleanJsonString(mediaContent);
      final jsonData = await compute(
        _decodeJsonInBackground,
        cleanedJsonString,
      );
      final mediaDeck = MediaDeckData.fromJson(jsonData);

      setState(() {
        _slides = mediaDeck.slides;
        _isLoading = false;
      });
    } on FormatException catch (e) {
      _setError("Content format error: ${e.message}");
    } catch (e) {
      _setError("Failed to load media content.");
    }
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
      _slides = [];
    });
  }

  String _cleanJsonString(String jsonString) {
    String cleanedString = jsonString.trim();
    if (cleanedString.startsWith('```json')) {
      cleanedString = cleanedString.substring(7);
    } else if (cleanedString.startsWith('```')) {
      cleanedString = cleanedString.substring(3);
    }
    if (cleanedString.endsWith('```')) {
      cleanedString = cleanedString.substring(0, cleanedString.length - 3);
    }
    return cleanedString.trim();
  }

  static dynamic _decodeJsonInBackground(String jsonString) {
    return jsonDecode(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.needAppBar ? _buildAppBar() : null,
      body: _buildBody(),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        _isLoading
            ? "Loading Media Deck..."
            : (widget.media.uid.isNotEmpty ? "Media Deck" : "Media Deck"),
      ),
      actions: [
        if (!_isLoading && _slides.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.content_copy),
            tooltip: 'Copy Slide Content',
            onPressed: () => _copySlideContent(context),
          ),
      ],
    );
  }

  void _copySlideContent(BuildContext context) {
    if (_slides.isNotEmpty) {
      final currentSlide = _slides[_currentSlideIndex];
      final textToCopy = "# ${currentSlide.title}\n\n${currentSlide.content}";
      Clipboard.setData(ClipboardData(text: textToCopy));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Slide content copied to clipboard")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No slide content to copy")));
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorBody();
    }

    if (_slides.isEmpty) {
      return const Center(child: Text("No slides available in this deck."));
    }

    return _buildSlideView();
  }

  Widget _buildErrorBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadMediaDeck,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideView() {
    final currentSlide = _slides[_currentSlideIndex];
    return Column(
      children: [
        _buildSlideTitleHeader(currentSlide.title),
        Expanded(child: _buildSlideContentDisplay(currentSlide)),
      ],
    );
  }

  Widget _buildSlideTitleHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Theme.of(context).colorScheme.primaryContainer,
      width: double.infinity,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSlideContentDisplay(SlideData slide) {
    final content = slide.content;
    switch (slide.contentType.toLowerCase()) {
      case 'markdown':
        return _buildMarkdownContent(content);
      case 'text':
        return _buildTextContent(content);
      default:
        return _buildUnsupportedContent(slide.contentType, content);
    }
  }

  Widget _buildMarkdownContent(String content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: MarkdownBody(
        data: content,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
      ),
    );
  }

  Widget _buildTextContent(String content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SelectableText(
        content,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildUnsupportedContent(String contentType, String content) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        "Unsupported content type: $contentType. Displaying as plain text:\n\n$content",
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: 'Previous Slide',
              onPressed: _currentSlideIndex > 0 ? _goToPreviousSlide : null,
            ),
            Text(
              "Slide ${_currentSlideIndex + 1} of ${_slides.length}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              tooltip: 'Next Slide',
              onPressed:
                  _currentSlideIndex < _slides.length - 1
                      ? _goToNextSlide
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  void _goToPreviousSlide() {
    setState(() => _currentSlideIndex--);
  }

  void _goToNextSlide() {
    setState(() => _currentSlideIndex++);
  }
}
