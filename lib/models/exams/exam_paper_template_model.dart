import 'exam_export_options_model.dart';

enum ExamPaperLayoutMode {
  structured('structured'),
  free('free'),
  hybrid('hybrid');

  const ExamPaperLayoutMode(this.value);
  final String value;

  static ExamPaperLayoutMode fromValue(String? value) {
    return ExamPaperLayoutMode.values.firstWhere(
      (mode) => mode.value == value,
      orElse: () => ExamPaperLayoutMode.hybrid,
    );
  }
}

class ExamPaperTemplateModel {
  const ExamPaperTemplateModel({
    this.id,
    this.courseId,
    required this.name,
    this.layoutMode = ExamPaperLayoutMode.hybrid,
    this.pageSize = 'A4',
    this.orientation = 'portrait',
    this.marginsJson = const <String, dynamic>{},
    this.headerJson = const <String, dynamic>{},
    this.trailingJson = const <String, dynamic>{},
    this.footerJson = const <String, dynamic>{},
  });

  final int? id;
  final int? courseId;
  final String name;
  final ExamPaperLayoutMode layoutMode;
  final String pageSize;
  final String orientation;
  final Map<String, dynamic> marginsJson;
  final Map<String, dynamic> headerJson;
  final Map<String, dynamic> trailingJson;
  final Map<String, dynamic> footerJson;

  factory ExamPaperTemplateModel.fromJson(Map<String, dynamic> json) {
    final snapshot = _map(json['snapshot']);
    final source = snapshot.isNotEmpty ? snapshot : json;
    return ExamPaperTemplateModel(
      id: _nullableInt(json['id'] ?? json['templateId'] ?? source['templateId']),
      courseId: _nullableInt(json['courseId'] ?? source['courseId']),
      name: (json['name'] ?? source['name'] ?? 'Paper template').toString(),
      layoutMode: ExamPaperLayoutMode.fromValue(
        (json['layoutMode'] ?? source['layoutMode'])?.toString(),
      ),
      pageSize: (json['pageSize'] ?? source['pageSize'] ?? 'A4').toString(),
      orientation:
          (json['orientation'] ?? source['orientation'] ?? 'portrait').toString(),
      marginsJson: _map(json['marginsJson'] ?? source['marginsJson']),
      headerJson: _map(json['headerJson'] ?? source['headerJson']),
      trailingJson: _map(json['trailingJson'] ?? source['trailingJson']),
      footerJson: _map(json['footerJson'] ?? source['footerJson']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'templateId': id,
      if (courseId != null) 'courseId': courseId,
      'name': name,
      'layoutMode': layoutMode.value,
      'pageSize': pageSize,
      'orientation': orientation,
      'marginsJson': marginsJson,
      'headerJson': headerJson,
      'trailingJson': trailingJson,
      'footerJson': footerJson,
    };
  }

  Map<String, dynamic> toSnapshot() => <String, dynamic>{
    if (id != null) 'templateId': id,
    'name': name,
    'layoutMode': layoutMode.value,
    'pageSize': pageSize,
    'orientation': orientation,
    'marginsJson': marginsJson,
    'headerJson': headerJson,
    'trailingJson': trailingJson,
    'footerJson': footerJson,
  };

  ExamPaperTemplateModel copyWith({
    int? id,
    int? courseId,
    String? name,
    ExamPaperLayoutMode? layoutMode,
    String? pageSize,
    String? orientation,
    Map<String, dynamic>? marginsJson,
    Map<String, dynamic>? headerJson,
    Map<String, dynamic>? trailingJson,
    Map<String, dynamic>? footerJson,
    bool clearId = false,
  }) {
    return ExamPaperTemplateModel(
      id: clearId ? null : id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      layoutMode: layoutMode ?? this.layoutMode,
      pageSize: pageSize ?? this.pageSize,
      orientation: orientation ?? this.orientation,
      marginsJson: marginsJson ?? this.marginsJson,
      headerJson: headerJson ?? this.headerJson,
      trailingJson: trailingJson ?? this.trailingJson,
      footerJson: footerJson ?? this.footerJson,
    );
  }

  factory ExamPaperTemplateModel.alexandriaDefault({
    int? courseId,
    String? courseCode,
    String? courseName,
    int? durationMinutes,
  }) {
    return ExamPaperTemplateModel(
      courseId: courseId,
      name: 'Alexandria paper style',
      layoutMode: ExamPaperLayoutMode.hybrid,
      headerJson: <String, dynamic>{
        'left': <Map<String, dynamic>>[
          {'value': 'Alexandria University', 'bold': true},
          {'value': 'Faculty of Engineering', 'bold': true},
          {'value': 'Department'},
        ],
        'center': <Map<String, dynamic>>[
          {'value': 'Alexandria University'},
          {'value': '[Logo]'},
        ],
        'right': <Map<String, dynamic>>[
          {'value': 'جامعة الإسكندرية', 'bold': true},
          {'value': 'كلية الهندسة', 'bold': true},
          {'value': 'القسم'},
        ],
        'metadataLeft': <Map<String, dynamic>>[
          {'value': 'Date: {date}'},
          {'value': courseName?.isNotEmpty == true ? courseName : '{courseName}'},
          {
            'value': durationMinutes != null
                ? 'Time allowed: $durationMinutes minutes'
                : 'Time allowed: {duration}',
          },
        ],
        'metadataRight': <Map<String, dynamic>>[
          {'value': 'العام الجامعي: {academicYear}'},
          {'value': courseCode?.isNotEmpty == true ? 'المادة: $courseCode' : 'المادة: {courseCode}'},
          {
            'value': durationMinutes != null
                ? 'الزمن: $durationMinutes دقيقة'
                : 'الزمن: {duration}',
          },
        ],
        'freeElements': <Map<String, dynamic>>[],
      },
      trailingJson: <String, dynamic>{
        'lines': <Map<String, dynamic>>[
          {'value': 'End of questions'},
          {'value': 'Good Luck'},
        ],
        'examiners': 'Examiners: ______________________________',
      },
      footerJson: <String, dynamic>{
        'pageNumberFormat': 'Page {page} of {totalPages}',
      },
    );
  }
}

class ExamPaperExportPayload {
  const ExamPaperExportPayload({
    required this.options,
    required this.template,
  });

  final ExamExportOptionsModel options;
  final ExamPaperTemplateModel template;
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
