import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class InstructionFileUploader extends StatefulWidget {
  const InstructionFileUploader({
    super.key,
    required this.nextOrderIndex,
    required this.onUpload,
    this.enabled = true,
  });

  final int nextOrderIndex;
  final bool enabled;
  final Future<void> Function(
    File file,
    int orderIndex,
    void Function(double progress) onProgress,
  )
  onUpload;

  @override
  State<InstructionFileUploader> createState() =>
      _InstructionFileUploaderState();
}

class _InstructionFileUploaderState extends State<InstructionFileUploader> {
  double _progress = 0;
  bool _isUploading = false;
  String? _error;
  File? _lastFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: !widget.enabled || _isUploading ? null : _pickAndUpload,
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(
            _isUploading ? 'Uploading...' : 'Upload Instruction File',
          ),
        ),
        if (_isUploading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(value: _progress),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: _lastFile == null || _isUploading
                      ? null
                      : () => _uploadFile(_lastFile!),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _pickAndUpload() async {
    final picked = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (picked == null || picked.files.isEmpty) {
      return;
    }

    final path = picked.files.single.path;
    if (path == null || path.trim().isEmpty) {
      setState(() {
        _error = 'Unable to access selected file.';
      });
      return;
    }

    final file = File(path);
    _lastFile = file;
    await _uploadFile(file);
  }

  Future<void> _uploadFile(File file) async {
    setState(() {
      _isUploading = true;
      _progress = 0;
      _error = null;
    });

    try {
      await widget.onUpload(file, widget.nextOrderIndex, (progress) {
        if (!mounted) {
          return;
        }
        setState(() {
          _progress = progress;
        });
      });

      if (!mounted) {
        return;
      }

      setState(() {
        _isUploading = false;
        _progress = 0;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isUploading = false;
        _error = error.toString();
      });
    }
  }
}
