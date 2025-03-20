import 'package:edu_app/features/communication/models/message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool isConsecutive;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.isConsecutive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final time = DateFormat('h:mm a').format(message.timestamp.toDate());

    return Padding(
      padding: EdgeInsets.only(top: isConsecutive ? 1 : 4, bottom: 1),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isCurrentUser
                        ? colorScheme.primary.withValues(alpha: 0.9)
                        : theme.brightness == Brightness.dark
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.surface,
                borderRadius: _getBubbleRadius(),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: textTheme.bodyMedium?.copyWith(
                      color:
                          isCurrentUser
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: textTheme.labelSmall?.copyWith(
                          color:
                              isCurrentUser
                                  ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                  : colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius _getBubbleRadius() {
    const double radius = 18;
    const double smallRadius = 5;

    if (isCurrentUser) {
      return BorderRadius.only(
        topLeft: const Radius.circular(radius),
        topRight: Radius.circular(isConsecutive ? radius : smallRadius),
        bottomLeft: const Radius.circular(radius),
        bottomRight: const Radius.circular(radius),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(isConsecutive ? radius : smallRadius),
        topRight: const Radius.circular(radius),
        bottomLeft: const Radius.circular(radius),
        bottomRight: const Radius.circular(radius),
      );
    }
  }
}
