import 'exam_generator_enums.dart';

class ExamExportOptionsModel {
  const ExamExportOptionsModel({
    this.format = ExamExportFormat.htmlDoc,
    this.variant = ExamExportVariant.student,
    this.studentNameLine = true,
    this.showCourseCode = true,
    this.pageBreakPerSection = false,
    this.showInstructorName = false,
    this.answerKeyStyle = ExamAnswerKeyStyle.inline,
    this.paperTemplateId,
    this.paperTemplateSnapshot,
  });

  final ExamExportFormat format;
  final ExamExportVariant variant;
  final bool studentNameLine;
  final bool showCourseCode;
  final bool pageBreakPerSection;
  final bool showInstructorName;
  final ExamAnswerKeyStyle answerKeyStyle;
  final int? paperTemplateId;
  final Map<String, dynamic>? paperTemplateSnapshot;

  bool get includeAnswerKey =>
      variant == ExamExportVariant.answerKey || variant == ExamExportVariant.combined;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'format': format.value,
      'variant': variant.value,
      'includeAnswerKey': includeAnswerKey,
      'studentNameLine': studentNameLine,
      'showCourseCode': showCourseCode,
      'pageBreakPerSection': pageBreakPerSection,
      'showInstructorName': showInstructorName,
      'answerKeyStyle': answerKeyStyle.value,
      if (paperTemplateId != null) 'paperTemplateId': paperTemplateId,
      if (paperTemplateSnapshot != null)
        'paperTemplateSnapshot': paperTemplateSnapshot,
    };
  }
}
