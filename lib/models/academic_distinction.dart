enum VerificationLevel {
  officiallyVerified,
  partiallyVerified,
  notAwardedAtUIU,
  unverified,
}

enum EligibilityStatus {
  eligible,
  notEligible,
  disqualified,
  cannotDetermine,
  notAwarded,
}

class DistinctionRequirement {
  final String title;
  final String description;
  final bool isMet;
  final bool isMandatory;

  const DistinctionRequirement({
    required this.title,
    required this.description,
    required this.isMet,
    this.isMandatory = true,
  });
}

class AcademicDistinction {
  final String id;
  final String name;
  final String honorType; // 'Gold Medal' | 'Latin Honor' | 'Class Honor'
  final String description;
  final VerificationLevel verificationLevel;
  final String verificationNote;
  final String officialSourceTitle;
  final String? officialSourceUrl;
  final String policyEffectiveDate;
  final EligibilityStatus status;
  final String statusReason;
  final double? minCgpa;
  final double? maxCgpa;
  final bool requiresBatchTopper;
  final bool requiresFacultyTopper;
  final bool prohibitsImprovementExam;
  final bool prohibitsMakeupExam;
  final bool prohibitsRetakes;
  final bool requiresNormalDuration;
  final List<DistinctionRequirement> requirements;
  final List<String> disqualifiers;

  const AcademicDistinction({
    required this.id,
    required this.name,
    required this.honorType,
    required this.description,
    required this.verificationLevel,
    required this.verificationNote,
    required this.officialSourceTitle,
    this.officialSourceUrl,
    required this.policyEffectiveDate,
    required this.status,
    required this.statusReason,
    this.minCgpa,
    this.maxCgpa,
    this.requiresBatchTopper = false,
    this.requiresFacultyTopper = false,
    this.prohibitsImprovementExam = false,
    this.prohibitsMakeupExam = false,
    this.prohibitsRetakes = false,
    this.requiresNormalDuration = false,
    required this.requirements,
    required this.disqualifiers,
  });
}

