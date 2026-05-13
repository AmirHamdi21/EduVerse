import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/exams/exam_export_options_model.dart';
import '../models/exams/exam_full_detail_model.dart';
import '../models/exams/exam_paper_template_model.dart';
import '../widgets/instructor/question_bank/question_text_renderer.dart';

typedef ExamPdfExportProgress = void Function(double progress, String message);

class ExamClientPdfExportResult {
  const ExamClientPdfExportResult({
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String fileName;
  final String mimeType;
  final Uint8List bytes;
}

class ExamClientPdfExportService {
  const ExamClientPdfExportService();

  static const double _pageWidth = 794;
  static const double _pageHeight = 1123;
  static const double _pagePadding = 48;
  static const double _pixelRatio = 2.4;
  static const double _availableContentHeight =
      _pageHeight - (_pagePadding * 2);

  Future<ExamClientPdfExportResult> generate({
    required BuildContext context,
    required ExamFullDetailModel detail,
    required ExamPaperTemplateModel template,
    required ExamExportOptionsModel options,
    ExamPdfExportProgress? onProgress,
  }) async {
    onProgress?.call(0.04, 'Preparing paper content');
    final blocks = _buildBlocks(context, detail, template, options);
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) {
      throw StateError('Export screen was disposed before PDF generation.');
    }
    onProgress?.call(0.1, 'Loading paper media');
    // The mounted guard immediately above protects this context use.
    // ignore: use_build_context_synchronously
    await _precacheExportImages(context, detail);
    if (!context.mounted) {
      throw StateError('Export screen was disposed before PDF generation.');
    }
    onProgress?.call(0.18, 'Paginating exam paper');
    final pages = await _paginate(context, detail, template, blocks, options);
    if (!context.mounted) {
      throw StateError('Export screen was disposed before PDF capture.');
    }
    final pageImages = <Uint8List>[];
    for (var index = 0; index < pages.length; index++) {
      if (!context.mounted) {
        throw StateError('Export screen was disposed before PDF capture.');
      }
      onProgress?.call(
        0.24 + (index / pages.length * 0.56),
        'Rendering page ${index + 1} of ${pages.length}',
      );
      pageImages.add(
        await _capturePage(
          // The method checks context.mounted before each capture.
          // ignore: use_build_context_synchronously
          context,
          _A4ExportPage(
            detail: detail,
            template: template,
            options: options,
            blocks: pages[index],
            pageNumber: index + 1,
            totalPages: pages.length,
            showHeader: index == 0,
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 18));
    }

    onProgress?.call(0.86, 'Building PDF file');
    final document = pw.Document();
    for (final imageBytes in pageImages) {
      final image = pw.MemoryImage(imageBytes);
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(image, fit: pw.BoxFit.fill),
        ),
      );
    }

    onProgress?.call(0.96, 'Finalizing export');
    return ExamClientPdfExportResult(
      fileName: 'exam-${detail.exam.id}.pdf',
      mimeType: 'application/pdf',
      bytes: await document.save(),
    );
  }

  Future<void> _precacheExportImages(
    BuildContext context,
    ExamFullDetailModel detail,
  ) async {
    final urls = <String>{
      for (final item in _allItems(detail)) ...[
        if ((item.sourceGroupImagePreviewUrl ?? '').trim().isNotEmpty)
          item.sourceGroupImagePreviewUrl!.trim(),
        if ((item.questionImagePreviewUrl ?? '').trim().isNotEmpty)
          item.questionImagePreviewUrl!.trim(),
        ..._attachmentImageUrls(item),
      ],
    };
    for (final url in urls) {
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (_) {
        // Keep export usable even when one optional media preview fails.
      }
    }
  }

  List<_ExportBlock> _buildBlocks(
    BuildContext context,
    ExamFullDetailModel detail,
    ExamPaperTemplateModel template,
    ExamExportOptionsModel options,
  ) {
    final l10n = AppLocalizations.of(context);
    final blocks = <_ExportBlock>[];
    var questionNumber = 1;
    for (final section in detail.sections) {
      if (blocks.isNotEmpty && options.pageBreakPerSection) {
        blocks.add(const _ExportBlock.pageBreak());
      }
      blocks.add(
        _ExportBlock(widget: _SectionExportBlock(sectionTitle: section.title)),
      );
      if ((section.instructions ?? '').trim().isNotEmpty) {
        blocks.add(
          _ExportBlock(
            widget: _MathTextBlock(text: section.instructions!, fontSize: 13),
          ),
        );
      }
      for (final item in section.items) {
        blocks.add(
          _ExportBlock(
            widget: _QuestionExportBlock(
              item: item,
              questionNumber: questionNumber++,
              options: options,
              marksLabel: l10n.marks,
            ),
          ),
        );
      }
    }
    for (final item in detail.unsectionedItems) {
      blocks.add(
        _ExportBlock(
          widget: _QuestionExportBlock(
            item: item,
            questionNumber: questionNumber++,
            options: options,
            marksLabel: l10n.marks,
          ),
        ),
      );
    }
    blocks.add(_ExportBlock(widget: _PaperTrailing(template: template)));
    return blocks;
  }

  Future<List<List<_ExportBlock>>> _paginate(
    BuildContext context,
    ExamFullDetailModel detail,
    ExamPaperTemplateModel template,
    List<_ExportBlock> blocks,
    ExamExportOptionsModel options,
  ) async {
    final pages = <List<_ExportBlock>>[];
    var current = <_ExportBlock>[];
    for (final block in blocks) {
      if (block.forcePageBreak) {
        if (current.isNotEmpty) {
          pages.add(current);
          current = <_ExportBlock>[];
        }
        continue;
      }
      final candidate = [...current, block];
      final fits = await _pageFits(
        context,
        detail,
        template,
        options,
        candidate,
        pages.isEmpty,
      );
      if (fits || current.isEmpty) {
        current = candidate;
      } else {
        pages.add(current);
        current = [block];
      }
    }
    if (current.isNotEmpty || pages.isEmpty) {
      pages.add(current);
    }
    return pages;
  }

  Future<bool> _pageFits(
    BuildContext context,
    ExamFullDetailModel detail,
    ExamPaperTemplateModel template,
    ExamExportOptionsModel options,
    List<_ExportBlock> blocks,
    bool firstPage,
  ) async {
    final key = GlobalKey();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _HiddenExportHost(
        child: _A4ExportPage(
          contentKey: key,
          detail: detail,
          template: template,
          options: options,
          blocks: blocks,
          pageNumber: 1,
          totalPages: 1,
          showHeader: firstPage,
          fixedHeight: false,
        ),
      ),
    );
    overlay.insert(entry);
    try {
      await _waitForPaint();
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      final height = box?.size.height ?? double.infinity;
      return height <= _availableContentHeight - 12;
    } finally {
      entry.remove();
    }
  }

  Future<Uint8List> _capturePage(BuildContext context, Widget page) async {
    final key = GlobalKey();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _HiddenExportHost(
        child: RepaintBoundary(key: key, child: page),
      ),
    );
    overlay.insert(entry);
    try {
      await _waitForPaint();
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw StateError('PDF page capture failed.');
      }
      return byteData.buffer.asUint8List();
    } finally {
      entry.remove();
    }
  }

  Future<void> _waitForPaint() async {
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 40));
    await WidgetsBinding.instance.endOfFrame;
  }
}

class _HiddenExportHost extends StatelessWidget {
  const _HiddenExportHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.01,
          child: Material(
            color: Colors.transparent,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: const Size(
                  ExamClientPdfExportService._pageWidth,
                  ExamClientPdfExportService._pageHeight,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _A4ExportPage extends StatelessWidget {
  const _A4ExportPage({
    required this.detail,
    required this.template,
    required this.options,
    required this.blocks,
    required this.pageNumber,
    required this.totalPages,
    required this.showHeader,
    this.contentKey,
    this.fixedHeight = true,
  });

  final ExamFullDetailModel detail;
  final ExamPaperTemplateModel template;
  final ExamExportOptionsModel options;
  final List<_ExportBlock> blocks;
  final int pageNumber;
  final int totalPages;
  final bool showHeader;
  final GlobalKey? contentKey;
  final bool fixedHeight;

  @override
  Widget build(BuildContext context) {
    final page = Container(
      width: ExamClientPdfExportService._pageWidth,
      height: fixedHeight ? ExamClientPdfExportService._pageHeight : null,
      color: Colors.white,
      padding: const EdgeInsets.all(ExamClientPdfExportService._pagePadding),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Times New Roman',
          fontSize: 15,
          height: 1.16,
        ),
        child: Column(
          key: contentKey,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[
              _PaperHeader(template: template, detail: detail),
              const SizedBox(height: 10),
              _PaperMetadataRows(detail: detail, options: options),
              const SizedBox(height: 12),
            ],
            for (final block in blocks)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: block.widget,
              ),
            if (fixedHeight) const Spacer(),
            Text(
              'Page $pageNumber of $totalPages',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
    return Directionality(textDirection: TextDirection.ltr, child: page);
  }
}

class _PaperHeader extends StatelessWidget {
  const _PaperHeader({required this.template, required this.detail});

  final ExamPaperTemplateModel template;
  final ExamFullDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final header = template.headerJson;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ZoneText(raw: header['left'], detail: detail),
            ),
            Expanded(
              child: _ZoneText(
                raw: header['center'],
                detail: detail,
                align: TextAlign.center,
              ),
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _ZoneText(
                  raw: header['right'],
                  detail: detail,
                  align: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black, thickness: 1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ZoneText(raw: header['metadataLeft'], detail: detail),
            ),
            Expanded(
              child: Text(
                detail.exam.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: _ZoneText(
                  raw: header['metadataRight'],
                  detail: detail,
                  align: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black, thickness: 1),
      ],
    );
  }
}

class _PaperMetadataRows extends StatelessWidget {
  const _PaperMetadataRows({required this.detail, required this.options});

  final ExamFullDetailModel detail;
  final ExamExportOptionsModel options;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = [
      if (options.studentNameLine)
        '${l10n.examStudentNameLine}: ______________________________',
      if (options.showCourseCode &&
          ((detail.courseCode ?? '').trim().isNotEmpty ||
              (detail.courseName ?? '').trim().isNotEmpty))
        '${l10n.course}: ${[detail.courseCode, detail.courseName].where((value) => value != null && value.trim().isNotEmpty).join(' - ')}',
      if (options.showInstructorName)
        '${l10n.examInstructorName}: ______________________________',
      if (options.showTotalMarks)
        '${l10n.totalMarks}: ${detail.exam.totalMarks ?? '-'}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows) Text(row, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _PaperTrailing extends StatelessWidget {
  const _PaperTrailing({required this.template});

  final ExamPaperTemplateModel template;

  @override
  Widget build(BuildContext context) {
    final lines = _list(template.trailingJson['lines']);
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        children: [
          for (final line in lines)
            Text(_valueAt([line], 0, ''), textAlign: TextAlign.center),
          if ((template.trailingJson['examiners'] ?? '').toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(
                template.trailingJson['examiners'].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoneText extends StatelessWidget {
  const _ZoneText({
    required this.raw,
    required this.detail,
    this.align = TextAlign.left,
  });

  final dynamic raw;
  final ExamFullDetailModel detail;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.right
          ? CrossAxisAlignment.end
          : align == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        for (final item in _list(raw))
          SizedBox(
            width: double.infinity,
            child: Text(
              _resolveTokens(_valueAt([item], 0, ''), detail),
              textAlign: align,
              textDirection: align == TextAlign.right
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: item is Map && item['bold'] == true
                    ? FontWeight.bold
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionExportBlock extends StatelessWidget {
  const _SectionExportBlock({required this.sectionTitle});

  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    return Text(
      sectionTitle,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }
}

class _QuestionExportBlock extends StatelessWidget {
  const _QuestionExportBlock({
    required this.item,
    required this.questionNumber,
    required this.options,
    required this.marksLabel,
  });

  final ExamSnapshotItemModel item;
  final int questionNumber;
  final ExamExportOptionsModel options;
  final String marksLabel;

  @override
  Widget build(BuildContext context) {
    final includeAnswers = options.includeAnswerKey;
    final snapshot = _snapshot(item);
    final answerWidgets = includeAnswers
        ? _answerWidgets(snapshot)
        : const <Widget>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((item.sourceGroupPrompt ?? '').trim().isNotEmpty)
          _MathTextBlock(text: item.sourceGroupPrompt!, fontSize: 15),
        if ((item.sourceGroupImagePreviewUrl ?? '').trim().isNotEmpty)
          _ExportImage(url: item.sourceGroupImagePreviewUrl!),
        _MathTextBlock(
          text: '$questionNumber. ${item.questionText}',
          fontSize: 16,
          bold: true,
        ),
        if ((item.questionImagePreviewUrl ?? '').trim().isNotEmpty)
          _ExportImage(url: item.questionImagePreviewUrl!),
        for (final url in _attachmentImageUrls(item)) _ExportImage(url: url),
        if (options.showQuestionMarks)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$marksLabel: ${item.marks ?? '-'}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ...answerWidgets,
      ],
    );
  }
}

class _MathTextBlock extends StatelessWidget {
  const _MathTextBlock({
    required this.text,
    this.fontSize = 15,
    this.bold = false,
  });

  final String text;
  final double fontSize;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return QuestionFormattedText(
      text: text,
      fallback: '',
      style: TextStyle(
        color: Colors.black,
        fontFamily: 'Times New Roman',
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        height: 1.16,
      ),
    );
  }
}

class _ExportImage extends StatelessWidget {
  const _ExportImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240, maxWidth: 640),
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _ExportBlock {
  const _ExportBlock({required this.widget}) : forcePageBreak = false;

  const _ExportBlock.pageBreak()
    : widget = const SizedBox.shrink(),
      forcePageBreak = true;

  final Widget widget;
  final bool forcePageBreak;
}

List<Widget> _answerWidgets(Map<String, dynamic> snapshot) {
  final widgets = <Widget>[];
  final options = _asList(
    snapshot['optionsJson'],
  ).whereType<Map>().map((value) => Map<String, dynamic>.from(value));
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  var index = 0;
  for (final option in options) {
    final text = option['optionText']?.toString() ?? '';
    final correct = option['isCorrect'] == true || option['isCorrect'] == 1;
    widgets.add(
      _MathTextBlock(
        text: '${letters[index]}.$text${correct ? ' (correct)' : ''}',
        fontSize: 13,
      ),
    );
    index++;
  }
  final fillBlanks = _asList(
    snapshot['fillBlanksJson'],
  ).whereType<Map>().map((value) => Map<String, dynamic>.from(value));
  for (final blank in fillBlanks) {
    widgets.add(
      _MathTextBlock(
        text: '${blank['blankKey'] ?? ''}: ${blank['acceptableAnswer'] ?? ''}',
        fontSize: 13,
      ),
    );
  }
  final expected = snapshot['expectedAnswerText']?.toString().trim();
  if (expected != null && expected.isNotEmpty) {
    widgets.add(
      _MathTextBlock(text: 'Expected Answer: $expected', fontSize: 13),
    );
  }
  final hints = snapshot['hints']?.toString().trim();
  if (hints != null && hints.isNotEmpty) {
    widgets.add(_MathTextBlock(text: 'Hints: $hints', fontSize: 13));
  }
  return widgets;
}

List<ExamSnapshotItemModel> _allItems(ExamFullDetailModel detail) => [
  for (final section in detail.sections) ...section.items,
  ...detail.unsectionedItems,
];

Map<String, dynamic> _snapshot(ExamSnapshotItemModel item) {
  final rawSnapshot = item.raw['snapshot'];
  if (rawSnapshot is Map<String, dynamic>) return rawSnapshot;
  if (rawSnapshot is Map) return Map<String, dynamic>.from(rawSnapshot);
  return item.raw;
}

List<String> _attachmentImageUrls(ExamSnapshotItemModel item) {
  final snapshot = _snapshot(item);
  return _asList(snapshot['attachmentsJson'])
      .whereType<Map>()
      .map((value) => Map<String, dynamic>.from(value))
      .map(
        (attachment) =>
            attachment['previewUrl'] ??
            attachment['questionImagePreviewUrl'] ??
            attachment['imageUrl'] ??
            attachment['downloadUrl'],
      )
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .map((value) => value.trim())
      .toList();
}

List<dynamic> _list(dynamic value) => value is List ? value : const <dynamic>[];

List<dynamic> _asList(dynamic value) =>
    value is List ? value : const <dynamic>[];

String _valueAt(List<dynamic> values, int index, String fallback) {
  if (index >= values.length) return fallback;
  final value = values[index];
  if (value is Map) {
    return (value['text'] ?? value['value'] ?? fallback).toString();
  }
  return value?.toString() ?? fallback;
}

String _resolveTokens(String value, ExamFullDetailModel detail) {
  final now = DateTime.now();
  return value
      .replaceAll('{examTitle}', detail.exam.title)
      .replaceAll('{courseCode}', detail.courseCode ?? '')
      .replaceAll('{courseName}', detail.courseName ?? '')
      .replaceAll('{duration}', '${detail.durationMinutes ?? ''}')
      .replaceAll('{totalMarks}', '${detail.exam.totalMarks ?? ''}')
      .replaceAll('{date}', now.toIso8601String().split('T').first)
      .replaceAll('{academicYear}', '${now.year}/${now.year + 1}');
}
