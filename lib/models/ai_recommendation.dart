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
  final String examDay; // e.g. 'Day 1', 'N/A'
  final String examSlot; // e.g. 'T1', 'T2', 'N/A'
  final bool hasSameDayExam;
  final String? sameDayWithCourse;
  final bool isProject; // e.g. FYDP
  final bool isLab;
  final bool isGed;
  final bool isElective;
  final bool isChoiceOption;
  final String? trackName;
  final List<String> optionCodes;
  final List<ChoiceOptionDetail> choiceDetails;

  const CourseRecommendation({
    required this.course,
    required this.reason,
    required this.unlockRationale,
    required this.priorityRank,
    this.examDay = 'N/A',
    this.examSlot = 'N/A',
    this.hasSameDayExam = false,
    this.sameDayWithCourse,
    this.isProject = false,
    this.isLab = false,
    this.isGed = false,
    this.isElective = false,
    this.isChoiceOption = false,
    this.trackName,
    this.optionCodes = const [],
    this.choiceDetails = const [],
  });

  CourseRecommendation copyWith({
    Course? course,
    String? reason,
    String? unlockRationale,
    int? priorityRank,
    String? examDay,
    String? examSlot,
    bool? hasSameDayExam,
    String? sameDayWithCourse,
    bool? isProject,
    bool? isLab,
    bool? isGed,
    bool? isElective,
    bool? isChoiceOption,
    String? trackName,
    List<String>? optionCodes,
    List<ChoiceOptionDetail>? choiceDetails,
  }) {
    return CourseRecommendation(
      course: course ?? this.course,
      reason: reason ?? this.reason,
      unlockRationale: unlockRationale ?? this.unlockRationale,
      priorityRank: priorityRank ?? this.priorityRank,
      examDay: examDay ?? this.examDay,
      examSlot: examSlot ?? this.examSlot,
      hasSameDayExam: hasSameDayExam ?? this.hasSameDayExam,
      sameDayWithCourse: sameDayWithCourse ?? this.sameDayWithCourse,
      isProject: isProject ?? this.isProject,
      isLab: isLab ?? this.isLab,
      isGed: isGed ?? this.isGed,
      isElective: isElective ?? this.isElective,
      isChoiceOption: isChoiceOption ?? this.isChoiceOption,
      trackName: trackName ?? this.trackName,
      optionCodes: optionCodes ?? this.optionCodes,
      choiceDetails: choiceDetails ?? this.choiceDetails,
    );
  }
}

class ChoiceOptionDetail {
  final String code;
  final String title;
  final String examDay;
  final String examSlot;
  final double credit;

  const ChoiceOptionDetail({
    required this.code,
    required this.title,
    this.examDay = 'N/A',
    this.examSlot = 'N/A',
    this.credit = 3.0,
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
  final bool isMeritScholarshipEligible;
  final String? meritScholarshipNotice;

  const AIAdvisorReport({
    required this.overallSummary,
    required this.currentPaceCGPA,
    required this.projectedFinalCGPA,
    required this.domainAnalyses,
    required this.recommendedCourses,
    required this.conflictWarnings,
    required this.gpaBoosterTips,
    required this.suggestedCreditLoad,
    this.isMeritScholarshipEligible = false,
    this.meritScholarshipNotice,
  });
}

