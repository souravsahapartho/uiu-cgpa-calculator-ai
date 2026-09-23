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
    required this.semesterIndex,
    required this.sgpa,
    required this.cgpa,
    required this.creditsEarned,
    required this.totalCompletedCredits,
    required this.courses,
  });

  int get courseCount => courses.length;

  int get aGradeCount => courses.where((c) => c.grade == 'A' || c.grade == 'A-').length;
}

