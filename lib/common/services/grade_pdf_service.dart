import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/grades/grade_model.dart';

/// Comprehensive grade report data with semester groupings and analytics
class GradeReportData {
  final String studentName;
  final String studentId;
  final String program;
  final double cumulativeGPA;
  final double semesterGPA;
  final int totalCredits;
  final int completedCredits;
  final int targetCredits;
  final String currentSemester;
  final List<CourseGrade> courses;
  final List<SemesterModel> semesters;
  final List<GradeTrendPoint> gpaTrend;
  final GradeStatistics? statistics;

  GradeReportData({
    required this.studentName,
    required this.studentId,
    required this.program,
    required this.cumulativeGPA,
    required this.semesterGPA,
    required this.totalCredits,
    required this.completedCredits,
    this.targetCredits = 120,
    required this.currentSemester,
    required this.courses,
    required this.semesters,
    required this.gpaTrend,
    this.statistics,
  });

  /// Group courses by semester
  Map<String, List<CourseGrade>> get coursesBySemester {
    final grouped = <String, List<CourseGrade>>{};
    for (final course in courses) {
      final semester = semesters
          .where((s) => s.id == course.semesterId)
          .firstOrNull;
      final key = semester != null
          ? '${semester.name} ${semester.year}'.trim()
          : course.semesterId;
      grouped.putIfAbsent(key, () => <CourseGrade>[]).add(course);
    }
    return grouped;
  }

  /// Calculate semester GPA for a specific semester
  double calculateSemesterGPA(List<CourseGrade> semesterCourses) {
    if (semesterCourses.isEmpty) {
      return 0.0;
    }

    double totalPoints = 0.0;
    int credits = 0;
    for (final course in semesterCourses) {
      totalPoints += course.currentGrade.gpa * course.creditHours;
      credits += course.creditHours;
    }

    return credits > 0 ? totalPoints / credits : 0.0;
  }

  /// Get grade distribution
  Map<String, int> get gradeDistribution {
    final distribution = <String, int>{};
    for (final course in courses) {
      final grade = course.currentGrade.label;
      distribution[grade] = (distribution[grade] ?? 0) + 1;
    }
    return distribution;
  }
}

class GradePdfReportService {
  // Color palette
  static const _primaryColor = PdfColor.fromInt(0xFF6366F1);
  static const _primaryDark = PdfColor.fromInt(0xFF4F46E5);
  static const _secondaryColor = PdfColor.fromInt(0xFF8B5CF6);
  static const _successColor = PdfColor.fromInt(0xFF10B981);
  static const _successLight = PdfColor.fromInt(0xFFD1FAE5);
  static const _warningColor = PdfColor.fromInt(0xFFF59E0B);
  static const _warningLight = PdfColor.fromInt(0xFFFEF3C7);
  static const _dangerColor = PdfColor.fromInt(0xFFEF4444);
  static const _infoColor = PdfColor.fromInt(0xFF3B82F6);
  static const _infoLight = PdfColor.fromInt(0xFFDBEAFE);
  static const _textPrimary = PdfColor.fromInt(0xFF111827);
  static const _textSecondary = PdfColor.fromInt(0xFF6B7280);
  static const _textMuted = PdfColor.fromInt(0xFF9CA3AF);
  static const _bgLight = PdfColor.fromInt(0xFFF9FAFB);
  static const _borderColor = PdfColor.fromInt(0xFFE5E7EB);

  static const _examColor = PdfColor.fromInt(0xFF6366F1);
  static const _quizColor = PdfColor.fromInt(0xFF8B5CF6);
  static const _assignmentColor = PdfColor.fromInt(0xFF3B82F6);
  static const _projectColor = PdfColor.fromInt(0xFF10B981);
  static const _labColor = PdfColor.fromInt(0xFF14B8A6);
  static const _presentationColor = PdfColor.fromInt(0xFFF59E0B);
  static const _midtermColor = PdfColor.fromInt(0xFFEC4899);
  static const _finalExamColor = PdfColor.fromInt(0xFFEF4444);
  static const _participationColor = PdfColor.fromInt(0xFF64748B);

  late pw.Font _regularFont;
  late pw.Font _boldFont;
  late pw.Font _semiBoldFont;
  bool _isArabic = false;

  /// Generate and share/save a PDF grade report
  Future<void> generateAndShareReport({
    required BuildContext context,
    required GradeReportData data,
    required String reportTitle,
    required bool isArabic,
  }) async {
    try {
      final pdf = await _generatePdf(data, reportTitle, isArabic);
      final fileName =
          'EduVerse_Grade_Report_${DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now())}.pdf';

      await Printing.sharePdf(bytes: pdf, filename: fileName);
    } catch (e) {
      debugPrint('PDF generation error: $e');
      rethrow;
    }
  }

  Future<Uint8List> _generatePdf(
    GradeReportData data,
    String reportTitle,
    bool isArabic,
  ) async {
    _isArabic = isArabic;

    final pdf = pw.Document(
      title: reportTitle,
      author: 'EduVerse',
      creator: 'EduVerse Academic System',
      subject: 'Official Academic Transcript',
    );

    // Load fonts
    if (isArabic) {
      _regularFont = await PdfGoogleFonts.notoSansArabicRegular();
      _boldFont = await PdfGoogleFonts.notoSansArabicBold();
      _semiBoldFont = await PdfGoogleFonts.notoSansArabicMedium();
    } else {
      _regularFont = await PdfGoogleFonts.interRegular();
      _boldFont = await PdfGoogleFonts.interBold();
      _semiBoldFont = await PdfGoogleFonts.interSemiBold();
    }

    final direction = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: direction,
        margin: const pw.EdgeInsets.all(0),
        build: (_) => _buildCoverPage(data, reportTitle),
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: direction,
        margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
        header: (context) => _buildPageHeader(reportTitle, context.pageNumber),
        footer: (context) =>
            _buildPageFooter(context.pageNumber, context.pagesCount),
        build: (_) => [
          _buildAcademicSummary(data),
          pw.SizedBox(height: 14),
          _buildGPAAnalysisSection(data),
          pw.SizedBox(height: 14),
          _buildGradeDistributionSection(data),
          pw.SizedBox(height: 14),
          _buildSemesterSummaryTable(data),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: direction,
        margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
        header: (context) => _buildPageHeader(reportTitle, context.pageNumber),
        footer: (context) =>
            _buildPageFooter(context.pageNumber, context.pagesCount),
        build: (_) => _buildSemesterCourseSections(data),
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: direction,
        margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 32),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader(reportTitle, 0),
            pw.SizedBox(height: 16),
            _buildPerformanceInsights(data),
            pw.SizedBox(height: 16),
            _buildAcademicGoals(data),
            pw.Spacer(),
            _buildReportSignature(data),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPageHeader(String title, int pageNumber) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _borderColor, width: 0.8),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 12,
                  color: _primaryDark,
                ),
              ),
              pw.Text(
                'Official Academic Transcript',
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: 9,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          if (pageNumber > 0)
            pw.Text(
              'Page $pageNumber',
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 9,
                color: _textMuted,
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildPageFooter(int pageNumber, int pageCount) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _borderColor, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 8,
              color: _textMuted,
            ),
          ),
          pw.Text(
            '$pageNumber / $pageCount',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 8,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== COVER PAGE ====================
  pw.Widget _buildCoverPage(GradeReportData data, String title) {
    final totalCourses = data.courses.length;

    return pw.Stack(
      children: [
        pw.Positioned.fill(
          child: pw.Container(
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [_primaryDark, _primaryColor, _secondaryColor],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        pw.Positioned(
          top: -60,
          right: -60,
          child: pw.Container(
            width: 220,
            height: 220,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.white.shade(0.12),
            ),
          ),
        ),
        pw.Positioned(
          bottom: -90,
          left: -90,
          child: pw.Container(
            width: 300,
            height: 300,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.white.shade(0.08),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.fromLTRB(44, 56, 44, 56),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 54,
                    height: 54,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(14),
                    ),
                    child: pw.Text(
                      'EV',
                      style: pw.TextStyle(
                        font: _boldFont,
                        fontSize: 20,
                        color: _primaryDark,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'EduVerse University',
                        style: pw.TextStyle(
                          font: _boldFont,
                          color: PdfColors.white,
                          fontSize: 18,
                        ),
                      ),
                      pw.Text(
                        'Department of Computer Science',
                        style: pw.TextStyle(
                          font: _regularFont,
                          color: PdfColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: _boldFont,
                  color: PdfColors.white,
                  fontSize: 32,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Official Academic Transcript',
                style: pw.TextStyle(
                  font: _semiBoldFont,
                  color: PdfColors.white,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 22),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white.shade(0.12),
                  borderRadius: pw.BorderRadius.circular(14),
                  border: pw.Border.all(color: PdfColors.white.shade(0.25)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _coverInfoRow('Student Name', data.studentName),
                    pw.SizedBox(height: 6),
                    _coverInfoRow('Student ID', data.studentId),
                    pw.SizedBox(height: 6),
                    _coverInfoRow('Program', data.program),
                    pw.SizedBox(height: 6),
                    _coverInfoRow('Current Semester', data.currentSemester),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildCoverStat(
                      'Cumulative GPA',
                      data.cumulativeGPA.toStringAsFixed(2),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _buildCoverStat(
                      'Credits Earned',
                      '${data.completedCredits}/${data.targetCredits}',
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: _buildCoverStat('Total Courses', '$totalCourses'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _coverInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 110,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: _regularFont,
              color: PdfColors.white,
              fontSize: 10,
            ),
          ),
        ),
        pw.Text(
          value.isNotEmpty ? value : '-',
          style: pw.TextStyle(
            font: _semiBoldFont,
            color: PdfColors.white,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCoverStat(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white.shade(0.12),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.white.shade(0.2)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 9,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 13,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUMMARY PAGE ====================
  pw.Widget _buildAcademicSummary(GradeReportData data) {
    final passRate = data.statistics?.passRate ?? 0.0;
    final average = data.statistics?.averagePercentage ?? 0.0;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [_primaryColor, _secondaryColor],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Academic Performance Summary',
            style: pw.TextStyle(
              font: _boldFont,
              color: PdfColors.white,
              fontSize: 15,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: _summaryMetric(
                  'Semester GPA',
                  data.semesterGPA.toStringAsFixed(2),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _summaryMetric(
                  'Cumulative GPA',
                  data.cumulativeGPA.toStringAsFixed(2),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _summaryMetric(
                  'Average',
                  '${average.toStringAsFixed(1)}%',
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _summaryMetric(
                  'Pass Rate',
                  '${passRate.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryMetric(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white.shade(0.12),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              font: _boldFont,
              color: PdfColors.white,
              fontSize: 14,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: _regularFont,
              color: PdfColors.white,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildGPAAnalysisSection(GradeReportData data) {
    final trend = data.gpaTrend.isNotEmpty
        ? data.gpaTrend
        : <GradeTrendPoint>[
            GradeTrendPoint(
              semesterName: data.currentSemester,
              gpa: data.cumulativeGPA,
              creditHours: data.completedCredits,
            ),
          ];

    final maxGpa = trend
        .map((point) => point.gpa)
        .fold<double>(0.0, (a, b) => a > b ? a : b)
        .clamp(0.1, 4.0);

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'GPA Analysis',
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 13,
              color: _textPrimary,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: trend.map((point) {
              final height = (point.gpa / maxGpa) * 70;
              return pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 3),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        point.gpa.toStringAsFixed(2),
                        style: pw.TextStyle(
                          font: _semiBoldFont,
                          fontSize: 8,
                          color: _textSecondary,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        height: height,
                        decoration: pw.BoxDecoration(
                          gradient: const pw.LinearGradient(
                            colors: [_infoColor, _primaryColor],
                            begin: pw.Alignment.bottomCenter,
                            end: pw.Alignment.topCenter,
                          ),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        point.semesterName,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: _regularFont,
                          fontSize: 7,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _inlinePill(
                'Current Semester',
                data.semesterGPA.toStringAsFixed(2),
                _infoLight,
                _infoColor,
              ),
              pw.SizedBox(width: 6),
              _inlinePill(
                'Cumulative',
                data.cumulativeGPA.toStringAsFixed(2),
                _successLight,
                _successColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _inlinePill(String label, String value, PdfColor bg, PdfColor fg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(999),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(font: _regularFont, fontSize: 8, color: fg),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(font: _semiBoldFont, fontSize: 8, color: fg),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildGradeDistributionSection(GradeReportData data) {
    final distribution = data.gradeDistribution.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Grade Distribution',
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 13,
              color: _textPrimary,
            ),
          ),
          pw.SizedBox(height: 10),
          if (distribution.isEmpty)
            pw.Text(
              'No graded courses available yet.',
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 10,
                color: _textMuted,
              ),
            )
          else
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: distribution.map((entry) {
                final grade = _gradeLetterFromLabel(entry.key);
                return pw.Container(
                  width: 88,
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(grade.color.toARGB32()).shade(0.14),
                    borderRadius: pw.BorderRadius.circular(10),
                    border: pw.Border.all(
                      color: PdfColor.fromInt(
                        grade.color.toARGB32(),
                      ).shade(0.35),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        entry.key,
                        style: pw.TextStyle(
                          font: _boldFont,
                          fontSize: 14,
                          color: PdfColor.fromInt(grade.color.toARGB32()),
                        ),
                      ),
                      pw.Text(
                        '${entry.value} course(s)',
                        style: pw.TextStyle(
                          font: _regularFont,
                          fontSize: 8,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildSemesterSummaryTable(GradeReportData data) {
    final semesters = data.semesters;

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Semester Performance Summary',
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 13,
              color: _textPrimary,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: _borderColor, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.6),
              1: pw.FlexColumnWidth(1.0),
              2: pw.FlexColumnWidth(1.0),
              3: pw.FlexColumnWidth(1.0),
            },
            children: [
              _summaryHeaderRow(),
              if (semesters.isEmpty)
                _summaryDataRow('Current', 0, 0, 0.0, false)
              else
                ...semesters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final semester = entry.value;
                  final courses = data.courses
                      .where((course) => course.semesterId == semester.id)
                      .toList();
                  final credits = courses.fold<int>(
                    0,
                    (sum, course) => sum + course.creditHours,
                  );
                  final gpa = data.calculateSemesterGPA(courses);
                  final name = '${semester.name} ${semester.year}'.trim();
                  return _summaryDataRow(
                    name,
                    courses.length,
                    credits,
                    gpa,
                    index.isEven,
                  );
                }),
            ],
          ),
        ],
      ),
    );
  }

  pw.TableRow _summaryHeaderRow() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: _bgLight),
      children: [
        _tableCell('Semester', isHeader: true),
        _tableCell('Courses', isHeader: true, align: pw.TextAlign.center),
        _tableCell('Credits', isHeader: true, align: pw.TextAlign.center),
        _tableCell('GPA', isHeader: true, align: pw.TextAlign.center),
      ],
    );
  }

  pw.TableRow _summaryDataRow(
    String name,
    int courseCount,
    int credits,
    double gpa,
    bool isEven,
  ) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: isEven ? PdfColors.white : _bgLight),
      children: [
        _tableCell(name),
        _tableCell('$courseCount', align: pw.TextAlign.center),
        _tableCell('$credits', align: pw.TextAlign.center),
        _tableCell(gpa.toStringAsFixed(2), align: pw.TextAlign.center),
      ],
    );
  }

  pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: isHeader ? _semiBoldFont : _regularFont,
          fontSize: isHeader ? 9 : 8.5,
          color: isHeader ? _textPrimary : _textSecondary,
        ),
      ),
    );
  }

  // ==================== DETAILED COURSES ====================
  List<pw.Widget> _buildSemesterCourseSections(GradeReportData data) {
    final widgets = <pw.Widget>[];

    final semesters = data.semesters.isNotEmpty
        ? data.semesters
        : <SemesterModel>[
            SemesterModel(
              id: data.currentSemester,
              name: data.currentSemester,
              year: '',
              isCurrent: true,
              startDate: DateTime.now(),
              endDate: DateTime.now(),
            ),
          ];

    for (final semester in semesters) {
      final semesterCourses = data.courses
          .where((course) => course.semesterId == semester.id)
          .toList();

      if (semesterCourses.isEmpty) {
        continue;
      }

      widgets.add(
        _buildSemesterHeader(
          '${semester.name} ${semester.year}'.trim(),
          data.calculateSemesterGPA(semesterCourses),
          semesterCourses.length,
        ),
      );
      widgets.add(pw.SizedBox(height: 10));

      for (final course in semesterCourses) {
        widgets.add(_buildCourseDetailCard(course));
        widgets.add(pw.SizedBox(height: 10));
      }

      widgets.add(pw.SizedBox(height: 6));
    }

    if (widgets.isEmpty) {
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: _bgLight,
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: _borderColor),
          ),
          child: pw.Text(
            'No course data available for this report period.',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
              color: _textSecondary,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  pw.Widget _buildSemesterHeader(String semesterName, double gpa, int count) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [_primaryColor, _primaryDark],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            semesterName,
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
          pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white.shade(0.18),
                  borderRadius: pw.BorderRadius.circular(999),
                ),
                child: pw.Text(
                  '$count course(s)',
                  style: pw.TextStyle(
                    font: _regularFont,
                    fontSize: 8,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(999),
                ),
                child: pw.Text(
                  'GPA ${gpa.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: _semiBoldFont,
                    fontSize: 8,
                    color: _primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCourseDetailCard(CourseGrade course) {
    final courseGrade = course.currentGrade;
    final graded = course.gradedCount;
    final total = course.assessments.length;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 6,
                height: 34,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(course.courseColor.toARGB32()),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      course.courseName,
                      style: pw.TextStyle(
                        font: _semiBoldFont,
                        fontSize: 11,
                        color: _textPrimary,
                      ),
                    ),
                    pw.Text(
                      '${course.courseCode}  |  ${course.instructor}  |  ${course.creditHours} credit(s)',
                      style: pw.TextStyle(
                        font: _regularFont,
                        fontSize: 8,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildGradeLetterBadge(courseGrade),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: _borderColor, width: 0.55),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.3),
              1: pw.FlexColumnWidth(3.1),
              2: pw.FlexColumnWidth(1.1),
              3: pw.FlexColumnWidth(1.0),
              4: pw.FlexColumnWidth(0.8),
              5: pw.FlexColumnWidth(1.1),
            },
            children: [
              _assessmentHeaderRow(),
              ...course.assessments.asMap().entries.map(
                (entry) => _buildAssessmentRow(entry.value, entry.key.isEven),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _bgLight,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _summaryToken(
                  'Course Average',
                  '${course.currentPercentage.toStringAsFixed(1)}%',
                ),
                _summaryToken('Grade', courseGrade.label),
                _summaryToken('GPA Points', courseGrade.gpa.toStringAsFixed(2)),
                _summaryToken('Credits', '${course.creditHours}'),
                _summaryToken('Graded', '$graded/$total'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.TableRow _assessmentHeaderRow() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: _bgLight),
      children: [
        _tableCell('Type', isHeader: true, align: pw.TextAlign.center),
        _tableCell('Assessment', isHeader: true),
        _tableCell('Score', isHeader: true, align: pw.TextAlign.center),
        _tableCell('Percent', isHeader: true, align: pw.TextAlign.center),
        _tableCell('Grade', isHeader: true, align: pw.TextAlign.center),
        _tableCell('Status', isHeader: true, align: pw.TextAlign.center),
      ],
    );
  }

  pw.TableRow _buildAssessmentRow(AssessmentGrade assessment, bool isEven) {
    final scoreText = assessment.maxScore > 0
        ? '${assessment.score.toStringAsFixed(assessment.score % 1 == 0 ? 0 : 1)}/${assessment.maxScore.toStringAsFixed(assessment.maxScore % 1 == 0 ? 0 : 1)}'
        : '--';
    final percentText = assessment.isGraded
        ? '${assessment.percentage.toStringAsFixed(1)}%'
        : '--';

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: isEven ? PdfColors.white : _bgLight),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Center(child: _buildAssessmentTypeBadge(assessment.type)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                assessment.name,
                style: pw.TextStyle(
                  font: _semiBoldFont,
                  fontSize: 8.2,
                  color: _textPrimary,
                ),
              ),
              if ((assessment.feedback ?? '').trim().isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    assessment.feedback!.trim(),
                    style: pw.TextStyle(
                      font: _regularFont,
                      fontSize: 7.2,
                      color: _textMuted,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _tableCell(scoreText, align: pw.TextAlign.center),
        _tableCell(percentText, align: pw.TextAlign.center),
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Center(
            child: _buildGradeLetterBadge(assessment.gradeLetter),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: pw.BoxDecoration(
              color: assessment.isGraded ? _successLight : _warningLight,
              borderRadius: pw.BorderRadius.circular(999),
            ),
            child: pw.Text(
              assessment.isGraded ? 'Published' : 'Pending',
              style: pw.TextStyle(
                font: _semiBoldFont,
                fontSize: 7,
                color: assessment.isGraded ? _successColor : _warningColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildAssessmentTypeBadge(AssessmentType type) {
    final badgeColor = _assessmentTypeColor(type);

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        color: badgeColor.shade(0.17),
        borderRadius: pw.BorderRadius.circular(999),
      ),
      child: pw.Text(
        type.label,
        style: pw.TextStyle(
          font: _semiBoldFont,
          fontSize: 7,
          color: badgeColor,
        ),
      ),
    );
  }

  pw.Widget _buildGradeLetterBadge(GradeLetter grade) {
    final color = PdfColor.fromInt(grade.color.toARGB32());

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: color.shade(0.17),
        borderRadius: pw.BorderRadius.circular(999),
        border: pw.Border.all(color: color.shade(0.35)),
      ),
      child: pw.Text(
        grade.label,
        style: pw.TextStyle(font: _semiBoldFont, fontSize: 8, color: color),
      ),
    );
  }

  pw.Widget _summaryToken(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(999),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                font: _regularFont,
                color: _textSecondary,
                fontSize: 7.5,
              ),
            ),
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                font: _semiBoldFont,
                color: _textPrimary,
                fontSize: 7.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== INSIGHTS ====================
  pw.Widget _buildPerformanceInsights(GradeReportData data) {
    final gradedCourses =
        data.courses.where((course) => course.gradedCount > 0).toList()
          ..sort((a, b) => b.currentPercentage.compareTo(a.currentPercentage));

    final strongest = gradedCourses.isNotEmpty ? gradedCourses.first : null;
    final needsFocus = gradedCourses.isNotEmpty ? gradedCourses.last : null;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Performance Insights',
          style: pw.TextStyle(
            font: _semiBoldFont,
            fontSize: 14,
            color: _textPrimary,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              child: _insightCard(
                title: 'Strengths',
                color: _successColor,
                light: _successLight,
                line1: strongest != null
                    ? '${strongest.courseName} (${strongest.currentPercentage.toStringAsFixed(1)}%)'
                    : 'No graded courses available yet.',
                line2: strongest != null
                    ? 'Consistent high performance in assessments.'
                    : 'Complete assessments to generate insights.',
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: _insightCard(
                title: 'Needs Focus',
                color: _warningColor,
                light: _warningLight,
                line1: needsFocus != null
                    ? '${needsFocus.courseName} (${needsFocus.currentPercentage.toStringAsFixed(1)}%)'
                    : 'No at-risk courses detected.',
                line2: needsFocus != null
                    ? 'Prioritize pending items and improve weak assessment areas.'
                    : 'Maintain current momentum.',
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _insightCard({
    required String title,
    required PdfColor color,
    required PdfColor light,
    required String line1,
    required String line2,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: light,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 11,
              color: color,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            line1,
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 9,
              color: _textPrimary,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            line2,
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 8,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAcademicGoals(GradeReportData data) {
    final completed = data.completedCredits.clamp(0, data.targetCredits);
    final progress = data.targetCredits > 0
        ? completed / data.targetCredits
        : 0.0;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Academic Goals & Graduation Progress',
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 13,
              color: _textPrimary,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '$completed / ${data.targetCredits} credits completed',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 9,
              color: _textSecondary,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            height: 11,
            decoration: pw.BoxDecoration(
              color: _bgLight,
              borderRadius: pw.BorderRadius.circular(999),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 460 * progress.clamp(0.0, 1.0),
                  decoration: pw.BoxDecoration(
                    gradient: const pw.LinearGradient(
                      colors: [_successColor, _infoColor],
                    ),
                    borderRadius: pw.BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Progress: ${(progress * 100).toStringAsFixed(1)}%',
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 9,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReportSignature(GradeReportData data) {
    final generatedAt = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _bgLight,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Report Signature',
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 10,
              color: _textPrimary,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Student ID: ${data.studentId.isNotEmpty ? data.studentId : '-'}',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 8.5,
              color: _textSecondary,
            ),
          ),
          pw.Text(
            'Generated at: $generatedAt',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 8.5,
              color: _textSecondary,
            ),
          ),
          pw.Text(
            'Issued by EduVerse Academic Affairs',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 8.5,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  PdfColor _assessmentTypeColor(AssessmentType type) {
    switch (type) {
      case AssessmentType.exam:
        return _examColor;
      case AssessmentType.quiz:
        return _quizColor;
      case AssessmentType.assignment:
        return _assignmentColor;
      case AssessmentType.project:
        return _projectColor;
      case AssessmentType.lab:
        return _labColor;
      case AssessmentType.presentation:
        return _presentationColor;
      case AssessmentType.midterm:
        return _midtermColor;
      case AssessmentType.finalExam:
        return _finalExamColor;
      case AssessmentType.participation:
        return _participationColor;
    }
  }

  GradeLetter _gradeLetterFromLabel(String label) {
    switch (label) {
      case 'A+':
        return GradeLetter.aPlus;
      case 'A':
        return GradeLetter.a;
      case 'A-':
        return GradeLetter.aMinus;
      case 'B+':
        return GradeLetter.bPlus;
      case 'B':
        return GradeLetter.b;
      case 'B-':
        return GradeLetter.bMinus;
      case 'C+':
        return GradeLetter.cPlus;
      case 'C':
        return GradeLetter.c;
      case 'C-':
        return GradeLetter.cMinus;
      case 'D+':
        return GradeLetter.dPlus;
      case 'D':
        return GradeLetter.d;
      case 'F':
        return GradeLetter.f;
      default:
        return GradeLetter.pending;
    }
  }
}
