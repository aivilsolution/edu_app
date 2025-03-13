import 'dart:async';
import 'dart:convert';
import 'package:edu_app/features/ai/bloc/chat_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

import '/features/ai/bloc/media_state.dart';
import '/features/ai/data/models/media.dart';
import '/features/ai/data/repository/media_repository.dart';
import '/features/ai/bloc/chat_cubit.dart';

class MediaCubit extends Cubit<MediaState> {
  final MediaRepository _repository;
  final ChatCubit _chatCubit;
  final FirebaseAuth _auth;
  VoidCallback? _mediaListener;
  StreamSubscription? _generationSubscription;
  Timer? _debounceTimer;

  static const _debounceDefault = Duration(milliseconds: 500);
  static const _defaultSlideCount = 5;
  static const _minSlideCount = 3;
  static const _maxSlideCount = 10;

  MediaCubit({
    required MediaRepository repository,
    required ChatCubit chatCubit,
    FirebaseAuth? auth,
  }) : _repository = repository,
       _chatCubit = chatCubit,
       _auth = auth ?? FirebaseAuth.instance,
       super(const MediaInitialState()) {
    _setupListeners();
    _loadMedia();
  }

  static Future<MediaCubit> create({
    required MediaRepository repository,
    required ChatCubit chatCubit,
    FirebaseAuth? auth,
  }) async {
    final cubit = MediaCubit(
      repository: repository,
      chatCubit: chatCubit,
      auth: auth,
    );
    await cubit._initialize();
    return cubit;
  }

  Future<void> _initialize() async {
    debugPrint('MediaCubit: initializing');
    try {
      await MediaRepository.forCurrentUser;
      await _loadMedia();
    } catch (e, stackTrace) {
      _handleError('Failed to initialize', e, stackTrace);
    }
  }

  void _setupListeners() {
    _mediaListener = _handleMediaUpdate;
    _repository.addListener(_mediaListener!);
  }

  Future<void> refreshMedia() async {
    debugPrint('MediaCubit: refreshing media');
    final currentMedia = _getCurrentMedia();
    emit(MediaLoadingState(allMedia: currentMedia));

    try {
      await _repository.refreshMediaList();
      await _loadMedia();
    } catch (e, stackTrace) {
      _handleError(
        'Failed to refresh media',
        e,
        stackTrace,
        allMedia: currentMedia,
      );
    }
  }

  Future<void> loadMedia() async {
    if (state is MediaLoadingState) return;

    emit(MediaLoadingState(allMedia: _getCurrentMedia()));
    await _loadMedia();
  }

  Future<Media?> createMedia({required String content}) async {
    emit(MediaLoadingState(allMedia: _getCurrentMedia()));
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      emit(const MediaErrorState('User not authenticated'));
      return null;
    }

    try {
      return await _repository.addMedia(content: content);
    } catch (e, stackTrace) {
      _handleError('Failed to create media', e, stackTrace);
      return null;
    }
  }

  Future<void> updateMediaContent(
    Media media,
    String content, {
    bool debounce = true,
    Duration? debounceTime,
  }) async {
    if (state is! MediaLoadedState) return;
    _debounceTimer?.cancel();

    try {
      if (debounce) {
        _debounceTimer = Timer(debounceTime ?? _debounceDefault, () async {
          await _repository.updateMedia(media.copyWith(content: content));
        });
      } else {
        await _repository.updateMedia(media.copyWith(content: content));
      }
    } catch (e, stackTrace) {
      _handleError(
        'Failed to update content',
        e,
        stackTrace,
        allMedia: _repository.media,
      );
      await _loadMedia();
    }
  }

  Future<void> deleteMedia(Media media) async {
    if (state is! MediaLoadedState) return;
    final currentMedia = (state as MediaLoadedState).allMedia;
    try {
      await _repository.deleteMedia(media);
    } catch (e, stackTrace) {
      _handleError(
        'Failed to delete media',
        e,
        stackTrace,
        allMedia: currentMedia,
      );
      await _loadMedia();
    }
  }

  Future<void> batchDeleteMedia(List<Media> mediaItems) async {
    if (state is! MediaLoadedState || mediaItems.isEmpty) return;
    final currentMedia = (state as MediaLoadedState).allMedia;
    try {
      await _repository.batchDeleteMedia(mediaItems);
    } catch (e, stackTrace) {
      _handleError(
        'Failed to delete media',
        e,
        stackTrace,
        allMedia: currentMedia,
      );
      await _loadMedia();
    }
  }

  Future<void> generateMedia({required String prompt, int? slideCount}) async {
    if (_chatCubit.state is! ChatLoadedState) {
      emit(const MediaErrorState('LLM Provider not available'));
      return;
    }
    if (state is MediaGeneratingState) _cancelGeneration();

    final currentMedia = _getCurrentMedia();
    emit(MediaGeneratingState(prompt: prompt, allMedia: currentMedia));

    try {
      final llmProvider = _getLlmProvider();
      if (llmProvider == null) return;

      final content = await _generateLlmContent(
        prompt,
        llmProvider,
        slideCount: slideCount,
      );
      await createMedia(content: content);
      await refreshMedia();
    } catch (e, stackTrace) {
      _handleError('Generation failed', e, stackTrace, allMedia: currentMedia);
    }
  }

  void cancelGeneration() => _cancelGeneration();

  Future<void> _loadMedia() async {
    try {
      emit(MediaLoadedState(allMedia: _repository.media));
    } catch (e, stackTrace) {
      _handleError('Failed to load media', e, stackTrace);
    }
  }

  void _cancelGeneration() {
    _generationSubscription?.cancel();
    _generationSubscription = null;
    if (state is MediaGeneratingState) {
      emit(
        MediaLoadedState(allMedia: (state as MediaGeneratingState).allMedia),
      );
    }
  }

  Future<String> _generateLlmContent(
    String prompt,
    LlmProvider llmProvider, {
    int? slideCount,
  }) async {
    return _generateMediaJson(prompt, llmProvider, slideCount: slideCount);
  }

  Future<String> _generateMediaJson(
    String prompt,
    LlmProvider llmProvider, {
    int? slideCount,
  }) async {
    final effectiveSlideCount =
        slideCount?.clamp(_minSlideCount, _maxSlideCount) ?? _defaultSlideCount;
    const progressStep = 0.9;
    double currentProgress = 0.0;
    final systemPrompt = _buildSystemPrompt(prompt);
    String fullResponse = '';

    _generationSubscription = llmProvider
        .sendMessageStream(systemPrompt)
        .listen(
          (chunk) {
            fullResponse += chunk;
            if (state is MediaGeneratingState) {
              currentProgress += (chunk.length / 2000.0) * progressStep;
              emit(
                (state as MediaGeneratingState).copyWith(
                  progress: currentProgress.clamp(0.0, progressStep),
                ),
              );
            }
          },
          onDone: () {
            if (state is MediaGeneratingState) {
              emit((state as MediaGeneratingState).copyWith(progress: 0.95));
            }
            _generationSubscription = null;
          },
          onError: (e, stackTrace) {
            _handleError('Generation stream error', e, stackTrace);
            _generationSubscription = null;
          },
        );

    final completer = Completer<String>();
    _generationSubscription?.onDone(() {
      try {
        final validatedJson = _validateAndFixJson(
          fullResponse,
          effectiveSlideCount,
        );
        completer.complete(validatedJson);
      } catch (e) {
        completer.complete(fullResponse);
      }
    });
    return completer.future;
  }

  String _buildSystemPrompt(String prompt) {
    return '''
You are a professional slide presentation generator that creates engaging, visually-oriented content. Create a JSON formatted output for a presentation on the topic: "$prompt".

Requirements:
1. The first slide must be a title slide with an eye-catching headline and a brief overview.
2. The final slide must be a conclusion with key takeaways or a call to action.
3. The middle slides should develop the topic logically and engagingly.

For each slide, include:
- slide_number: the order of the slide
- slide_type: one of title, content, visual, quote, data, conclusion
- title: a concise, impactful title
- content: markdown formatted content (bullet points preferred, 40-60 words max)
- visual_suggestion: a description of a visual element or image that complements the content
- presenter_notes: additional context or talking points for the presenter

The JSON output must follow this schema:
{
  "presentation_title": "Overall Presentation Title",
  "target_audience": "Brief description of intended audience",
  "slides": [
    {
      "slide_number": 1,
      "slide_type": "title|content|visual|quote|data|conclusion",
      "title": "Concise, Impactful Slide Title",
      "content": "Content in Markdown format. Bullet points preferred for most slides. Keep it scannable.",
      "visual_suggestion": "Description of an image or visual element that would enhance this slide",
      "presenter_notes": "Additional context or talking points for the presenter (not displayed)"
    }
  ]
}

Additional Guidelines:
- Produce between 3 to 10 slides, with a default of 5 slides if not specified.
- Use active voice, strong verbs, and include specific examples or statistics when relevant.
- Vary slide types to maintain audience engagement.
- Ensure a logical flow between slides with smooth transitions.
- Tailor content to the expertise level of the intended audience.
- Your response must be valid, parseable JSON with no additional commentary.
''';
  }

  String _validateAndFixJson(String jsonString, int expectedSlideCount) {
    try {
      final jsonData = jsonDecode(jsonString);
      final slides = jsonData['slides'] as List;

      if (slides.length != expectedSlideCount) {
        if (slides.length > expectedSlideCount) {
          jsonData['slides'] = slides.sublist(0, expectedSlideCount);
          return jsonEncode(jsonData);
        } else {
          // Optionally, add logic to supplement missing slides.
          return jsonString;
        }
      }
      return jsonString;
    } catch (e) {
      return jsonString;
    }
  }

  void _handleMediaUpdate() {
    if (state is MediaLoadedState) {
      emit(MediaLoadedState(allMedia: _repository.media));
    }
  }

  List<Media> _getCurrentMedia() {
    return state is MediaLoadedState
        ? (state as MediaLoadedState).allMedia
        : [];
  }

  void _handleError(
    String message,
    Object error,
    StackTrace stackTrace, {
    List<Media>? allMedia,
  }) {
    final errorMessage = '$message: ${error.toString().split('\n').first}';
    debugPrint('MediaCubit Error: $message: $error\n$stackTrace');
    emit(
      MediaErrorState(
        errorMessage,
        allMedia: allMedia,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  LlmProvider? _getLlmProvider() {
    if (_chatCubit.state is! ChatLoadedState) {
      emit(const MediaErrorState('LLM Provider not available from ChatCubit'));
      return null;
    }
    return VertexProvider(
      model: FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.0-flash-lite-preview-02-05',
      ),
    );
  }

  @override
  Future<void> close() {
    _generationSubscription?.cancel();
    _debounceTimer?.cancel();
    if (_mediaListener != null) {
      _repository.removeListener(_mediaListener!);
      _mediaListener = null;
    }
    return super.close();
  }
}
