import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LlmChatView(
      style: ThemeStyle.fromContext(context),
      provider: VertexProvider(
        model: FirebaseVertexAI.instance.generativeModel(
          model: 'gemini-1.5-flash',
        ),
      ),
    ),
  );
}

class ThemeStyle {
  static LlmChatViewStyle fromContext(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final defaultTextStyle = textTheme.bodyMedium ?? const TextStyle();

    return LlmChatViewStyle(
      backgroundColor: colorScheme.background,
      progressIndicatorColor: colorScheme.primary,
      suggestionStyle: _buildSuggestionStyle(colorScheme, defaultTextStyle),
      chatInputStyle: _buildChatInputStyle(colorScheme, defaultTextStyle),
      userMessageStyle: _buildUserMessageStyle(colorScheme, defaultTextStyle),
      llmMessageStyle: _buildLlmMessageStyle(colorScheme, defaultTextStyle),
      recordButtonStyle: _buildDefaultActionButtonStyle(
        colorScheme,
        defaultTextStyle,
      ),
      stopButtonStyle: _buildDefaultActionButtonStyle(
        colorScheme,
        defaultTextStyle,
      ),
      submitButtonStyle: _buildDefaultActionButtonStyle(
        colorScheme,
        defaultTextStyle,
      ),
      addButtonStyle: _buildDefaultActionButtonStyle(
        colorScheme,
        defaultTextStyle,
      ),
      attachFileButtonStyle: _buildMenuButtonStyle(
        colorScheme,
        defaultTextStyle,
      ),
      cameraButtonStyle: _buildMenuButtonStyle(colorScheme, defaultTextStyle),
      closeButtonStyle: _buildDefaultActionButtonStyle(
        colorScheme,
        defaultTextStyle,
      ),
      cancelButtonStyle: _buildDefaultActionButtonStyle(
        colorScheme,
        defaultTextStyle,
      ),
      closeMenuButtonStyle: _buildDefaultActionButtonStyle(
        colorScheme,
        defaultTextStyle,
      ),
      copyButtonStyle: _buildMenuButtonStyle(colorScheme, defaultTextStyle),
      editButtonStyle: _buildMenuButtonStyle(colorScheme, defaultTextStyle),
      galleryButtonStyle: _buildMenuButtonStyle(colorScheme, defaultTextStyle),
      actionButtonBarDecoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      fileAttachmentStyle: _buildFileAttachmentStyle(
        colorScheme,
        defaultTextStyle,
      ),
    );
  }

  static SuggestionStyle _buildSuggestionStyle(
    ColorScheme colorScheme,
    TextStyle defaultTextStyle,
  ) => SuggestionStyle(
    textStyle: defaultTextStyle.copyWith(color: colorScheme.onPrimary),
    decoration: BoxDecoration(
      color: colorScheme.secondary,
      border: Border.all(color: colorScheme.primary),
    ),
  );

  static ChatInputStyle _buildChatInputStyle(
    ColorScheme colorScheme,
    TextStyle defaultTextStyle,
  ) => ChatInputStyle(
    backgroundColor: colorScheme.surface,
    decoration: BoxDecoration(
      color: colorScheme.surfaceVariant,
      border: Border.all(color: colorScheme.outline),
    ),
    textStyle: defaultTextStyle.copyWith(color: colorScheme.onSurface),
    hintText: 'Type a message...',
    hintStyle: defaultTextStyle.copyWith(color: colorScheme.onSurfaceVariant),
  );

  static UserMessageStyle _buildUserMessageStyle(
    ColorScheme colorScheme,
    TextStyle defaultTextStyle,
  ) => UserMessageStyle(
    textStyle: defaultTextStyle.copyWith(color: colorScheme.onPrimary),
    decoration: BoxDecoration(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withAlpha(128),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
  );

  static LlmMessageStyle _buildLlmMessageStyle(
    ColorScheme colorScheme,
    TextStyle defaultTextStyle,
  ) => LlmMessageStyle(
    icon: Icons.android,
    iconColor: colorScheme.onSecondary,
    iconDecoration: BoxDecoration(
      color: colorScheme.secondary,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
        topRight: Radius.zero,
        bottomRight: Radius.circular(8),
      ),
      border: Border.all(color: colorScheme.onSecondary),
    ),
    decoration: BoxDecoration(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.only(
        topLeft: Radius.zero,
        bottomLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withAlpha(76),
          blurRadius: 8,
          offset: const Offset(2, 2),
        ),
      ],
    ),
    markdownStyle: MarkdownStyleSheet(
      p: defaultTextStyle.copyWith(color: colorScheme.onSecondaryContainer),
      listBullet: defaultTextStyle.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
    ),
  );

  static ActionButtonStyle _buildDefaultActionButtonStyle(
    ColorScheme colorScheme,
    TextStyle defaultTextStyle,
  ) => ActionButtonStyle(
    tooltipTextStyle: defaultTextStyle.copyWith(color: colorScheme.onPrimary),
    iconColor: colorScheme.onPrimary,
    iconDecoration: BoxDecoration(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ActionButtonStyle _buildMenuButtonStyle(
    ColorScheme colorScheme,
    TextStyle defaultTextStyle,
  ) => ActionButtonStyle(
    tooltipTextStyle: defaultTextStyle.copyWith(color: colorScheme.onSurface),
    iconColor: colorScheme.onSurface,
    iconDecoration: BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: colorScheme.onSurface),
    ),
  );

  static FileAttachmentStyle _buildFileAttachmentStyle(
    ColorScheme colorScheme,
    TextStyle defaultTextStyle,
  ) => FileAttachmentStyle(
    decoration: BoxDecoration(color: colorScheme.surface),
    iconDecoration: BoxDecoration(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(8),
    ),
    filenameStyle: defaultTextStyle.copyWith(color: colorScheme.onSurface),
    filetypeStyle: defaultTextStyle.copyWith(
      color: colorScheme.secondary,
      fontSize: 18,
    ),
  );
}
