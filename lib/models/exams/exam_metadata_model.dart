class ExamMetadataModel {
  const ExamMetadataModel({
    this.durationMinutes,
    this.instructions = '',
    this.headerText = '',
    this.footerText = '',
  });

  final int? durationMinutes;
  final String instructions;
  final String headerText;
  final String footerText;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (instructions.trim().isNotEmpty) 'instructions': instructions.trim(),
      if (headerText.trim().isNotEmpty) 'headerText': headerText.trim(),
      if (footerText.trim().isNotEmpty) 'footerText': footerText.trim(),
    };
  }
}
