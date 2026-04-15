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
      final semesterName = semesters
          .firstWhere(
            (s) => s.id == course.semesterId,
            orElse: () => SemesterModel(
              id: course.semesterId,
              name: 'Unknown',
              year: '',
              startDate: DateTime.now(),
              endDate: DateTime.now(),
            ),
          )
          .name;
      grouped.putIfAbsent(semesterName, () => []).add(course);
    }
    return grouped;
  }

  /// Calculate semester GPA for a specific semester
  double calculateSemesterGPA(List<CourseGrade> courses) {
    if (courses.isEmpty) return 0.0;
    double totalPoints = 0;
    int totalCredits = 0;
    for (final course in courses) {
      totalPoints += course.currentGrade.gpa * course.creditHours;
      totalCredits += course.creditHours;
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
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

  /// Generate PDF bytes
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
      subject: 'Academic Grade Report',
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

    final textDirection = isArabic
        ? pw.TextDirection.rtl
        : pw.TextDirection.ltr;

    // Page 1: Cover and Overview
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: textDirection,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => _buildCoverPage(data, reportTitle),
      ),
    );

    // Page 2: Academic Summary & GPA Analysis
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: textDirection,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPageHeader(reportTitle, context.pageNumber),
        footer: (context) =>
            _buildPageFooter(context.pageNumber, context.pagesCount),
        build: (context) => [
          _buildAcademicSummary(data),
          pw.SizedBox(height: 20),
          _buildGPAAnalysisSection(data),
          pw.SizedBox(height: 20),
          _buildGradeDistributionSection(data),
        ],
      ),
    );

    // Page 3+: Detailed Course Grades by Semester
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: textDirection,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPageHeader(reportTitle, context.pageNumber),
        footer: (context) =>
            _buildPageFooter(context.pageNumber, context.pagesCount),
        build: (context) => _buildSemesterCourseSections(data),
      ),
    );

    // Page 4: Performance Insights & Recommendations
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: textDirection,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader(reportTitle, 0),
            pw.SizedBox(height: 20),
            _buildPerformanceInsights(data),
            pw.SizedBox(height: 20),
            _buildAcademicGoals(data),
            pw.Spacer(),
            _buildReportSignature(data),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // ==================== COVER PAGE ====================
  pw.Widget _buildCoverPage(GradeReportData data, String title) {
    return pw.Stack(
      children: [
        // Background gradient
        pw.Positioned.fill(
          child: pw.Container(
            decoration: const pw.BoxDecoration(
              gradient: pw.LinearGradient(
                begin: pw.Alignment.topLeft,
                end: pw.Alignment.bottomRight,
                colors: [_primaryColor, _secondaryColor, _primaryDark],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Decorative circles
        pw.Positioned(
          top: -50,
          right: -50,
          child: pw.Container(
            width: 200,
            height: 200,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.white.shade(0.1),
            ),
          ),
        ),
        pw.Positioned(
          bottom: -80,
          left: -80,
          child: pw.Container(
            width: 300,
            height: 300,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.white.shade(0.05),
            ),
          ),
        ),
        // Content
        pw.Padding(
          padding: const pw.EdgeInsets.all(50),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo/Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'EduVerse',
                      style: pw.TextStyle(
                        font: _boldFont,
                        fontSize: 24,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                  pw.Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: pw.TextStyle(
                      font: _regularFont,
                      fontSize: 12,
                      color: PdfColors.white.shade(0.8),
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              // Main Title
              pw.Text(
                _isArabic ? 'التقرير الأكاديمي' : 'Academic',
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: 36,
                  color: PdfColors.white.shade(0.9),
                ),
              ),
              pw.Text(
                _isArabic ? 'الشامل للدرجات' : 'Grade Report',
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 48,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 30),
              // Student Info Card
              pw.Container(
                padding: const pw.EdgeInsets.all(25),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(16),
                  boxShadow: [
                    pw.BoxShadow(
                      color: PdfColors.black.shade(0.1),
                      blurRadius: 20,
                      offset: const PdfPoint(0, 10),
                    ),
                  ],
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 60,
                          height: 60,
                          decoration: pw.BoxDecoration(
                            gradient: const pw.LinearGradient(
                              colors: [_primaryColor, _secondaryColor],
                            ),
                            borderRadius: pw.BorderRadius.circular(12),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              data.studentName.isNotEmpty
                                  ? data.studentName[0].toUpperCase()
                                  : 'S',
                              style: pw.TextStyle(
                                font: _boldFont,
                                fontSize: 28,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                data.studentName,
                                style: pw.TextStyle(
                                  font: _boldFont,
                                  fontSize: 20,
                                  color: _textPrimary,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                '${_isArabic ? 'رقم الطالب:' : 'Student ID:'} ${data.studentId}',
                                style: pw.TextStyle(
                                  font: _regularFont,
                                  fontSize: 12,
                                  color: _textSecondary,
                                ),
                              ),
                              pw.Text(
                                data.program,
                                style: pw.TextStyle(
                                  font: _regularFont,
                                  fontSize: 12,
                                  color: _textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Divider(color: _borderColor, thickness: 1),
                    pw.SizedBox(height: 20),
                    // Quick Stats
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildCoverStat(
                          _isArabic ? 'المعدل التراكمي' : 'Cumulative GPA',
                          data.cumulativeGPA.toStringAsFixed(2),
                          '/4.00',
                          _primaryColor,
                        ),
                        _buildCoverStat(
                          _isArabic ? 'الساعات المكتسبة' : 'Credits Earned',
                          '${data.completedCredits}',
                          '/${data.targetCredits}',
                          _successColor,
                        ),
                        _buildCoverStat(
                          _isArabic ? 'الفصل الحالي' : 'Current Semester',
                          data.currentSemester.split(' ')[0],
                          data.currentSemester.contains(' ')
                              ? data.currentSemester.split(' ')[1]
                              : '',
                          _infoColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Spacer(),
              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white.shade(0.15),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      _isArabic
                          ? 'تم إنشاؤه بواسطة EduVerse'
                          : 'Generated by EduVerse Academic System',
                      style: pw.TextStyle(
                        font: _regularFont,
                        fontSize: 10,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
                      style: pw.TextStyle(
                        font: _regularFont,
                        fontSize: 10,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCoverStat(
    String label,
    String value,
    String suffix,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: value,
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 28,
                  color: color,
                ),
              ),
              pw.TextSpan(
                text: suffix,
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: 14,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: _regularFont,
            fontSize: 10,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  // ==================== PAGE HEADER & FOOTER ====================
  pw.Widget _buildPageHeader(String title, int pageNumber) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _borderColor, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 24,
                decoration: pw.BoxDecoration(
                  color: _primaryColor,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                'EduVerse',
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 14,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          pw.Text(
            _isArabic ? 'التقرير الأكاديمي' : 'Academic Grade Report',
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPageFooter(int pageNumber, int totalPages) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _borderColor)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            _isArabic
                ? 'هذا التقرير تم إنشاؤه تلقائياً بواسطة نظام EduVerse'
                : 'This report was automatically generated by EduVerse System',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 8,
              color: _textMuted,
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: pw.BoxDecoration(
              color: _bgLight,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Text(
              '$pageNumber / $totalPages',
              style: pw.TextStyle(
                font: _semiBoldFont,
                fontSize: 10,
                color: _textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACADEMIC SUMMARY ====================
  pw.Widget _buildAcademicSummary(GradeReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [_primaryColor, _secondaryColor],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _isArabic
                ? 'ملخص الأداء الأكاديمي'
                : 'Academic Performance Summary',
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 18,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              _buildSummaryCard(
                _isArabic ? 'المعدل التراكمي' : 'Cumulative GPA',
                data.cumulativeGPA.toStringAsFixed(2),
                'out of 4.00',
                _getGPAStatus(data.cumulativeGPA),
              ),
              pw.SizedBox(width: 15),
              _buildSummaryCard(
                _isArabic ? 'معدل الفصل الحالي' : 'Current Semester GPA',
                data.semesterGPA.toStringAsFixed(2),
                'out of 4.00',
                _getGPAStatus(data.semesterGPA),
              ),
              pw.SizedBox(width: 15),
              _buildSummaryCard(
                _isArabic ? 'الساعات المكتسبة' : 'Credits Completed',
                '${data.completedCredits}',
                'of ${data.targetCredits} total',
                '${((data.completedCredits / data.targetCredits) * 100).toStringAsFixed(0)}%',
              ),
              pw.SizedBox(width: 15),
              _buildSummaryCard(
                _isArabic ? 'إجمالي المقررات' : 'Total Courses',
                '${data.courses.length}',
                'across ${data.semesters.length} semesters',
                '',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGPAStatus(double gpa) {
    if (gpa >= 3.7) return _isArabic ? 'امتياز' : 'Excellent';
    if (gpa >= 3.3) return _isArabic ? 'جيد جداً' : 'Very Good';
    if (gpa >= 2.7) return _isArabic ? 'جيد' : 'Good';
    if (gpa >= 2.0) return _isArabic ? 'مقبول' : 'Satisfactory';
    return _isArabic ? 'يحتاج تحسين' : 'Needs Improvement';
  }

  pw.Widget _buildSummaryCard(
    String label,
    String value,
    String subtitle,
    String badge,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 9,
                color: _textSecondary,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: _boldFont,
                fontSize: 24,
                color: _textPrimary,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 8,
                color: _textMuted,
              ),
            ),
            if (badge.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: pw.BoxDecoration(
                  color: _successLight,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(
                  badge,
                  style: pw.TextStyle(
                    font: _semiBoldFont,
                    fontSize: 8,
                    color: _successColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== GPA ANALYSIS SECTION ====================
  pw.Widget _buildGPAAnalysisSection(GradeReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: _primaryColor,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                _isArabic ? 'تحليل المعدل التراكمي' : 'GPA Trend Analysis',
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 16,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          // GPA Trend Chart
          pw.Container(
            height: 120,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                pw.Container(
                  width: 30,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        '4.0',
                        style: pw.TextStyle(
                          font: _regularFont,
                          fontSize: 8,
                          color: _textMuted,
                        ),
                      ),
                      pw.Text(
                        '3.0',
                        style: pw.TextStyle(
                          font: _regularFont,
                          fontSize: 8,
                          color: _textMuted,
                        ),
                      ),
                      pw.Text(
                        '2.0',
                        style: pw.TextStyle(
                          font: _regularFont,
                          fontSize: 8,
                          color: _textMuted,
                        ),
                      ),
                      pw.Text(
                        '1.0',
                        style: pw.TextStyle(
                          font: _regularFont,
                          fontSize: 8,
                          color: _textMuted,
                        ),
                      ),
                      pw.Text(
                        '0.0',
                        style: pw.TextStyle(
                          font: _regularFont,
                          fontSize: 8,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 10),
                // Bars
                pw.Expanded(
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: data.gpaTrend.map((point) {
                      final barHeight = (point.gpa / 4.0) * 100;
                      final color = point.gpa >= 3.5
                          ? _successColor
                          : point.gpa >= 2.5
                          ? _warningColor
                          : _dangerColor;
                      return pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: pw.BoxDecoration(
                              color: color,
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Text(
                              point.gpa.toStringAsFixed(2),
                              style: pw.TextStyle(
                                font: _boldFont,
                                fontSize: 8,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Container(
                            width: 40,
                            height: barHeight,
                            decoration: pw.BoxDecoration(
                              gradient: pw.LinearGradient(
                                begin: pw.Alignment.topCenter,
                                end: pw.Alignment.bottomCenter,
                                colors: [color, color.shade(0.7)],
                              ),
                              borderRadius: const pw.BorderRadius.vertical(
                                top: pw.Radius.circular(6),
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            point.semesterName,
                            style: pw.TextStyle(
                              font: _semiBoldFont,
                              fontSize: 7,
                              color: _textSecondary,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            '${point.creditHours} cr',
                            style: pw.TextStyle(
                              font: _regularFont,
                              fontSize: 6,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== GRADE DISTRIBUTION ====================
  pw.Widget _buildGradeDistributionSection(GradeReportData data) {
    final distribution = data.gradeDistribution;
    final totalCourses = data.courses.length;

    final gradeColors = {
      'A+': _successColor,
      'A': _successColor,
      'A-': const PdfColor.fromInt(0xFF22C55E),
      'B+': const PdfColor.fromInt(0xFF84CC16),
      'B': _warningColor,
      'B-': _warningColor,
      'C+': const PdfColor.fromInt(0xFFF97316),
      'C': const PdfColor.fromInt(0xFFF97316),
      'C-': const PdfColor.fromInt(0xFFEA580C),
      'D+': _dangerColor,
      'D': _dangerColor,
      'F': const PdfColor.fromInt(0xFFDC2626),
    };

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: _secondaryColor,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                _isArabic ? 'توزيع الدرجات' : 'Grade Distribution',
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 16,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: distribution.entries.map((entry) {
              final percentage = (entry.value / totalCourses * 100);
              final color = gradeColors[entry.key] ?? _textMuted;
              return pw.Container(
                width: 80,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: _bgLight,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: color, width: 2),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      entry.key,
                      style: pw.TextStyle(
                        font: _boldFont,
                        fontSize: 20,
                        color: color,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${entry.value} ${_isArabic ? 'مقرر' : 'course${entry.value > 1 ? 's' : ''}'}',
                      style: pw.TextStyle(
                        font: _regularFont,
                        fontSize: 8,
                        color: _textSecondary,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: pw.TextStyle(
                        font: _semiBoldFont,
                        fontSize: 10,
                        color: _textPrimary,
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

  // ==================== SEMESTER COURSE SECTIONS ====================
  List<pw.Widget> _buildSemesterCourseSections(GradeReportData data) {
    final widgets = <pw.Widget>[];
    final coursesBySemester = data.coursesBySemester;

    widgets.add(
      pw.Text(
        _isArabic
            ? 'تفاصيل المقررات حسب الفصل الدراسي'
            : 'Detailed Course Grades by Semester',
        style: pw.TextStyle(font: _boldFont, fontSize: 20, color: _textPrimary),
      ),
    );
    widgets.add(pw.SizedBox(height: 20));

    int semesterIndex = 0;
    coursesBySemester.forEach((semesterName, courses) {
      final semesterGPA = data.calculateSemesterGPA(courses);
      final totalCredits = courses.fold<int>(
        0,
        (sum, c) => sum + c.creditHours,
      );

      widgets.add(
        pw.Container(
          margin: pw.EdgeInsets.only(
            bottom: 20,
            top: semesterIndex > 0 ? 10 : 0,
          ),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: _borderColor),
          ),
          child: pw.Column(
            children: [
              // Semester Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [
                      semesterIndex == 0 ? _primaryColor : _secondaryColor,
                      semesterIndex == 0 ? _secondaryColor : _primaryColor,
                    ],
                  ),
                  borderRadius: const pw.BorderRadius.vertical(
                    top: pw.Radius.circular(12),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white.shade(0.2),
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Text(
                            '${semesterIndex + 1}',
                            style: pw.TextStyle(
                              font: _boldFont,
                              fontSize: 14,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              semesterName,
                              style: pw.TextStyle(
                                font: _boldFont,
                                fontSize: 14,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              '${courses.length} ${_isArabic ? 'مقرر' : 'courses'} • $totalCredits ${_isArabic ? 'ساعة' : 'credits'}',
                              style: pw.TextStyle(
                                font: _regularFont,
                                fontSize: 9,
                                color: PdfColors.white.shade(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        borderRadius: pw.BorderRadius.circular(20),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Text(
                            _isArabic ? 'المعدل:' : 'GPA:',
                            style: pw.TextStyle(
                              font: _regularFont,
                              fontSize: 10,
                              color: _textSecondary,
                            ),
                          ),
                          pw.SizedBox(width: 4),
                          pw.Text(
                            semesterGPA.toStringAsFixed(2),
                            style: pw.TextStyle(
                              font: _boldFont,
                              fontSize: 14,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Table Header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const pw.BoxDecoration(color: _bgLight),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        _isArabic ? 'المقرر' : 'Course',
                        style: pw.TextStyle(
                          font: _semiBoldFont,
                          fontSize: 9,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        _isArabic ? 'الساعات' : 'Credits',
                        style: pw.TextStyle(
                          font: _semiBoldFont,
                          fontSize: 9,
                          color: _textSecondary,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        _isArabic ? 'التقدم' : 'Progress',
                        style: pw.TextStyle(
                          font: _semiBoldFont,
                          fontSize: 9,
                          color: _textSecondary,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        _isArabic ? 'النسبة' : '%',
                        style: pw.TextStyle(
                          font: _semiBoldFont,
                          fontSize: 9,
                          color: _textSecondary,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        _isArabic ? 'التقدير' : 'Grade',
                        style: pw.TextStyle(
                          font: _semiBoldFont,
                          fontSize: 9,
                          color: _textSecondary,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              // Course Rows
              ...courses.asMap().entries.map((entry) {
                final index = entry.key;
                final course = entry.value;
                final isEven = index % 2 == 0;
                final gradeColor = PdfColor.fromInt(
                  course.currentGrade.color.toARGB32(),
                );

                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : _bgLight,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              course.courseName,
                              style: pw.TextStyle(
                                font: _semiBoldFont,
                                fontSize: 10,
                                color: _textPrimary,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              children: [
                                pw.Text(
                                  course.courseCode,
                                  style: pw.TextStyle(
                                    font: _regularFont,
                                    fontSize: 8,
                                    color: _textMuted,
                                  ),
                                ),
                                pw.Text(
                                  ' • ',
                                  style: pw.TextStyle(
                                    color: _textMuted,
                                    fontSize: 8,
                                  ),
                                ),
                                pw.Text(
                                  course.instructor,
                                  style: pw.TextStyle(
                                    font: _regularFont,
                                    fontSize: 8,
                                    color: _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '${course.creditHours}',
                          style: pw.TextStyle(
                            font: _semiBoldFont,
                            fontSize: 10,
                            color: _textPrimary,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          children: [
                            pw.Container(
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: _borderColor,
                                borderRadius: pw.BorderRadius.circular(3),
                              ),
                              child: pw.Row(
                                children: [
                                  pw.Expanded(
                                    flex: course.currentPercentage.round(),
                                    child: pw.Container(
                                      decoration: pw.BoxDecoration(
                                        color: gradeColor,
                                        borderRadius: pw.BorderRadius.circular(
                                          3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (course.currentPercentage < 100)
                                    pw.Expanded(
                                      flex: (100 - course.currentPercentage)
                                          .round(),
                                      child: pw.Container(),
                                    ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              '${course.gradedCount}/${course.assessments.length} ${_isArabic ? 'تقييم' : 'graded'}',
                              style: pw.TextStyle(
                                font: _regularFont,
                                fontSize: 7,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '${course.currentPercentage.toStringAsFixed(1)}%',
                          style: pw.TextStyle(
                            font: _semiBoldFont,
                            fontSize: 10,
                            color: _textPrimary,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: pw.BoxDecoration(
                            color: gradeColor,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            course.currentGrade.label,
                            style: pw.TextStyle(
                              font: _boldFont,
                              fontSize: 10,
                              color: PdfColors.white,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
      semesterIndex++;
    });

    return widgets;
  }

  // ==================== PERFORMANCE INSIGHTS ====================
  pw.Widget _buildPerformanceInsights(GradeReportData data) {
    final stats = data.statistics;
    final passRate =
        stats?.passRate ??
        (data.courses.where((c) => c.currentGrade.gpa >= 1.0).length /
            data.courses.length *
            100);

    final topCourses = List<CourseGrade>.from(data.courses)
      ..sort((a, b) => b.currentPercentage.compareTo(a.currentPercentage));
    final bottomCourses = List<CourseGrade>.from(data.courses)
      ..sort((a, b) => a.currentPercentage.compareTo(b.currentPercentage));

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 20,
                decoration: pw.BoxDecoration(
                  color: _infoColor,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                _isArabic
                    ? 'رؤى الأداء والتوصيات'
                    : 'Performance Insights & Recommendations',
                style: pw.TextStyle(
                  font: _boldFont,
                  fontSize: 16,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Strengths
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: _successLight,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 24,
                            height: 24,
                            decoration: pw.BoxDecoration(
                              color: _successColor,
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '★',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            _isArabic ? 'نقاط القوة' : 'Strengths',
                            style: pw.TextStyle(
                              font: _boldFont,
                              fontSize: 12,
                              color: _successColor,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      ...topCourses
                          .take(3)
                          .map(
                            (course) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
                              child: pw.Row(
                                children: [
                                  pw.Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const pw.BoxDecoration(
                                      color: _successColor,
                                      shape: pw.BoxShape.circle,
                                    ),
                                  ),
                                  pw.SizedBox(width: 8),
                                  pw.Expanded(
                                    child: pw.Text(
                                      '${course.courseName} (${course.currentPercentage.toStringAsFixed(0)}%)',
                                      style: pw.TextStyle(
                                        font: _regularFont,
                                        fontSize: 9,
                                        color: _textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 15),
              // Areas for Improvement
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: _warningLight,
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        children: [
                          pw.Container(
                            width: 24,
                            height: 24,
                            decoration: pw.BoxDecoration(
                              color: _warningColor,
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '!',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 14,
                                  font: _boldFont,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            _isArabic ? 'يحتاج اهتمام' : 'Needs Focus',
                            style: pw.TextStyle(
                              font: _boldFont,
                              fontSize: 12,
                              color: _warningColor,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      ...bottomCourses
                          .take(3)
                          .where((c) => c.currentPercentage < 80)
                          .map(
                            (course) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
                              child: pw.Row(
                                children: [
                                  pw.Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const pw.BoxDecoration(
                                      color: _warningColor,
                                      shape: pw.BoxShape.circle,
                                    ),
                                  ),
                                  pw.SizedBox(width: 8),
                                  pw.Expanded(
                                    child: pw.Text(
                                      '${course.courseName} (${course.currentPercentage.toStringAsFixed(0)}%)',
                                      style: pw.TextStyle(
                                        font: _regularFont,
                                        fontSize: 9,
                                        color: _textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (bottomCourses
                          .where((c) => c.currentPercentage < 80)
                          .isEmpty)
                        pw.Text(
                          _isArabic
                              ? 'أداء ممتاز في جميع المقررات!'
                              : 'Excellent performance across all courses!',
                          style: pw.TextStyle(
                            font: _regularFont,
                            fontSize: 9,
                            color: _textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          // Key Metrics
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: _infoLight,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  _isArabic ? 'نسبة النجاح' : 'Pass Rate',
                  '${passRate.toStringAsFixed(0)}%',
                  _successColor,
                ),
                _buildMetricItem(
                  _isArabic ? 'متوسط النسبة' : 'Avg Score',
                  '${(data.courses.fold<double>(0, (sum, c) => sum + c.currentPercentage) / data.courses.length).toStringAsFixed(1)}%',
                  _primaryColor,
                ),
                _buildMetricItem(
                  _isArabic ? 'أعلى تقدير' : 'Best Grade',
                  topCourses.first.currentGrade.label,
                  _successColor,
                ),
                _buildMetricItem(
                  _isArabic ? 'الفصول المكتملة' : 'Semesters',
                  '${data.semesters.length}',
                  _infoColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetricItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(font: _boldFont, fontSize: 18, color: color),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: _regularFont,
            fontSize: 8,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  // ==================== ACADEMIC GOALS ====================
  pw.Widget _buildAcademicGoals(GradeReportData data) {
    final creditProgress = (data.completedCredits / data.targetCredits * 100);
    final gpaProgress = (data.cumulativeGPA / 4.0 * 100);

    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [_primaryColor, _secondaryColor],
        ),
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _isArabic ? 'التقدم نحو التخرج' : 'Progress Towards Graduation',
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 16,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildProgressItem(
                  _isArabic ? 'الساعات المعتمدة' : 'Credit Hours',
                  '${data.completedCredits}/${data.targetCredits}',
                  creditProgress,
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildProgressItem(
                  _isArabic ? 'المعدل التراكمي' : 'GPA Target (4.0)',
                  '${data.cumulativeGPA.toStringAsFixed(2)}/4.00',
                  gpaProgress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProgressItem(String label, String value, double progress) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.white.shade(0.15),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
              color: PdfColors.white.shade(0.8),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 20,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            height: 8,
            decoration: pw.BoxDecoration(
              color: PdfColors.white.shade(0.2),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: progress.round().clamp(0, 100),
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                  ),
                ),
                if (progress < 100)
                  pw.Expanded(
                    flex: (100 - progress).round().clamp(0, 100),
                    child: pw.Container(),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${progress.toStringAsFixed(0)}% ${_isArabic ? 'مكتمل' : 'complete'}',
            style: pw.TextStyle(
              font: _semiBoldFont,
              fontSize: 9,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== REPORT SIGNATURE ====================
  pw.Widget _buildReportSignature(GradeReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _bgLight,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _borderColor),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                _isArabic ? 'معلومات التقرير' : 'Report Information',
                style: pw.TextStyle(
                  font: _semiBoldFont,
                  fontSize: 10,
                  color: _textSecondary,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '${_isArabic ? 'تاريخ الإنشاء:' : 'Generated:'} ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: 9,
                  color: _textMuted,
                ),
              ),
              pw.Text(
                '${_isArabic ? 'رقم الطالب:' : 'Student ID:'} ${data.studentId}',
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: 9,
                  color: _textMuted,
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _primaryColor,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'EduVerse',
                  style: pw.TextStyle(
                    font: _boldFont,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  _isArabic ? 'النظام الأكاديمي' : 'Academic System',
                  style: pw.TextStyle(
                    font: _regularFont,
                    fontSize: 8,
                    color: PdfColors.white.shade(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
