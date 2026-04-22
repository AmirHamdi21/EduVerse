import '../../bloc/chat/chat_models.dart';

/// Extra helpers used by UX flows that should not live inside core API models.
extension HydratedMessage on ChatMessageModel {
  /// Resolves a stable sender label for reply context previews.
  ///
  /// Falls back to the participant cache when `senderName` is not hydrated,
  /// and finally to `Unknown User` when no participant can be resolved.
  String hydratedReplyToName(
    Map<int, ChatUserModel> participantCache, {
    String fallback = 'Unknown User',
  }) {
    final normalized = senderName?.trim();
    if (normalized != null &&
        normalized.isNotEmpty &&
        normalized.toLowerCase() != 'unknown') {
      return normalized;
    }

    final cached = participantCache[senderId];
    if (cached != null) {
      return cached.displayName;
    }

    return fallback;
  }
}
