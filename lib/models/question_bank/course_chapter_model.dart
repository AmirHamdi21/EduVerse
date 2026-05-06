class CourseChapterModel {
  const CourseChapterModel({
    required this.id,
    required this.courseId,
    required this.name,
    required this.chapterOrder,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int courseId;
  final String name;
  final int chapterOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CourseChapterModel.fromJson(Map<String, dynamic> json) {
    return CourseChapterModel(
      id: _toInt(json['id'] ?? json['chapterId']),
      courseId: _toInt(json['courseId']),
      name: json['name']?.toString() ?? '',
      chapterOrder: _toInt(json['chapterOrder']),
      isActive: _toBool(json['isActive']),
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'courseId': courseId,
      'name': name,
      'chapterOrder': chapterOrder,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true';
}

DateTime? _toDate(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}
