import 'course.dart';

class SemesterTranscript {
  final String semesterName;
  final int semesterIndex;
  final double sgpa;
  final double cgpa;
  final double creditsEarned;
  final double totalCompletedCredits;
  final List<Course> courses;

  const SemesterTranscript({
    required this.semesterName,
    this.semesterIndex = 0,
    required this.sgpa,
    required this.cgpa,
    required this.creditsEarned,
    this.totalCompletedCredits = 0.0,
    required this.courses,
  });

  /// In UIU terminology, terms are trimesters and the term average is GPA (not SGPA).
  double get gpa => sgpa;

  int get courseCount => courses.length;

  int get aGradeCount => courses.where((c) => c.grade == 'A' || c.grade == 'A-').length;

  Map<String, dynamic> toJson() {
    return {
      'semesterName': semesterName,
      'semesterIndex': semesterIndex,
      'sgpa': sgpa,
      'cgpa': cgpa,
      'creditsEarned': creditsEarned,
      'totalCompletedCredits': totalCompletedCredits,
      'courses': courses.map((c) => c.toJson()).toList(),
    };
  }

  factory SemesterTranscript.fromJson(Map<String, dynamic> json) {
    final rawCourses = json['courses'] as List<dynamic>? ?? [];
    return SemesterTranscript(
      semesterName: json['semesterName'] as String? ?? 'Trimester',
      semesterIndex: json['semesterIndex'] as int? ?? 0,
      sgpa: (json['sgpa'] as num?)?.toDouble() ?? (json['gpa'] as num?)?.toDouble() ?? 0.0,
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0.0,
      creditsEarned: (json['creditsEarned'] as num?)?.toDouble() ?? 0.0,
      totalCompletedCredits: (json['totalCompletedCredits'] as num?)?.toDouble() ?? 0.0,
      courses: rawCourses
          .map((c) => Course.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  SemesterTranscript copyWith({
    String? semesterName,
    int? semesterIndex,
    double? sgpa,
    double? cgpa,
    double? creditsEarned,
    double? totalCompletedCredits,
    List<Course>? courses,
  }) {
    return SemesterTranscript(
      semesterName: semesterName ?? this.semesterName,
      semesterIndex: semesterIndex ?? this.semesterIndex,
      sgpa: sgpa ?? this.sgpa,
      cgpa: cgpa ?? this.cgpa,
      creditsEarned: creditsEarned ?? this.creditsEarned,
      totalCompletedCredits: totalCompletedCredits ?? this.totalCompletedCredits,
      courses: courses ?? this.courses,
    );
  }
}
