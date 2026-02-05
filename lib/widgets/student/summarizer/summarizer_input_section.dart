import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/summarizer/summarizer_cubit.dart';
import '../../../bloc/summarizer/summarizer_state.dart';
import '../../../generated_l10n/app_localizations.dart';

class SummarizerInputSection extends StatefulWidget {
  final bool isDark;

  const SummarizerInputSection({
    super.key,
    required this.isDark,
  });

  @override
  State<SummarizerInputSection> createState() => _SummarizerInputSectionState();
}

class _SummarizerInputSectionState extends State<SummarizerInputSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final cubit = context.read<SummarizerCubit>();
      cubit.setActiveInputSource(
        _tabController.index == 0 ? InputSource.file : InputSource.text,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tab selector
          _buildTabSelector(l10n),
          const SizedBox(height: 16),
          // Tab content
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: BlocBuilder<SummarizerCubit, SummarizerState>(
              buildWhen: (previous, current) =>
                  previous.activeInputSource != current.activeInputSource,
              builder: (context, state) {
                return state.activeInputSource == InputSource.file
                    ? _buildFileUploadCard(l10n)
                    : _buildTextInputCard(l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(AppLocalizations l10n) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E2939) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor:
            widget.isDark ? const Color(0xFF99A1AF) : const Color(0xFF4A5565),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload_file_rounded, size: 18),
                const SizedBox(width: 8),
                Text(l10n.summarizerUploadFile),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_note_rounded, size: 18),
                const SizedBox(width: 8),
                Text(l10n.summarizerPasteText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadCard(AppLocalizations l10n) {
    return BlocBuilder<SummarizerCubit, SummarizerState>(
      buildWhen: (previous, current) =>
          previous.uploadedFile != current.uploadedFile,
      builder: (context, state) {
        if (state.uploadedFile != null) {
          return _buildUploadedFileCard(state, l10n);
        }
        return _buildFileDropZone(l10n);
      },
    );
  }

  Widget _buildFileDropZone(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF364153) : const Color(0xFFD1D5DC),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.read<SummarizerCubit>().uploadFile(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              children: [
                // Upload icon with gradient
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2B7FFF), Color(0xFF155DFC)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2B7FFF).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_upload_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.summarizerUploadTitle,
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF101828),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.summarizerDragDrop,
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFF99A1AF)
                        : const Color(0xFF4A5565),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                // Browse files button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF1E2939).withValues(alpha: 0.5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isDark
                          ? const Color(0xFF364153)
                          : const Color(0xFFD1D5DC),
                    ),
                  ),
                  child: Text(
                    l10n.summarizerBrowseFiles,
                    style: TextStyle(
                      color: widget.isDark
                          ? const Color(0xFFFAFAFA)
                          : const Color(0xFF0A0A0A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Supported formats
                Text(
                  l10n.summarizerSupportedFormats,
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedFileCard(SummarizerState state, AppLocalizations l10n) {
    final file = state.uploadedFile!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // File icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.2),
                  const Color(0xFF059669).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getFileIcon(file.extension),
              color: const Color(0xFF10B981),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF101828),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF10B981),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${l10n.summarizerFileReady} • ${file.formattedSize}',
                        style: TextStyle(
                          color: widget.isDark
                              ? const Color(0xFF99A1AF)
                              : const Color(0xFF4A5565),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            onPressed: () => context.read<SummarizerCubit>().clearUploadedFile(),
            icon: Icon(
              Icons.close_rounded,
              color: widget.isDark
                  ? const Color(0xFF99A1AF)
                  : const Color(0xFF64748B),
            ),
            style: IconButton.styleFrom(
              backgroundColor: widget.isDark
                  ? const Color(0xFF1E2939)
                  : const Color(0xFFF3F4F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputCard(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF101828) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF1E2939) : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 180, maxHeight: 250),
            child: BlocBuilder<SummarizerCubit, SummarizerState>(
              buildWhen: (previous, current) =>
                  previous.textInput != current.textInput,
              builder: (context, state) {
                if (_textController.text != state.textInput) {
                  _textController.text = state.textInput;
                }
                return TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  onChanged: (value) {
                    context.read<SummarizerCubit>().setTextInput(value);
                  },
                  style: TextStyle(
                    color: widget.isDark
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF101828),
                    fontSize: 15,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.summarizerPasteHint,
                    hintStyle: TextStyle(
                      color: widget.isDark
                          ? const Color(0xFFA1A1A1)
                          : const Color(0xFF717182),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                );
              },
            ),
          ),
          // Character count and clear button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF1E2939)
                  : const Color(0xFFF9FAFB),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: BlocBuilder<SummarizerCubit, SummarizerState>(
              buildWhen: (previous, current) =>
                  previous.textInput != current.textInput,
              builder: (context, state) {
                final charCount = state.textInput.length;
                final wordCount = state.textInput.isEmpty
                    ? 0
                    : state.textInput.trim().split(RegExp(r'\s+')).length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$charCount ${l10n.summarizerCharacters} • $wordCount ${l10n.summarizerWords}',
                      style: TextStyle(
                        color: widget.isDark
                            ? const Color(0xFF64748B)
                            : const Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                    if (state.textInput.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _textController.clear();
                          context.read<SummarizerCubit>().setTextInput('');
                        },
                        child: Text(
                          l10n.summarizerClear,
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'txt':
        return Icons.article_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
