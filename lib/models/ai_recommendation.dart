import 'course.dart';

class SubjectDomainAnalysis {
  final String domain;
  final double scorePercent; // 0-100
  final String status; // 'Strong', 'Average', 'Needs Focus'
  final String insight;
  final bool isStrength;

  const SubjectDomainAnalysis({
    required this.domain,
    required this.scorePercent,
    required this.status,
    required this.insight,
    required this.isStrength,
  });
}

class CourseRecommendation {
  final Course course;
  final String reason;
  final String unlockRationale;
  final int priorityRank; // 1 = highest

  const CourseRecommendation({
    required this.course,
    required this.reason,
    required this.unlockRationale,
    required this.priorityRank,
  });
}

class CourseConflictWarning {
  final String title;
  final List<String> conflictingCourses;
  final String severity; // 'High', 'Moderate'
  final String explanation;
  final String recommendation;

  const CourseConflictWarning({
    required this.title,
    required this.conflictingCourses,
    required this.severity,
    required this.explanation,
    required this.recommendation,
  });
}

class AIAdvisorReport {
  final String overallSummary;
  final double currentPaceCGPA;
  final double projectedFinalCGPA;
  final List<SubjectDomainAnalysis> domainAnalyses;
  final List<CourseRecommendation> recommendedCourses;
  final List<CourseConflictWarning> conflictWarnings;
  final List<String> gpaBoosterTips;
  final double suggestedCreditLoad;

  const AIAdvisorReport({
    required this.overallSummary,
    required this.currentPaceCGPA,
    required this.projectedFinalCGPA,
    required this.domainAnalyses,
    required this.recommendedCourses,
    required this.conflictWarnings,
    required this.gpaBoosterTips,
    required this.suggestedCreditLoad,
  });
}

