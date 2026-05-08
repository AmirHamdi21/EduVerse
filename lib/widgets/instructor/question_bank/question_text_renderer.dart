import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class QuestionFormattedText extends StatelessWidget {
  const QuestionFormattedText({
    super.key,
    required this.text,
    required this.fallback,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign,
    this.clipMathToMaxLines = false,
  });

  final String? text;
  final String fallback;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final bool clipMathToMaxLines;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = style ?? DefaultTextStyle.of(context).style;
    final value = text?.trim();
    final source = _normalizeQuestionTextInput(
      value == null || value.isEmpty ? fallback : value,
    );
    final segments = _questionTextSegments(source);
    final hasMath = segments.any((segment) => segment.isMath);
    if (!hasMath) {
      return RichText(
        text: TextSpan(
          style: resolvedStyle,
          children: [TextSpan(text: _prettifyLatex(source, trim: false))],
        ),
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign ?? TextAlign.start,
      );
    }

    if (clipMathToMaxLines && maxLines != null) {
      return Text(
        _stripQuestionMathDelimiters(source),
        maxLines: maxLines,
        overflow: overflow == TextOverflow.clip
            ? TextOverflow.ellipsis
            : overflow,
        textAlign: textAlign,
        style: resolvedStyle,
      );
    }

    if (maxLines == 1) {
      return Text(
        _stripQuestionMathDelimiters(source),
        maxLines: 1,
        overflow: overflow,
        textAlign: textAlign,
        style: resolvedStyle,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return _MathAwareText(
          segments: segments,
          style: resolvedStyle,
          textAlign: textAlign ?? TextAlign.start,
          maxWidth: constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : double.infinity,
        );
      },
    );
  }
}

String questionTextForDisplay(String? text, {required String fallback}) {
  final value = text?.trim();
  if (value == null || value.isEmpty) return fallback;
  return _stripQuestionMathDelimiters(_normalizeQuestionTextInput(value));
}

class _MathAwareText extends StatelessWidget {
  const _MathAwareText({
    required this.segments,
    required this.style,
    required this.textAlign,
    required this.maxWidth,
  });

  final List<_QuestionTextSegment> segments;
  final TextStyle style;
  final TextAlign textAlign;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];
    final inline = <_QuestionTextSegment>[];

    void flushInline() {
      if (inline.isEmpty) return;
      blocks.add(
        Text.rich(
          TextSpan(
            style: style,
            children: inline.map((segment) {
              if (!segment.isMath) {
                return TextSpan(
                  text: _prettifyLatex(segment.text, trim: false),
                );
              }
              return WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _InlineMath(text: segment.text, style: style),
              );
            }).toList(),
          ),
          textAlign: textAlign,
        ),
      );
      inline.clear();
    }

    for (final segment in segments) {
      if (segment.display) {
        flushInline();
        blocks.add(_DisplayMath(text: segment.text, style: style));
      } else {
        inline.add(segment);
      }
    }
    flushInline();

    if (blocks.length == 1) return blocks.single;
    return Column(
      crossAxisAlignment: _crossAxisFor(textAlign),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: blocks[i],
          ),
        ],
      ],
    );
  }
}

class _InlineMath extends StatelessWidget {
  const _InlineMath({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Math.tex(
      _normalizeLatexExpression(text),
      mathStyle: MathStyle.text,
      textStyle: style.copyWith(fontStyle: FontStyle.normal),
      onErrorFallback: (_) => Text(
        _prettifyLatex(text),
        style: style.copyWith(fontStyle: FontStyle.italic),
      ),
    );
  }
}

class _DisplayMath extends StatelessWidget {
  const _DisplayMath({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Math.tex(
          _normalizeLatexExpression(text),
          mathStyle: MathStyle.display,
          textStyle: style.copyWith(fontStyle: FontStyle.normal),
          onErrorFallback: (_) => Text(
            _prettifyLatex(text),
            style: style.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }
}

CrossAxisAlignment _crossAxisFor(TextAlign textAlign) {
  switch (textAlign) {
    case TextAlign.center:
      return CrossAxisAlignment.center;
    case TextAlign.right:
    case TextAlign.end:
      return CrossAxisAlignment.end;
    case TextAlign.left:
    case TextAlign.start:
    case TextAlign.justify:
      return CrossAxisAlignment.start;
  }
}

class _QuestionTextSegment {
  const _QuestionTextSegment.text(this.text) : isMath = false, display = false;

  const _QuestionTextSegment.math(this.text, {this.display = false})
    : isMath = true;

  final String text;
  final bool isMath;
  final bool display;
}

List<_QuestionTextSegment> _questionTextSegments(String value) {
  final normalized = _normalizeQuestionTextInput(value);
  final segments = <_QuestionTextSegment>[];
  var index = 0;

  void addText(String text) {
    if (text.isEmpty) return;
    segments.addAll(_splitTextAroundAutoMath(text));
  }

  while (index < normalized.length) {
    final inlineParen = normalized.startsWith(r'\(', index);
    final inlineBracket = normalized.startsWith(r'\[', index);
    if (inlineParen || inlineBracket) {
      final close = inlineParen ? r'\)' : r'\]';
      final closeIndex = normalized.indexOf(close, index + 2);
      if (closeIndex > index + 2) {
        segments.add(
          _QuestionTextSegment.math(
            normalized.substring(index + 2, closeIndex),
            display: inlineBracket,
          ),
        );
        index = closeIndex + 2;
        continue;
      }
    }

    if (normalized.codeUnitAt(index) == 36 && !_isEscaped(normalized, index)) {
      final isBlock = normalized.startsWith(r'$$', index);
      final token = isBlock ? r'$$' : r'$';
      final start = index + token.length;
      final closeIndex = _findClosingDollar(normalized, start, token);
      if (closeIndex > start) {
        segments.add(
          _QuestionTextSegment.math(
            normalized.substring(start, closeIndex),
            display: isBlock,
          ),
        );
        index = closeIndex + token.length;
        continue;
      }
    }

    if (normalized.startsWith(r'\begin{', index)) {
      final end = _rawMathRunEnd(normalized, index);
      if (end > index) {
        segments.add(
          _QuestionTextSegment.math(
            normalized.substring(index, end),
            display: true,
          ),
        );
        index = end;
        continue;
      }
    }

    final nextSpecial = _nextMathStart(normalized, index + 1);
    final end = nextSpecial == -1 ? normalized.length : nextSpecial;
    addText(normalized.substring(index, end));
    index = end;
  }

  return segments.isEmpty
      ? <_QuestionTextSegment>[_QuestionTextSegment.text(value)]
      : segments;
}

List<_QuestionTextSegment> _splitTextAroundAutoMath(String value) {
  final segments = <_QuestionTextSegment>[];
  var index = 0;
  final markers = RegExp(
    r'(\\(?:dfrac|tfrac|frac|sqrt|int|sum|prod|lim|dot|ddot|hat|bar|vec|alpha|beta|gamma|delta|epsilon|theta|lambda|mu|pi|sigma|omega|Omega|Delta|infty|quad|leq|geq|neq|times|cdot)|[A-Za-z0-9)\]}][_^])',
  );

  while (index < value.length) {
    final match = markers.firstMatch(value.substring(index));
    if (match == null) {
      segments.add(_QuestionTextSegment.text(value.substring(index)));
      break;
    }

    final markerStart = index + match.start;
    final start = _autoMathStart(value, markerStart);
    final end = _autoMathEnd(value, markerStart);
    if (start > index) {
      segments.add(_QuestionTextSegment.text(value.substring(index, start)));
    }
    final candidate = value.substring(start, end).trim();
    if (_looksLikeMath(candidate)) {
      segments.add(_QuestionTextSegment.math(candidate));
    } else {
      segments.add(_QuestionTextSegment.text(candidate));
    }
    index = end;
  }

  return segments;
}

int _autoMathStart(String value, int markerStart) {
  var start = markerStart;
  while (start > 0) {
    final char = value[start - 1];
    if (RegExp(r'[A-Za-z0-9_{}\\^+\-*/=()[\]., ]').hasMatch(char)) {
      start--;
      continue;
    }
    break;
  }
  final fragment = value.substring(start, markerStart);
  final assignment = RegExp(
    r'([A-Za-z](?:\s*\([^)]*\))?\s*=)\s*$',
  ).firstMatch(fragment);
  if (assignment != null) {
    return start + assignment.start;
  }

  final boundaries = RegExp(
    r'\b(?:where|with|and|or|the|a|an|is|are|was|were|be|to|for|by|of|in|on|from|then|such that)\s+',
    caseSensitive: false,
  ).allMatches(fragment);
  if (boundaries.isNotEmpty) {
    return start + boundaries.last.end;
  }
  return start;
}

int _autoMathEnd(String value, int markerStart) {
  var end = markerStart;
  while (end < value.length) {
    final remaining = value.substring(end);
    final boundary = RegExp(
      r'^(?:,\s+(?:where|when|then|and the|and determine)|\.\s+[A-Z]|;\s+[A-Z]|\s+(?:is minimized|is desired|such that|where)\b)',
    ).firstMatch(remaining);
    if (boundary != null) break;
    final char = value[end];
    if (char == '\n') break;
    end++;
  }
  return end;
}

bool _looksLikeMath(String value) {
  if (value.length < 2) return false;
  return value.contains(r'\') ||
      value.contains('_') ||
      value.contains('^') ||
      RegExp(r'[A-Za-z]\s*=').hasMatch(value);
}

String _stripQuestionMathDelimiters(String value) {
  final buffer = StringBuffer();
  for (final segment in _questionTextSegments(value)) {
    buffer.write(segment.isMath ? _prettifyLatex(segment.text) : segment.text);
  }
  return _prettifyLatex(buffer.toString());
}

String _normalizeQuestionTextInput(String value) {
  return _normalizeLatexExpression(value.replaceAll(r'\$', r'$'));
}

String _normalizeLatexExpression(String value) {
  var output = value;
  output = output.replaceAllMapped(
    RegExp(
      r'\\(begin|end)(bmatrix|pmatrix|matrix|vmatrix|Vmatrix|Bmatrix|cases|array|aligned|align|gathered)\b',
    ),
    (match) => '\\${match.group(1)}{${match.group(2)}}',
  );
  output = output
      .replaceAll(RegExp(r'\\begin\s*bmatrix'), r'\begin{bmatrix}')
      .replaceAll(RegExp(r'\\end\s*bmatrix'), r'\end{bmatrix}')
      .replaceAll(RegExp(r'\\begin\s*pmatrix'), r'\begin{pmatrix}')
      .replaceAll(RegExp(r'\\end\s*pmatrix'), r'\end{pmatrix}')
      .replaceAll(RegExp(r'\\begin\s*matrix'), r'\begin{bmatrix}')
      .replaceAll(RegExp(r'\\end\s*matrix'), r'\end{bmatrix}')
      .replaceAll(RegExp(r'\\beginmatrix'), r'\begin{bmatrix}')
      .replaceAll(RegExp(r'\\endmatrix'), r'\end{bmatrix}')
      .replaceAll(RegExp(r'\\beginbmatrix'), r'\begin{bmatrix}')
      .replaceAll(RegExp(r'\\endbmatrix'), r'\end{bmatrix}')
      .replaceAll(RegExp(r'\\beginpmatrix'), r'\begin{pmatrix}')
      .replaceAll(RegExp(r'\\endpmatrix'), r'\end{pmatrix}');
  output = output.replaceAllMapped(
    RegExp(r'\\(dot|ddot|hat|bar|vec)([A-Za-z])'),
    (match) => '\\${match.group(1)}{${match.group(2)}}',
  );
  output = output.replaceAllMapped(
    RegExp(r'\\sqrt\s*([A-Za-z0-9])'),
    (match) => '\\sqrt{${match.group(1)}}',
  );
  output = output.replaceAllMapped(
    RegExp(r'\\(sin|cos|tan|log|ln|lim)([A-Za-z])'),
    (match) => '\\${match.group(1)} ${match.group(2)}',
  );
  return output;
}

String _prettifyLatex(String value, {bool trim = true}) {
  final keepLeadingSpace =
      !trim && value.isNotEmpty && value.codeUnitAt(0) <= 32;
  final keepTrailingSpace =
      !trim && value.isNotEmpty && value.codeUnitAt(value.length - 1) <= 32;
  var output = _normalizeLatexExpression(value.replaceAll(r'\$', r'$'));
  final fractionPattern = RegExp(
    r'\\(?:dfrac|tfrac|frac)\s*\{([^{}]+)\}\s*\{([^{}]+)\}',
  );
  var previous = '';
  while (previous != output) {
    previous = output;
    output = output.replaceAllMapped(
      fractionPattern,
      (match) =>
          '(${match.group(1)?.trim() ?? ''})/(${match.group(2)?.trim() ?? ''})',
    );
  }
  output = output
      .replaceAllMapped(
        RegExp(r'\\begin\{[^}]+\}(.+?)\\end\{[^}]+\}', dotAll: true),
        (match) => '[${match.group(1)?.replaceAll(r'\\', '; ') ?? ''}]',
      )
      .replaceAll(r'\left', '')
      .replaceAll(r'\right', '')
      .replaceAll(r'\cdot', ' · ')
      .replaceAll(r'\times', ' × ')
      .replaceAll(r'\quad', ' ')
      .replaceAll(r'\,', ' ')
      .replaceAll(r'\infty', '∞')
      .replaceAll(r'\mu', 'μ')
      .replaceAll(r'\alpha', 'α')
      .replaceAll(r'\beta', 'β')
      .replaceAll(r'\gamma', 'γ')
      .replaceAll(r'\delta', 'δ')
      .replaceAll(r'\theta', 'θ')
      .replaceAll(r'\lambda', 'λ')
      .replaceAll(r'\pi', 'π')
      .replaceAll(r'\sigma', 'σ')
      .replaceAll(r'\omega', 'ω')
      .replaceAll(r'\Omega', 'Ω')
      .replaceAll(r'\Delta', 'Δ')
      .replaceAllMapped(
        RegExp(r'\\sqrt\{([^{}]+)\}'),
        (match) => '√(${match.group(1)})',
      )
      .replaceAllMapped(
        RegExp(r'\\dot\{([A-Za-z])\}'),
        (match) => '${match.group(1)} dot',
      )
      .replaceAll('{', '')
      .replaceAll('}', '');
  output = _unicodeSimpleScripts(output).replaceAll(RegExp(r'\s+'), ' ').trim();
  if (trim) return output;
  return '${keepLeadingSpace ? ' ' : ''}$output${keepTrailingSpace ? ' ' : ''}';
}

String _unicodeSimpleScripts(String value) {
  const superscripts = {
    '0': '⁰',
    '1': '¹',
    '2': '²',
    '3': '³',
    '4': '⁴',
    '5': '⁵',
    '6': '⁶',
    '7': '⁷',
    '8': '⁸',
    '9': '⁹',
    '+': '⁺',
    '-': '⁻',
  };
  const subscripts = {
    '0': '₀',
    '1': '₁',
    '2': '₂',
    '3': '₃',
    '4': '₄',
    '5': '₅',
    '6': '₆',
    '7': '₇',
    '8': '₈',
    '9': '₉',
    '+': '₊',
    '-': '₋',
  };
  return value
      .replaceAllMapped(
        RegExp(r'\^([0-9+\-])'),
        (match) => superscripts[match.group(1)] ?? match.group(0)!,
      )
      .replaceAllMapped(
        RegExp(r'_([0-9+\-])'),
        (match) => subscripts[match.group(1)] ?? match.group(0)!,
      );
}

int _nextMathStart(String value, int start) {
  for (var i = start; i < value.length; i++) {
    if (value.startsWith(r'\(', i) ||
        value.startsWith(r'\[', i) ||
        value.startsWith(r'\begin{', i)) {
      return i;
    }
    if (value.codeUnitAt(i) == 36 && !_isEscaped(value, i)) return i;
  }
  return -1;
}

int _rawMathRunEnd(String value, int start) {
  final firstEnd = RegExp(
    r'\\end\{[A-Za-z*]+\}',
  ).firstMatch(value.substring(start));
  if (firstEnd == null) return -1;
  var end = start + firstEnd.end;
  while (end < value.length) {
    final rest = value.substring(end);
    final boundary = RegExp(
      r'^(?:\s+(?:such that|where|is desired|determine|find|Is the|This|The)\b|\.\s+)',
      caseSensitive: false,
    ).firstMatch(rest);
    if (boundary != null) break;
    if (rest.startsWith(r'\begin{')) {
      final nextEnd = RegExp(r'\\end\{[A-Za-z*]+\}').firstMatch(rest);
      if (nextEnd == null) break;
      end += nextEnd.end;
      continue;
    }
    if (RegExp(r'^[\sA-Za-z0-9_{}\\^+\-*/=()[\].,]').hasMatch(rest)) {
      end++;
      continue;
    }
    break;
  }
  return end;
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
