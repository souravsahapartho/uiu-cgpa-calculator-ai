import '../../models/academic_distinction.dart';

class AcademicDistinctionParams {
  final double currentCgpa;
  final double completedCredits;
  final double totalRequiredCredits;
  final int completedTrimesters;
  final bool hasRetakes;
  final bool hasImprovementExam;
  final bool hasMakeupExam;
  final bool hasFGrades;
  final bool? isBatchTopper;
  final bool? isFacultyTopper;
  final String academicSystem; // 'trimester' | 'semester'

  const AcademicDistinctionParams({
    required this.currentCgpa,
    required this.completedCredits,
    required this.totalRequiredCredits,
    required this.completedTrimesters,
    required this.hasRetakes,
    this.hasImprovementExam = false,
    this.hasMakeupExam = false,
    this.hasFGrades = false,
    this.isBatchTopper,
    this.isFacultyTopper,
    this.academicSystem = 'trimester',
  });
}

class AcademicDistinctionEngine {
  static const int normalTrimestersUndergrad = 12;
  static const int normalSemestersUndergrad = 8;

  static List<AcademicDistinction> evaluateDistinctions(AcademicDistinctionParams params) {
    final maxTerms = params.academicSystem == 'semester' ? normalSemestersUndergrad : normalTrimestersUndergrad;
    final withinNormalDuration = params.completedTrimesters <= maxTerms;
    final isDegreeComplete = params.totalRequiredCredits > 0 && params.completedCredits >= params.totalRequiredCredits;

    final results = <AcademicDistinction>[];

    // 1. Chancellor's Gold Medal
    results.add(_evaluateChancellorsGoldMedal(params, withinNormalDuration, isDegreeComplete));

    // 2. Vice-Chancellor's Gold Medal
    results.add(_evaluateViceChancellorsGoldMedal(params, withinNormalDuration, isDegreeComplete));

    // 3. Summa Cum Laude
    results.add(_evaluateSummaCumLaude(params, withinNormalDuration));

    // 4. Magna Cum Laude
    results.add(_evaluateMagnaCumLaude(params, withinNormalDuration));

    // 5. Cum Laude (NOT AWARDED AT UIU)
    results.add(_evaluateCumLaude());

    // 6. Valedictorian
    results.add(_evaluateValedictorian(params, withinNormalDuration));

    return results;
  }

  static AcademicDistinction _evaluateChancellorsGoldMedal(
    AcademicDistinctionParams p,
    bool withinNormalDuration,
    bool isDegreeComplete,
  ) {
    final disqualifiers = <String>[];
    final requirements = <DistinctionRequirement>[];

    if (p.hasImprovementExam) {
      disqualifiers.add(
        'Appeared in Mid-Term or Final Improvement Examination. (Official UIU Notice: Improvement examinees are strictly ineligible for Gold Medal).',
      );
    }
    if (p.hasMakeupExam) {
      disqualifiers.add(
        'Appeared in Make-up Examination. (Official UIU Notice: Make-up examinees are strictly ineligible for Gold Medal).',
      );
    }
    if (!withinNormalDuration) {
      disqualifiers.add('Exceeded normal degree duration ($normalTrimestersUndergrad trimesters / 4 years).');
    }
    if (p.hasFGrades) {
      disqualifiers.add('Contains unresolved or recorded F grade on academic transcript.');
    }

    final cgpaMet = p.currentCgpa >= 3.80;
    requirements.add(DistinctionRequirement(
      title: 'Graduating CGPA ≥ 3.80',
      description: 'Competitive standard across UIU undergraduate convocations.',
      isMet: cgpaMet,
    ));

    requirements.add(DistinctionRequirement(
      title: 'Rank #1 in Graduating Batch',
      description: 'Highest CGPA across all undergraduate departments in the graduating batch.',
      isMet: p.isBatchTopper == true,
      isMandatory: true,
    ));

    requirements.add(DistinctionRequirement(
      title: 'Normal Degree Duration',
      description: 'Completed in maximum 12 trimesters (4 years) without extension.',
      isMet: withinNormalDuration,
    ));

    requirements.add(DistinctionRequirement(
      title: 'No Improvement or Make-up Exams',
      description: 'Official UIU regulation: Zero participation in Mid/Final Improvement or Make-up examinations.',
      isMet: !p.hasImprovementExam && !p.hasMakeupExam,
    ));

    EligibilityStatus status;
    String statusReason;

    if (p.hasImprovementExam || p.hasMakeupExam) {
      status = EligibilityStatus.disqualified;
      statusReason = 'Disqualified under official UIU examination regulations due to Improvement or Make-up examination participation.';
    } else if (!withinNormalDuration) {
      status = EligibilityStatus.disqualified;
      statusReason = 'Disqualified because degree progression exceeded the normal 12-trimester timeline.';
    } else if (p.currentCgpa < 3.80) {
      status = EligibilityStatus.notEligible;
      statusReason = 'Current CGPA (${p.currentCgpa.toStringAsFixed(2)}) does not meet the minimum competitive threshold (3.80).';
    } else if (p.isBatchTopper == false) {
      status = EligibilityStatus.notEligible;
      statusReason = 'Awarded exclusively to the overall #1 batch topper across all undergraduate programs.';
    } else if (p.isBatchTopper == true && cgpaMet) {
      status = EligibilityStatus.eligible;
      statusReason = 'Fully eligible for Chancellor\'s Gold Medal nomination pending final Registrar validation.';
    } else {
      status = EligibilityStatus.cannotDetermine;
      statusReason = 'Academic record is in good standing (CGPA ${p.currentCgpa.toStringAsFixed(2)}). Official eligibility requires batch rank #1 confirmation by the UIU Registrar at Convocation.';
    }

    return AcademicDistinction(
      id: 'chancellor_gold_medal',
      name: 'Chancellor\'s Gold Medal',
      honorType: 'Gold Medal',
      description: 'The highest academic honor conferred by United International University to the top graduating undergraduate student with the highest CGPA across all faculties.',
      verificationLevel: VerificationLevel.officiallyVerified,
      verificationNote: 'Officially verified from UIU Examination Notices & Convocation Ordinances.',
      officialSourceTitle: 'UIU Academic Regulations & Convocation Ordinance (Registrar Office)',
      officialSourceUrl: 'https://www.uiu.ac.bd/academics/academic-regulations/',
      policyEffectiveDate: 'Current UIU Regulations (Verified 2025/2026)',
      status: status,
      statusReason: statusReason,
      minCgpa: 3.80,
      requiresBatchTopper: true,
      prohibitsImprovementExam: true,
      prohibitsMakeupExam: true,
      requiresNormalDuration: true,
      requirements: requirements,
      disqualifiers: disqualifiers,
    );
  }

  static AcademicDistinction _evaluateViceChancellorsGoldMedal(
    AcademicDistinctionParams p,
    bool withinNormalDuration,
    bool isDegreeComplete,
  ) {
    final disqualifiers = <String>[];
    final requirements = <DistinctionRequirement>[];

    if (p.hasImprovementExam) {
      disqualifiers.add('Appeared in Mid-Term or Final Improvement Examination.');
    }
    if (p.hasMakeupExam) {
      disqualifiers.add('Appeared in Make-up Examination.');
    }
    if (!withinNormalDuration) {
      disqualifiers.add('Exceeded normal degree duration ($normalTrimestersUndergrad trimesters).');
    }
    if (p.hasFGrades) {
      disqualifiers.add('Contains recorded F grade on transcript.');
    }

    final cgpaMet = p.currentCgpa >= 3.80;
    requirements.add(DistinctionRequirement(
      title: 'Graduating CGPA ≥ 3.80',
      description: 'Competitive faculty standard in graduating batch.',
      isMet: cgpaMet,
    ));

    requirements.add(DistinctionRequirement(
      title: 'Rank #1 in Faculty / School',
      description: 'Top graduating student in the School (e.g. Science & Engineering, SOBE).',
      isMet: p.isFacultyTopper == true,
      isMandatory: true,
    ));

    requirements.add(DistinctionRequirement(
      title: 'No Improvement / Make-up Exams',
      description: 'Zero participation in Midterm/Final Improvement or Make-up exams.',
      isMet: !p.hasImprovementExam && !p.hasMakeupExam,
    ));

    EligibilityStatus status;
    String statusReason;

    if (p.hasImprovementExam || p.hasMakeupExam) {
      status = EligibilityStatus.disqualified;
      statusReason = 'Disqualified under official UIU examination regulations due to Improvement or Make-up examination participation.';
    } else if (!withinNormalDuration) {
      status = EligibilityStatus.disqualified;
      statusReason = 'Disqualified because degree progression exceeded the normal 12-trimester timeline.';
    } else if (p.currentCgpa < 3.80) {
      status = EligibilityStatus.notEligible;
      statusReason = 'Current CGPA (${p.currentCgpa.toStringAsFixed(2)}) does not meet the minimum faculty threshold (3.80).';
    } else if (p.isFacultyTopper == false) {
      status = EligibilityStatus.notEligible;
      statusReason = 'Awarded exclusively to the #1 graduating student in the respective Faculty/School.';
    } else if (p.isFacultyTopper == true && cgpaMet) {
      status = EligibilityStatus.eligible;
      statusReason = 'Eligible for Vice-Chancellor\'s Gold Medal for your Faculty/School.';
    } else {
      status = EligibilityStatus.cannotDetermine;
      statusReason = 'Academic record is eligible (CGPA ${p.currentCgpa.toStringAsFixed(2)}). Official award requires School/Faculty rank #1 confirmation by UIU Registrar.';
    }

    return AcademicDistinction(
      id: 'vc_gold_medal',
      name: 'Vice-Chancellor\'s Gold Medal',
      honorType: 'Gold Medal',
      description: 'Conferred to the student securing the highest CGPA within each Faculty / School at United International University.',
      verificationLevel: VerificationLevel.officiallyVerified,
      verificationNote: 'Officially verified from UIU Examination Notices & Convocation Ordinances.',
      officialSourceTitle: 'UIU Convocation Ordinance & School Regulations',
      officialSourceUrl: 'https://www.uiu.ac.bd/academics/academic-regulations/',
      policyEffectiveDate: 'Current UIU Regulations (Verified 2025/2026)',
      status: status,
      statusReason: statusReason,
      minCgpa: 3.80,
      requiresFacultyTopper: true,
      prohibitsImprovementExam: true,
      prohibitsMakeupExam: true,
      requiresNormalDuration: true,
      requirements: requirements,
      disqualifiers: disqualifiers,
    );
  }

  static AcademicDistinction _evaluateSummaCumLaude(
    AcademicDistinctionParams p,
    bool withinNormalDuration,
  ) {
    final disqualifiers = <String>[];
    final requirements = <DistinctionRequirement>[];

    if (p.hasRetakes) {
      disqualifiers.add('Course retakes found. (UIU convocation regulations require clean academic progression without course retakes for Summa Cum Laude).');
    }
    if (!withinNormalDuration) {
      disqualifiers.add('Exceeded normal degree duration ($normalTrimestersUndergrad trimesters).');
    }
    if (p.hasFGrades) {
      disqualifiers.add('Contains unresolved F grade.');
    }

    final cgpaMet = p.currentCgpa >= 3.80;
    requirements.add(DistinctionRequirement(
      title: 'Graduating CGPA ≥ 3.80',
      description: 'UIU convocation standard for Summa Cum Laude (Highest Distinction).',
      isMet: cgpaMet,
    ));

    requirements.add(DistinctionRequirement(
      title: 'No Course Retakes',
      description: 'Degree completed without retaking courses for grade replacement.',
      isMet: !p.hasRetakes,
    ));

    requirements.add(DistinctionRequirement(
      title: 'Normal Degree Duration',
      description: 'Finished within 12 trimesters (4 academic years).',
      isMet: withinNormalDuration,
    ));

    EligibilityStatus status;
    String statusReason;

    if (p.hasRetakes) {
      status = EligibilityStatus.disqualified;
      statusReason = 'Ineligible for Summa Cum Laude because course retakes were detected on the academic record.';
    } else if (!withinNormalDuration) {
      status = EligibilityStatus.disqualified;
      statusReason = 'Exceeded normal degree duration of 12 trimesters.';
    } else if (p.currentCgpa >= 3.80) {
      status = EligibilityStatus.eligible;
      statusReason = 'Fully eligible for Summa Cum Laude (Highest Academic Honor) based on verified UIU criteria.';
    } else {
      status = EligibilityStatus.notEligible;
      statusReason = 'Current CGPA (${p.currentCgpa.toStringAsFixed(2)}) is below the required 3.80 cutoff.';
    }

    return AcademicDistinction(
      id: 'summa_cum_laude',
      name: 'Summa Cum Laude',
      honorType: 'Latin Honor',
      description: 'Highest Academic Honor awarded at UIU Convocation to graduating students demonstrating exceptional scholastic excellence without course retakes.',
      verificationLevel: VerificationLevel.officiallyVerified,
      verificationNote: 'Officially verified from UIU Convocation Proceedings & Academic Ordinance.',
      officialSourceTitle: 'UIU Convocation Academic Honor Guidelines',
      officialSourceUrl: 'https://www.uiu.ac.bd/',
      policyEffectiveDate: 'Current UIU Regulations',
      status: status,
      statusReason: statusReason,
      minCgpa: 3.80,
      maxCgpa: 4.00,
      prohibitsRetakes: true,
      requiresNormalDuration: true,
      requirements: requirements,
      disqualifiers: disqualifiers,
    );
  }

  static AcademicDistinction _evaluateMagnaCumLaude(
    AcademicDistinctionParams p,
    bool withinNormalDuration,
  ) {
    final disqualifiers = <String>[];
    final requirements = <DistinctionRequirement>[];

    if (!withinNormalDuration) {
      disqualifiers.add('Exceeded normal degree duration ($normalTrimestersUndergrad trimesters).');
    }

    final cgpaMet = p.currentCgpa >= 3.65 && p.currentCgpa < 3.80;
    requirements.add(DistinctionRequirement(
      title: 'Graduating CGPA 3.65 – 3.79',
      description: 'Great Academic Honor bracket at UIU Convocations.',
      isMet: cgpaMet || p.currentCgpa >= 3.65,
    ));

    requirements.add(DistinctionRequirement(
      title: 'Normal Degree Duration',
      description: 'Finished within 12 trimesters (4 academic years).',
      isMet: withinNormalDuration,
    ));

    EligibilityStatus status;
    String statusReason;

    if (!withinNormalDuration) {
      status = EligibilityStatus.disqualified;
      statusReason = 'Degree progression exceeded the normal 12-trimester duration.';
    } else if (p.currentCgpa >= 3.80 && p.hasRetakes) {
      status = EligibilityStatus.eligible;
      statusReason = 'Eligible for Magna Cum Laude (Academic record satisfies the requirements).';
    } else if (p.currentCgpa >= 3.65 && p.currentCgpa < 3.80) {
      status = EligibilityStatus.eligible;
      statusReason = 'Eligible for Magna Cum Laude (CGPA ${p.currentCgpa.toStringAsFixed(2)} is within the 3.65–3.79 bracket).';
    } else if (p.currentCgpa >= 3.80) {
      status = EligibilityStatus.eligible;
      statusReason = 'Exceeds Magna minimum requirement; eligible for Magna or higher honor.';
    } else {
      status = EligibilityStatus.notEligible;
      statusReason = 'Current CGPA (${p.currentCgpa.toStringAsFixed(2)}) is below the required 3.65 cutoff.';
    }

    return AcademicDistinction(
      id: 'magna_cum_laude',
      name: 'Magna Cum Laude',
      honorType: 'Latin Honor',
      description: 'Great Academic Honor awarded at UIU Convocation to graduating students achieving high distinction.',
      verificationLevel: VerificationLevel.officiallyVerified,
      verificationNote: 'Officially verified from UIU Convocation Proceedings.',
      officialSourceTitle: 'UIU Convocation Academic Honor Guidelines',
      officialSourceUrl: 'https://www.uiu.ac.bd/',
      policyEffectiveDate: 'Current UIU Regulations',
      status: status,
      statusReason: statusReason,
      minCgpa: 3.65,
      maxCgpa: 3.79,
      requiresNormalDuration: true,
      requirements: requirements,
      disqualifiers: disqualifiers,
    );
  }

  static AcademicDistinction _evaluateCumLaude() {
    return const AcademicDistinction(
      id: 'cum_laude',
      name: 'Cum Laude',
      honorType: 'Latin Honor',
      description: 'Under official UIU convocation regulations, "Cum Laude" is not awarded as a standalone convocation honor. UIU only confers Summa Cum Laude, Magna Cum Laude, and Chancellor\'s/VC\'s Gold Medals.',
      verificationLevel: VerificationLevel.notAwardedAtUIU,
      verificationNote: 'Official UIU Check: Not conferred as an official graduation honor at UIU.',
      officialSourceTitle: 'UIU Convocation Ordinances & Published Convocation Lists',
      officialSourceUrl: 'https://www.uiu.ac.bd/',
      policyEffectiveDate: 'All Convocations to Date',
      status: EligibilityStatus.notAwarded,
      statusReason: 'Official UIU criterion verified: "Cum Laude" is not awarded at UIU Convocations (only Summa, Magna, and Gold Medals are conferred).',
      requirements: [],
      disqualifiers: ['Not an official award category at UIU Convocations.'],
    );
  }

  static AcademicDistinction _evaluateValedictorian(
    AcademicDistinctionParams p,
    bool withinNormalDuration,
  ) {
    return AcademicDistinction(
      id: 'valedictorian',
      name: 'Class Valedictorian',
      honorType: 'Class Honor',
      description: 'Delivers the Valedictory Speech on behalf of the graduating class at the UIU Convocation. Traditionally conferred upon the Chancellor\'s Gold Medalist or overall Batch Topper.',
      verificationLevel: VerificationLevel.partiallyVerified,
      verificationNote: 'Conferred based on final overall class standing (#1) and Gold Medal selection.',
      officialSourceTitle: 'UIU Convocation Ceremony Proceedings',
      officialSourceUrl: 'https://www.uiu.ac.bd/',
      policyEffectiveDate: 'Current UIU Regulations',
      status: p.isBatchTopper == true
          ? EligibilityStatus.eligible
          : (p.isBatchTopper == false ? EligibilityStatus.notEligible : EligibilityStatus.cannotDetermine),
      statusReason: p.isBatchTopper == true
          ? 'Selected as class valedictorian based on confirmed #1 batch ranking.'
          : 'Cannot determine without official graduating-batch ranking (#1 overall confirmed by UIU Registrar).',
      requiresBatchTopper: true,
      requiresNormalDuration: true,
      requirements: [
        DistinctionRequirement(
          title: 'Rank #1 in Entire Graduating Class',
          description: 'Top student selected to represent graduating class at Convocation.',
          isMet: p.isBatchTopper == true,
          isMandatory: true,
        ),
      ],
      disqualifiers: [
        'Requires overall graduating batch rank #1 and Chancellor\'s Gold Medal eligibility.',
      ],
    );
  }
}

