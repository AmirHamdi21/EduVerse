import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/ai_assistant_models.dart';

class AiConversationRepository {
  static const String _indexPrefix = 'ai_assistant_conversation_index_v1_';

  Future<List<AiConversationIndexEntry>> loadIndex({
    required int userId,
    required AiAssistantRole role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_indexKey(userId, role));
    if (raw == null || raw.trim().isEmpty) {
      return const <AiConversationIndexEntry>[];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                AiConversationIndexEntry.fromJson(item.cast<String, dynamic>()),
          )
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return const <AiConversationIndexEntry>[];
    }
  }

  Future<void> saveConversation(AiConversation conversation) async {
    final directory = await _conversationDirectory(
      conversation.userId,
      conversation.role,
    );
    await directory.create(recursive: true);
    final tempFile = File(
      '${_conversationPath(directory.path, conversation.id)}.tmp',
    );
    final targetFile = File(_conversationPath(directory.path, conversation.id));
    await tempFile.writeAsString(conversation.encode(), flush: true);
    await tempFile.rename(targetFile.path);

    final index = await loadIndex(
      userId: conversation.userId,
      role: conversation.role,
    );
    final nextIndex = <AiConversationIndexEntry>[
      AiConversationIndexEntry.fromConversation(conversation),
      ...index.where((entry) => entry.id != conversation.id),
    ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _saveIndex(conversation.userId, conversation.role, nextIndex);
  }

  Future<AiConversation?> loadConversation({
    required int userId,
    required AiAssistantRole role,
    required String conversationId,
  }) async {
    final directory = await _conversationDirectory(userId, role);
    final file = File(_conversationPath(directory.path, conversationId));
    if (!await file.exists()) {
      return null;
    }
    try {
      final raw = await file.readAsString();
      return AiConversation.decode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteConversation({
    required int userId,
    required AiAssistantRole role,
    required String conversationId,
  }) async {
    final directory = await _conversationDirectory(userId, role);
    final file = File(_conversationPath(directory.path, conversationId));
    if (await file.exists()) {
      await file.delete();
    }
    final index = await loadIndex(userId: userId, role: role);
    await _saveIndex(
      userId,
      role,
      index.where((entry) => entry.id != conversationId).toList(),
    );
  }

  Future<void> clearAll({
    required int userId,
    required AiAssistantRole role,
  }) async {
    final directory = await _conversationDirectory(userId, role);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_indexKey(userId, role));
  }

  Future<String> exportConversation(AiConversation conversation) async {
    final buffer = StringBuffer()
      ..writeln(conversation.title)
      ..writeln()
      ..writeln(
        'Provider: ${conversation.settings.providerId.name} / ${conversation.settings.modelId}',
      )
      ..writeln();

    for (final message in conversation.messages) {
      if (message.content.trim().isEmpty) {
        continue;
      }
      buffer
        ..writeln(
          '[${message.author.name}] ${message.createdAt.toLocal().toIso8601String()}',
        )
        ..writeln(message.content.trim())
        ..writeln();
    }

    return buffer.toString().trim();
  }

  Future<void> _saveIndex(
    int userId,
    AiAssistantRole role,
    List<AiConversationIndexEntry> entries,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _indexKey(userId, role),
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }

  String _indexKey(int userId, AiAssistantRole role) {
    return '$_indexPrefix${role.name}_$userId';
  }

  Future<Directory> _conversationDirectory(
    int userId,
    AiAssistantRole role,
  ) async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory(
      '${documents.path}${Platform.pathSeparator}ai_assistant${Platform.pathSeparator}${role.name}_${userId.toString()}',
    );
  }

  String _conversationPath(String directoryPath, String conversationId) {
    return '$directoryPath${Platform.pathSeparator}$conversationId.json';
  }
}
