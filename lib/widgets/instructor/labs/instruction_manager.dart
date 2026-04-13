import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../bloc/instructor/lab_detail_cubit.dart';
import '../../../models/core/lab_instruction_model.dart';
import 'instruction_file_uploader.dart';

class InstructionManager extends StatefulWidget {
  const InstructionManager({
    super.key,
    required this.labId,
    required this.instructions,
    required this.canManage,
    this.isUpdating = false,
  });

  final String labId;
  final List<LabInstructionModel> instructions;
  final bool canManage;
  final bool isUpdating;

  @override
  State<InstructionManager> createState() => _InstructionManagerState();
}

class _InstructionManagerState extends State<InstructionManager> {
  final TextEditingController _newInstructionController =
      TextEditingController();
  final Set<int> _editingInstructionIds = <int>{};
  final Map<int, TextEditingController> _editControllers =
      <int, TextEditingController>{};

  @override
  void dispose() {
    _newInstructionController.dispose();
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LabDetailCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.canManage) ...<Widget>[
          TextField(
            controller: _newInstructionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Add text-based instruction (Markdown)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              FilledButton.icon(
                onPressed: widget.isUpdating
                    ? null
                    : () => _addInstruction(cubit),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Instruction'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InstructionFileUploader(
                  enabled: !widget.isUpdating,
                  nextOrderIndex: widget.instructions.length,
                  onUpload:
                      (
                        File file,
                        int orderIndex,
                        void Function(double progress) onProgress,
                      ) async {
                        await cubit.uploadInstructionFile(
                          widget.labId,
                          file,
                          orderIndex,
                          onProgress: onProgress,
                        );
                      },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (widget.instructions.isEmpty)
          const _EmptyInstructionState()
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.instructions.length,
            onReorder: widget.canManage ? _onReorder : (_, __) {},
            itemBuilder: (context, index) {
              final instruction = widget.instructions[index];
              return _buildInstructionCard(
                context,
                cubit,
                index,
                instruction,
                key: ValueKey<String>('instruction-${instruction.id}'),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInstructionCard(
    BuildContext context,
    LabDetailCubit cubit,
    int index,
    LabInstructionModel instruction, {
    required Key key,
  }) {
    final isEditing = _editingInstructionIds.contains(instruction.id);
    final isTextInstruction =
        instruction.instructionText != null &&
        instruction.instructionText!.trim().isNotEmpty;
    final file = instruction.file;

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (widget.canManage)
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.drag_indicator_rounded),
                    ),
                  ),
                SizedBox(
                  width: 58,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file != null ? file.fileName : 'Text instruction',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (widget.canManage)
                  IconButton(
                    tooltip: 'Move up',
                    onPressed: index == 0 ? null : () => _moveBy(index, -1),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                if (widget.canManage)
                  IconButton(
                    tooltip: 'Move down',
                    onPressed: index == widget.instructions.length - 1
                        ? null
                        : () => _moveBy(index, 1),
                    icon: const Icon(Icons.arrow_downward_rounded),
                  ),
              ],
            ),
            if (isTextInstruction) ...<Widget>[
              const SizedBox(height: 8),
              if (!isEditing)
                MarkdownBody(data: instruction.instructionText!.trim())
              else
                TextField(
                  controller: _controllerForInstruction(instruction),
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Edit markdown instruction',
                  ),
                ),
            ],
            if (file != null) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  FilledButton.tonalIcon(
                    onPressed: () => _showPreview(
                      context,
                      file.iframeUrl.trim().isNotEmpty
                          ? file.iframeUrl
                          : file.webViewLink,
                      file.downloadUrl,
                    ),
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Preview'),
                  ),
                  TextButton.icon(
                    onPressed: () => _openUrl(file.webViewLink),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open in Drive'),
                  ),
                  TextButton.icon(
                    onPressed: () => _openUrl(file.downloadUrl),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download'),
                  ),
                ],
              ),
            ],
            if (widget.canManage)
              Row(
                children: <Widget>[
                  if (isTextInstruction && !isEditing)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _editingInstructionIds.add(instruction.id);
                        });
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  if (isTextInstruction && isEditing)
                    TextButton.icon(
                      onPressed: () => _saveInstructionEdit(cubit, instruction),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save'),
                    ),
                  if (isTextInstruction && isEditing)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _editingInstructionIds.remove(instruction.id);
                          _editControllers.remove(instruction.id)?.dispose();
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Cancel'),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(cubit, instruction),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  TextEditingController _controllerForInstruction(
    LabInstructionModel instruction,
  ) {
    return _editControllers.putIfAbsent(
      instruction.id,
      () => TextEditingController(text: instruction.instructionText ?? ''),
    );
  }

  Future<void> _addInstruction(LabDetailCubit cubit) async {
    final text = _newInstructionController.text.trim();
    if (text.isEmpty) {
      return;
    }

    await cubit.addTextInstruction(
      widget.labId,
      text,
      widget.instructions.length,
    );
    if (!mounted) {
      return;
    }

    _newInstructionController.clear();
  }

  Future<void> _saveInstructionEdit(
    LabDetailCubit cubit,
    LabInstructionModel instruction,
  ) async {
    final controller = _editControllers[instruction.id];
    final nextText = controller?.text.trim();
    if (nextText == null || nextText.isEmpty) {
      return;
    }

    await cubit.updateInstruction(
      widget.labId,
      instruction.id.toString(),
      nextText,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _editingInstructionIds.remove(instruction.id);
      _editControllers.remove(instruction.id)?.dispose();
    });
  }

  Future<void> _confirmDelete(
    LabDetailCubit cubit,
    LabInstructionModel instruction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete instruction?'),
          content: const Text('This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await cubit.deleteInstruction(widget.labId, instruction.id.toString());
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (!widget.canManage) {
      return;
    }

    final next = List<LabInstructionModel>.from(widget.instructions);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final moved = next.removeAt(oldIndex);
    next.insert(newIndex, moved);
    _requestReorder(next);
  }

  void _moveBy(int index, int delta) {
    final target = index + delta;
    _moveToIndex(index, target);
  }

  void _moveToIndex(int currentIndex, int targetIndex) {
    if (!widget.canManage) {
      return;
    }

    if (targetIndex < 0 || targetIndex >= widget.instructions.length) {
      return;
    }

    if (currentIndex == targetIndex) {
      return;
    }

    final next = List<LabInstructionModel>.from(widget.instructions);
    final moved = next.removeAt(currentIndex);
    next.insert(targetIndex, moved);
    _requestReorder(next);
  }

  void _requestReorder(List<LabInstructionModel> ordered) {
    context.read<LabDetailCubit>().reorderInstructions(
      widget.labId,
      ordered.map((item) => item.id.toString()).toList(growable: false),
    );
  }

  Future<void> _showPreview(
    BuildContext context,
    String previewUrl,
    String fallbackDownloadUrl,
  ) async {
    final uri = Uri.tryParse(previewUrl);
    if (uri == null) {
      await _openUrl(fallbackDownloadUrl);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 900,
            height: 620,
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Expanded(
                  child: WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..loadRequest(uri),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _EmptyInstructionState extends StatelessWidget {
  const _EmptyInstructionState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: const <Widget>[
            Icon(Icons.menu_book_outlined, size: 46),
            SizedBox(height: 8),
            Text('No instructions added yet.'),
          ],
        ),
      ),
    );
  }
}
