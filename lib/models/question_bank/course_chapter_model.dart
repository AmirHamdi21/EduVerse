export '../instructor/question_bank_exam_models.dart' show CourseChapterModel;

class CreateChapterRequest {
  const CreateChapterRequest({required this.name, required this.chapterOrder});

  final String name;
  final int chapterOrder;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'name': name.trim(), 'chapterOrder': chapterOrder};
  }
}

class UpdateChapterRequest {
  const UpdateChapterRequest({this.name, this.chapterOrder, this.isActive});

  final String? name;
  final int? chapterOrder;
  final int? isActive;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
      if (chapterOrder != null) 'chapterOrder': chapterOrder,
      if (isActive != null) 'isActive': isActive,
    };
  }
}
