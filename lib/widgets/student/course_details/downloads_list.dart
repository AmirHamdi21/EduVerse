import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadsList extends StatefulWidget {
  const DownloadsList({super.key});

  @override
  State<DownloadsList> createState() => _DownloadsListState();
}

class _DownloadsListState extends State<DownloadsList> {
  bool _isLoading = true;
  List<_DownloadEntry> _entries = const <_DownloadEntry>[];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'course_material_downloads';
    final rows = prefs.getStringList(key) ?? <String>[];

    final parsed = <_DownloadEntry>[];
    for (final row in rows) {
      try {
        final map = jsonDecode(row) as Map<String, dynamic>;
        parsed.add(_DownloadEntry.fromJson(map));
      } catch (_) {
        // Ignore malformed rows.
      }
    }

    if (!mounted) return;
    setState(() {
      _entries = parsed;
      _isLoading = false;
    });
  }

  Future<void> _openEntry(_DownloadEntry entry) async {
    final result = await OpenFile.open(entry.filePath);
    if (!mounted) return;

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message.isEmpty ? 'Unable to open file.' : result.message,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_entries.isEmpty) {
      return const Center(child: Text('No offline downloads yet.'));
    }

    return ListView.separated(
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return ListTile(
          leading: const Icon(Icons.download_done_rounded),
          title: Text(entry.title),
          subtitle: Text(entry.savedAtLabel),
          trailing: const Icon(Icons.open_in_new_rounded),
          onTap: () => _openEntry(entry),
        );
      },
    );
  }
}

class _DownloadEntry {
  final String materialId;
  final String title;
  final String filePath;
  final DateTime savedAt;

  const _DownloadEntry({
    required this.materialId,
    required this.title,
    required this.filePath,
    required this.savedAt,
  });

  factory _DownloadEntry.fromJson(Map<String, dynamic> json) {
    return _DownloadEntry(
      materialId: json['materialId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Downloaded file',
      filePath: json['filePath']?.toString() ?? '',
      savedAt:
          DateTime.tryParse(json['savedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String get savedAtLabel {
    final month = savedAt.month.toString().padLeft(2, '0');
    final day = savedAt.day.toString().padLeft(2, '0');
    final hour = savedAt.hour.toString().padLeft(2, '0');
    final minute = savedAt.minute.toString().padLeft(2, '0');
    return '$month/$day ${savedAt.year} • $hour:$minute';
  }
}
