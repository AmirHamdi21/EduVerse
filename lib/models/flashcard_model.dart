class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String topic;
  bool isMarkedAsKnown;
  bool isMarkedForReview;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.topic,
    this.isMarkedAsKnown = false,
    this.isMarkedForReview = false,
  });
}

class StudySet {
  final String id;
  final String name;
  final List<Flashcard> cards;
  final DateTime createdAt;
  final String courseId;

  StudySet({
    required this.id,
    required this.name,
    required this.cards,
    required this.createdAt,
    required this.courseId,
  });
}

class Course {
  final String id;
  final String name;
  final String icon;

  Course({
    required this.id,
    required this.name,
    required this.icon,
  });
}
