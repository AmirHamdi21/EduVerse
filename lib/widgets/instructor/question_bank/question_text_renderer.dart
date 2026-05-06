import 'package:flutter/material.dart';

class QuestionFormattedText extends StatelessWidget {
  const QuestionFormattedText({
    super.key,
    required this.text,
    required this.fallback,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign,
  });

  final String? text;
  final String fallback;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = style ?? DefaultTextStyle.of(context).style;
    final value = text?.trim();
    final source = _normalizeQuestionTextInput(
      value == null || value.isEmpty ? fallback : value,
    );
    final spans = _questionTextSpans(source, resolvedStyle);
    return RichText(
      text: TextSpan(style: resolvedStyle, children: spans),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}

String questionTextForDisplay(String? text, {required String fallback}) {
  final value = text?.trim();
  if (value == null || value.isEmpty) return fallback;
  return _stripQuestionMathDelimiters(_normalizeQuestionTextInput(value));
}

List<TextSpan> _questionTextSpans(String value, TextStyle baseStyle) {
  final spans = <TextSpan>[];
  var index = 0;

  void addPlain(String text) {
    if (text.isEmpty) return;
    spans.add(TextSpan(text: _prettifyLatex(text, trim: false)));
  }

  while (index < value.length) {
    final inlineParen = value.startsWith(r'\(', index);
    final inlineBracket = value.startsWith(r'\[', index);
    if (inlineParen || inlineBracket) {
      final close = inlineParen ? r'\)' : r'\]';
      final closeIndex = value.indexOf(close, index + 2);
      if (closeIndex > index + 2) {
        final math = value.substring(index + 2, closeIndex);
        spans.add(_mathSpan(math, baseStyle));
        index = closeIndex + 2;
        continue;
      }
    }

    if (value.codeUnitAt(index) == 36 && !_isEscaped(value, index)) {
      final isBlock = value.startsWith(r'$$', index);
      final token = isBlock ? r'$$' : r'$';
      final start = index + token.length;
      final closeIndex = _findClosingDollar(value, start, token);
      if (closeIndex > start) {
        final math = value.substring(start, closeIndex);
        spans.add(_mathSpan(math, baseStyle));
        index = closeIndex + token.length;
        continue;
      }
    }

    final nextSpecial = _nextMathStart(value, index + 1);
    final end = nextSpecial == -1 ? value.length : nextSpecial;
    addPlain(value.substring(index, end));
    index = end;
  }

  return spans.isEmpty ? <TextSpan>[TextSpan(text: value)] : spans;
}

TextSpan _mathSpan(String text, TextStyle baseStyle) {
  return TextSpan(
    text: _prettifyLatex(text.trim()),
    style: baseStyle.copyWith(fontStyle: FontStyle.italic),
  );
}

String _stripQuestionMathDelimiters(String value) {
  final buffer = StringBuffer();
  var index = 0;

  while (index < value.length) {
    final inlineParen = value.startsWith(r'\(', index);
    final inlineBracket = value.startsWith(r'\[', index);
    if (inlineParen || inlineBracket) {
      final close = inlineParen ? r'\)' : r'\]';
      final closeIndex = value.indexOf(close, index + 2);
      if (closeIndex > index + 2) {
        buffer.write(
          _prettifyLatex(value.substring(index + 2, closeIndex).trim()),
        );
        index = closeIndex + 2;
        continue;
      }
    }

    if (value.codeUnitAt(index) == 36 && !_isEscaped(value, index)) {
      final isBlock = value.startsWith(r'$$', index);
      final token = isBlock ? r'$$' : r'$';
      final start = index + token.length;
      final closeIndex = _findClosingDollar(value, start, token);
      if (closeIndex > start) {
        buffer.write(_prettifyLatex(value.substring(start, closeIndex).trim()));
        index = closeIndex + token.length;
        continue;
      }
    }

    buffer.write(value[index]);
    index++;
  }

  return _prettifyLatex(buffer.toString());
}

String _normalizeQuestionTextInput(String value) {
  return value.replaceAll(r'\$', r'$');
}

String _prettifyLatex(String value, {bool trim = true}) {
  final keepLeadingSpace =
      !trim && value.isNotEmpty && value.codeUnitAt(0) <= 32;
  final keepTrailingSpace =
      !trim && value.isNotEmpty && value.codeUnitAt(value.length - 1) <= 32;
  var output = value.replaceAll(r'\$', r'$');
  final fractionPattern = RegExp(r'\\frac\s*\{([^{}]+)\}\s*\{([^{}]+)\}');
  var previous = '';
  while (previous != output) {
    previous = output;
    output = output.replaceAllMapped(
      fractionPattern,
      (match) =>
          '(${match.group(1)?.trim() ?? ''})/(${match.group(2)?.trim() ?? ''})',
    );
  }
  final compact = output
      .replaceAll(r'\left', '')
      .replaceAll(r'\right', '')
      .replaceAll(r'\cdot', ' * ')
      .replaceAll(r'\times', ' x ')
      .replaceAll(r'\,', ' ')
      .replaceAll('{', '')
      .replaceAll('}', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (trim) return compact;
  return '${keepLeadingSpace ? ' ' : ''}$compact${keepTrailingSpace ? ' ' : ''}';
}

int _nextMathStart(String value, int start) {
  for (var i = start; i < value.length; i++) {
    if (value.startsWith(r'\(', i) || value.startsWith(r'\[', i)) return i;
    if (value.codeUnitAt(i) == 36 && !_isEscaped(value, i)) return i;
  }
  return -1;
}

int _findClosingDollar(String value, int start, String token) {
  var searchFrom = start;
  while (searchFrom < value.length) {
    final index = value.indexOf(token, searchFrom);
    if (index == -1) return -1;
    if (!_isEscaped(value, index)) return index;
    searchFrom = index + token.length;
  }
  return -1;
}

bool _isEscaped(String value, int index) {
  var slashCount = 0;
  for (var i = index - 1; i >= 0 && value.codeUnitAt(i) == 92; i--) {
    slashCount++;
  }
  return slashCount.isOdd;
}
