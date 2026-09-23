enum CourseCategory {
  core,
  lab,
  ged,
  elective,
  math,
  physics,
}

enum CourseDifficulty {
  easy,
  medium,
  hard,
  veryHard,
}

class Course {
  final String code;
  final String title;
  final double credit;
  final String? grade;
  final double? gradePoint;
  final CourseCategory category;
  final CourseDifficulty difficulty;
  final String? prerequisite;
  final String? semesterTaken;

  const Course({
    required this.code,
    required this.title,
    required this.credit,
    this.grade,
    this.gradePoint,
    this.category = CourseCategory.core,
    this.difficulty = CourseDifficulty.medium,
    this.prerequisite,
    this.semesterTaken,
  });

  Course copyWith({
    String? code,
    String? title,
    double? credit,
    String? grade,
    double? gradePoint,
    CourseCategory category,
    CourseDifficulty difficulty,
    String? prerequisite,
    String? semesterTaken,
  }) {
    return Course(
      code: code ?? this.code,
      title: title ?? this.title,
      credit: credit ?? this.credit,
      grade: grade ?? this.grade,
      gradePoint: gradePoint ?? this.gradePoint,
      category: category,
      difficulty: difficulty,
      prerequisite: prerequisite ?? this.prerequisite,
      semesterTaken: semesterTaken ?? this.semesterTaken,
    );
  }

  String get categoryName {
    switch (category) {
      case CourseCategory.core:
        return 'Core';
      case CourseCategory.lab:
        return 'Lab';
      case CourseCategory.ged:
        return 'GED';
      case CourseCategory.elective:
        return 'Elective';
      case CourseCategory.math:
        return 'Math';
      case CourseCategory.physics:
        return 'Science';
    }
  }

  String get difficultyName {
    switch (difficulty) {
      case CourseDifficulty.easy:
        return 'Light';
      case CourseDifficulty.medium:
        return 'Moderate';
      case CourseDifficulty.hard:
        return 'Challenging';
      case CourseDifficulty.veryHard:
        return 'Intense';
    }
  }
}

