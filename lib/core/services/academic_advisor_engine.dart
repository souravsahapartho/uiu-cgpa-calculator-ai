import '../../models/ai_recommendation.dart';
import '../../models/course.dart';
import '../../models/semester_transcript.dart';
import '../providers/user_profile_provider.dart';

/// Official UIU Course Offering Curriculum Definition
class UIUCurriculumCourse {
  final int trimester; // 1 to 12, or 0 for GenEd/Elective
  final int sl;
  final String code;
  final String title;
  final double credit;
  final String prerequisite;
  final String examDay;
  final String examSlot;
  final bool isLab;
  final String domain;

  const UIUCurriculumCourse({
    required this.trimester,
    required this.sl,
    required this.code,
    required this.title,
    required this.credit,
    required this.prerequisite,
    required this.examDay,
    required this.examSlot,
    required this.isLab,
    required this.domain,
  });
}

class AcademicAdvisorEngine {
  /// Complete UIU CSE Curriculum & Course Sequence with Prerequisites and Exam Schedules
  static const List<UIUCurriculumCourse> uiuCurriculum = [
    // Trimester 1
    UIUCurriculumCourse(trimester: 1, sl: 1, code: 'ENG 1011', title: 'English I', credit: 3.0, prerequisite: 'X', examDay: 'Day 1', examSlot: 'T1', isLab: false, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 1, sl: 2, code: 'BDS 1201', title: 'History of the Emergence of Bangladesh', credit: 2.0, prerequisite: 'X', examDay: 'Day 6', examSlot: 'T1', isLab: false, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 1, sl: 3, code: 'CSE 1110', title: 'Introduction to Computer Systems', credit: 1.0, prerequisite: 'X', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 1, sl: 4, code: 'MATH 1151', title: 'Fundamental Calculus', credit: 3.0, prerequisite: 'X', examDay: 'Day 2', examSlot: 'T2', isLab: false, domain: 'Mathematics'),

    // Trimester 2
    UIUCurriculumCourse(trimester: 2, sl: 1, code: 'ENG 1013', title: 'English II', credit: 3.0, prerequisite: 'ENG 1011', examDay: 'Day 1', examSlot: 'T2', isLab: false, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 2, sl: 2, code: 'CSE 1111', title: 'Structured Programming Language', credit: 3.0, prerequisite: 'CSE 1110', examDay: 'Day 4', examSlot: 'T2', isLab: false, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 2, sl: 3, code: 'CSE 1112', title: 'Structured Programming Language Laboratory', credit: 1.0, prerequisite: 'CSE 1110', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 2, sl: 4, code: 'CSE 2213', title: 'Discrete Mathematics', credit: 3.0, prerequisite: 'X', examDay: 'Day 3', examSlot: 'T2', isLab: false, domain: 'Mathematics'),

    // Trimester 3
    UIUCurriculumCourse(trimester: 3, sl: 1, code: 'MATH 2183', title: 'Calculus and Linear Algebra', credit: 3.0, prerequisite: 'MATH 1151', examDay: 'Day 1', examSlot: 'T3', isLab: false, domain: 'Mathematics'),
    UIUCurriculumCourse(trimester: 3, sl: 2, code: 'PHY 2105', title: 'Physics', credit: 3.0, prerequisite: 'X', examDay: 'Day 7', examSlot: 'T3', isLab: false, domain: 'Sciences'),
    UIUCurriculumCourse(trimester: 3, sl: 3, code: 'PHY 2106', title: 'Physics Lab', credit: 1.0, prerequisite: 'X', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Sciences'),
    UIUCurriculumCourse(trimester: 3, sl: 4, code: 'CSE 2215', title: 'Data Structure and Algorithms I', credit: 3.0, prerequisite: 'CSE 1111', examDay: 'Day 4', examSlot: 'T2', isLab: false, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 3, sl: 5, code: 'CSE 2216', title: 'Data Structure and Algorithms I Laboratory', credit: 1.0, prerequisite: 'CSE 1112', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Programming & CS'),

    // Trimester 4
    UIUCurriculumCourse(trimester: 4, sl: 1, code: 'MATH 2201', title: 'Coordinate Geometry and Vector Analysis', credit: 3.0, prerequisite: 'MATH 1151', examDay: 'Day 5', examSlot: 'T1', isLab: false, domain: 'Mathematics'),
    UIUCurriculumCourse(trimester: 4, sl: 2, code: 'CSE 1325', title: 'Digital Logic Design', credit: 3.0, prerequisite: 'X', examDay: 'Day 3', examSlot: 'T3', isLab: false, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 4, sl: 3, code: 'CSE 1326', title: 'Digital Logic Design Lab', credit: 1.0, prerequisite: 'X', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 4, sl: 4, code: 'CSE 1115', title: 'Object Oriented Programming', credit: 3.0, prerequisite: 'CSE 2215', examDay: 'Day 6', examSlot: 'T2', isLab: false, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 4, sl: 5, code: 'CSE 1116', title: 'Object Oriented Programming Lab', credit: 1.0, prerequisite: 'CSE 2216', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Programming & CS'),

    // Trimester 5
    UIUCurriculumCourse(trimester: 5, sl: 1, code: 'MATH 2205', title: 'Probability and Statistics', credit: 3.0, prerequisite: 'MATH 1151', examDay: 'Day 2', examSlot: 'T3', isLab: false, domain: 'Mathematics'),
    UIUCurriculumCourse(trimester: 5, sl: 2, code: 'SOC 2101', title: 'Society, Technology and Engineering Ethics', credit: 3.0, prerequisite: 'X', examDay: 'Day 1', examSlot: 'T3', isLab: false, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 5, sl: 3, code: 'CSE 2217', title: 'Data Structure and Algorithms II', credit: 3.0, prerequisite: 'CSE 2215', examDay: 'Day 5', examSlot: 'T2', isLab: false, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 5, sl: 4, code: 'CSE 2218', title: 'Data Structure and Algorithms II Laboratory', credit: 1.0, prerequisite: 'CSE 2216', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 5, sl: 5, code: 'EEE 2113', title: 'Electrical Circuits', credit: 3.0, prerequisite: 'X', examDay: 'Day 6', examSlot: 'T3', isLab: false, domain: 'Hardware & Architecture'),

    // Trimester 6
    UIUCurriculumCourse(trimester: 6, sl: 1, code: 'CSE 3521', title: 'Database Management Systems', credit: 3.0, prerequisite: 'CSE 2215', examDay: 'Day 2', examSlot: 'T1', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 6, sl: 2, code: 'CSE 3522', title: 'Database Management Systems Lab', credit: 1.0, prerequisite: 'CSE 2216', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 6, sl: 3, code: 'EEE 2123', title: 'Electronics', credit: 3.0, prerequisite: 'EEE 2113', examDay: 'Day 6', examSlot: 'T3', isLab: false, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 6, sl: 4, code: 'EEE 2124', title: 'Electronics Lab', credit: 1.0, prerequisite: 'X', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 6, sl: 5, code: 'CSE 4165', title: 'Web Programming', credit: 3.0, prerequisite: 'CSE 1115', examDay: 'Day 7', examSlot: 'T1', isLab: false, domain: 'Programming & CS'),

    // Trimester 7
    UIUCurriculumCourse(trimester: 7, sl: 1, code: 'CSE 3313', title: 'Computer Architecture', credit: 3.0, prerequisite: 'CSE 1325', examDay: 'Day 1', examSlot: 'T3', isLab: false, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 7, sl: 2, code: 'CSE 2118', title: 'Advanced Object Oriented Programming Lab', credit: 1.0, prerequisite: 'CSE 1116', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 7, sl: 3, code: 'BIO 3105', title: 'Biology for Engineers', credit: 3.0, prerequisite: 'X', examDay: 'Day 3', examSlot: 'T3', isLab: false, domain: 'Sciences'),
    UIUCurriculumCourse(trimester: 7, sl: 4, code: 'CSE 3411', title: 'System Analysis and Design', credit: 3.0, prerequisite: 'CSE 3521', examDay: 'Day 5', examSlot: 'T1', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 7, sl: 5, code: 'CSE 3412', title: 'System Analysis and Design Lab', credit: 1.0, prerequisite: 'CSE 3522', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Software & Systems'),

    // Trimester 8
    UIUCurriculumCourse(trimester: 8, sl: 1, code: 'CSE 3421', title: 'Software Engineering', credit: 3.0, prerequisite: 'CSE 3411', examDay: 'Day 4', examSlot: 'T3', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 8, sl: 2, code: 'CSE 3422', title: 'Software Engineering Lab', credit: 1.0, prerequisite: 'CSE 3412', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 8, sl: 3, code: 'CSE 4325', title: 'Microprocessors and Microcontrollers', credit: 3.0, prerequisite: 'CSE 3313', examDay: 'Day 6', examSlot: 'T2', isLab: false, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 8, sl: 4, code: 'CSE 4326', title: 'Microprocessors and Microcontrollers Lab', credit: 1.0, prerequisite: 'CSE 1326', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 8, sl: 5, code: 'CSE 3811', title: 'Artificial Intelligence', credit: 3.0, prerequisite: 'CSE 2217', examDay: 'Day 2', examSlot: 'T3', isLab: false, domain: 'Artificial Intelligence'),

    // Trimester 9
    UIUCurriculumCourse(trimester: 9, sl: 1, code: 'CSE 3812', title: 'Artificial Intelligence Lab', credit: 1.0, prerequisite: 'CSE 2218', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Artificial Intelligence'),
    UIUCurriculumCourse(trimester: 9, sl: 2, code: 'CSE 4531', title: 'Computer Networks', credit: 3.0, prerequisite: 'CSE 2217', examDay: 'Day 3', examSlot: 'T2', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 9, sl: 3, code: 'CSE 4532', title: 'Computer Networks Lab', credit: 1.0, prerequisite: 'CSE 2218', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 9, sl: 4, code: 'CSE 4111', title: 'Compiler Design', credit: 3.0, prerequisite: 'CSE 2217', examDay: 'Day 7', examSlot: 'T2', isLab: false, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 9, sl: 5, code: 'CSE 4112', title: 'Compiler Design Lab', credit: 1.0, prerequisite: 'CSE 2218', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Programming & CS'),

    // Trimester 10
    UIUCurriculumCourse(trimester: 10, sl: 1, code: 'CSE 4329', title: 'Operating Systems', credit: 3.0, prerequisite: 'CSE 3313', examDay: 'Day 2', examSlot: 'T2', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 2, code: 'CSE 4330', title: 'Operating Systems Lab', credit: 1.0, prerequisite: 'CSE 1326', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 3, code: 'CSE 4000A', title: 'Final Year Design Project - I', credit: 2.0, prerequisite: 'CREDITS_85', examDay: 'N/A', examSlot: 'N/A', isLab: false, domain: 'Project & Thesis'),
    UIUCurriculumCourse(trimester: 10, sl: 4, code: 'CSE 4611', title: 'Machine Learning', credit: 3.0, prerequisite: 'CSE 3811', examDay: 'Day 5', examSlot: 'T3', isLab: false, domain: 'Artificial Intelligence'),

    // Trimester 11
    UIUCurriculumCourse(trimester: 11, sl: 1, code: 'CSE 4000B', title: 'Final Year Design Project - II', credit: 2.0, prerequisite: 'CSE 4000A', examDay: 'N/A', examSlot: 'N/A', isLab: false, domain: 'Project & Thesis'),
    UIUCurriculumCourse(trimester: 11, sl: 2, code: 'CSE 4889', title: 'Computer Graphics', credit: 3.0, prerequisite: 'MATH 2183', examDay: 'Day 4', examSlot: 'T1', isLab: false, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 11, sl: 3, code: 'CSE 4890', title: 'Computer Graphics Lab', credit: 1.0, prerequisite: 'MATH 2183', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 11, sl: 4, code: 'ECO 2101', title: 'Economics', credit: 2.0, prerequisite: 'X', examDay: 'Day 1', examSlot: 'T2', isLab: false, domain: 'General Education'),

    // Trimester 12
    UIUCurriculumCourse(trimester: 12, sl: 1, code: 'CSE 4000C', title: 'Final Year Design Project - III', credit: 2.0, prerequisite: 'CSE 4000B', examDay: 'N/A', examSlot: 'N/A', isLab: false, domain: 'Project & Thesis'),
    UIUCurriculumCourse(trimester: 12, sl: 2, code: 'CSE 4547', title: 'Cyber Security', credit: 3.0, prerequisite: 'CSE 4531', examDay: 'Day 6', examSlot: 'T1', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 12, sl: 3, code: 'ACT 2111', title: 'Financial and Managerial Accounting', credit: 2.0, prerequisite: 'X', examDay: 'Day 3', examSlot: 'T1', isLab: false, domain: 'General Education'),
  ];

  /// Generates a personalized AI advisor report based on official UIU course sequences
  static AIAdvisorReport generateReport({
    required UserProfile profile,
    required List<SemesterTranscript> semesters,
  }) {
    // 1. Gather all completed course codes & their best grade point
    final completedCourseMap = <String, double>{};
    final ongoingCourseCodes = <String>{};
    double ongoingCredits = 0.0;
    final gradesByDomain = <String, List<double>>{
      'Programming & CS': [],
      'Mathematics': [],
      'Hardware & Architecture': [],
      'Software & Systems': [],
      'General Education': [],
      'Sciences': [],
      'Artificial Intelligence': [],
    };

    double realEarnedCredits = 0.0;
    double realPoints = 0.0;
    double realGpaCredits = 0.0;

    for (final sem in semesters) {
      for (final course in sem.courses) {
        if (course.credit <= 0) continue;
        final key = _normalizeCode(course.code);

        // Track ongoing / in-progress courses
        if (course.isOngoing || sem.isOngoing) {
          ongoingCourseCodes.add(key);
          ongoingCredits += course.credit;
          continue; // Ongoing courses must not be recorded as failed or finished with 0 GP!
        }

        final grade = (course.grade ?? '').trim().toUpperCase();
        if (grade == 'W' || grade.isEmpty) continue; // Withdraw excluded

        final gp = course.gradePoint ?? 0.0;

        if (!completedCourseMap.containsKey(key) || gp > completedCourseMap[key]!) {
          completedCourseMap[key] = gp;
        }

        // Domain tracking
        final domain = _findCourseDomain(key);
        gradesByDomain.putIfAbsent(domain, () => []).add(gp);
      }
    }

    // Recompute transcript stats
    for (final entry in completedCourseMap.entries) {
      final key = entry.key;
      final gp = entry.value;
      // find course credit in curriculum or default 3.0
      double cr = 3.0;
      for (final c in uiuCurriculum) {
        if (_normalizeCode(c.code) == key) {
          cr = c.credit;
          break;
        }
      }
      realPoints += gp * cr;
      realGpaCredits += cr;
      if (gp > 0.0) {
        realEarnedCredits += cr;
      }
    }

    final double realCGPA = realGpaCredits > 0
        ? (realPoints / realGpaCredits)
        : (profile.currentCGPA > 0 ? profile.currentCGPA : 0.0);

    final double realCompletedCredits = realEarnedCredits > 0
        ? realEarnedCredits
        : (profile.completedCredits > 0 ? profile.completedCredits : 0.0);

    final double targetCGPA = profile.targetCGPA > 0 ? profile.targetCGPA : 3.75;
    final double totalCredits = profile.totalDegreeCredits > 0 ? profile.totalDegreeCredits : 138.0;
    final double remainingCredits = (totalCredits - realCompletedCredits).clamp(0.0, totalCredits);

    // Dynamic pace required
    double projectedPace = 3.75;
    if (remainingCredits > 0 && totalCredits > 0 && realCGPA > 0) {
      final totalTargetPoints = targetCGPA * totalCredits;
      final currentPoints = realCGPA * realCompletedCredits;
      projectedPace = ((totalTargetPoints - currentPoints) / remainingCredits).clamp(2.0, 4.0);
    }

    // 2. Identify potential retakes (courses taken with gp < 2.50 or F, excluding ongoing courses)
    final retakeRecommendations = <CourseRecommendation>[];
    int rank = 1;

    completedCourseMap.forEach((code, gp) {
      // Exclude courses that student is currently taking in ongoing trimester
      if (ongoingCourseCodes.contains(code)) return;

      if (gp < 2.50) {
        // find details
        UIUCurriculumCourse? match;
        for (final c in uiuCurriculum) {
          if (_normalizeCode(c.code) == code) {
            match = c;
            break;
          }
        }
        if (match != null) {
          retakeRecommendations.add(CourseRecommendation(
            course: Course(
              code: match.code,
              title: match.title,
              credit: match.credit,
              grade: 'A',
              gradePoint: 4.0,
            ),
            priorityRank: rank++,
            reason: gp == 0.0
                ? 'Mandatory Retake: Failed course (${match.code}) blocking prerequisite chain and depressing CGPA.'
                : 'High-Impact Retake: Grade is below 2.50 (${gp.toStringAsFixed(2)}). Retaking replaces this grade directly in your CGPA calculation.',
            unlockRationale: 'Retake Policy: Eligible for immediate retake registration with 50% waiver if 1st retake.',
          ));
        }
      }
    });

    // 3. Find eligible next curriculum courses based on completed prerequisites
    final eligibleCourses = <UIUCurriculumCourse>[];

    for (final c in uiuCurriculum) {
      final codeNorm = _normalizeCode(c.code);

      // EXCLUDE courses already enrolled in ongoing trimester!
      if (ongoingCourseCodes.contains(codeNorm)) {
        continue;
      }

      // Skip if already passed with gp >= 2.50
      if (completedCourseMap.containsKey(codeNorm) && completedCourseMap[codeNorm]! >= 2.50) {
        continue;
      }
      // Check prerequisites
      bool prereqMet = false;
      if (c.prerequisite == 'X') {
        prereqMet = true;
      } else if (c.prerequisite == 'CREDITS_85') {
        prereqMet = (realCompletedCredits + ongoingCredits) >= 85.0;
      } else {
        final reqs = c.prerequisite.split(',').map((s) => _normalizeCode(s.trim())).toList();
        prereqMet = reqs.every((r) =>
            (completedCourseMap.containsKey(r) && completedCourseMap[r]! > 0.0) ||
            ongoingCourseCodes.contains(r));
      }

      if (prereqMet) {
        eligibleCourses.add(c);
      }
    }

    // Sort eligible courses: lowest trimester first, labs paired with theory
    eligibleCourses.sort((a, b) => a.trimester.compareTo(b.trimester));

    // 4. Select balanced set of courses adhering to UIU Credit Capacity policy
    // (3.00-4.00: 16 Cr, 2.50-3.00: 14 Cr, 2.00-2.49: 12 Cr, <2.00: 10 Cr)
    final double maxCreditCap = realCGPA >= 3.00
        ? 16.0
        : (realCGPA >= 2.50 ? 14.0 : (realCGPA >= 2.00 ? 12.0 : 10.0));

    final recommended = <CourseRecommendation>[...retakeRecommendations];
    double currentAccumulatedCredits = recommended.fold(0.0, (sum, r) => sum + r.course.credit);
    double theoryCredits = recommended.where((r) => !r.course.isLab).fold(0.0, (sum, r) => sum + r.course.credit);
    double labCredits = recommended.where((r) => r.course.isLab).fold(0.0, (sum, r) => sum + r.course.credit);

    final conflicts = <CourseConflictWarning>[];
    final selectedSlots = <String, String>{}; // "Day 1" -> "T1"

    for (final c in eligibleCourses) {
      if (currentAccumulatedCredits + c.credit > maxCreditCap) continue;
      if (currentAccumulatedCredits >= (maxCreditCap - 2.0) && currentAccumulatedCredits >= 11.0) break;
      if (c.isLab && labCredits >= 2.0) continue;
      if (recommended.any((r) => _normalizeCode(r.course.code) == _normalizeCode(c.code))) continue;

      // Check exam clash
      if (c.examDay != 'N/A' && selectedSlots.containsKey(c.examDay) && selectedSlots[c.examDay] == c.examSlot) {
        conflicts.add(CourseConflictWarning(
          title: 'Exam Schedule Clash Detected',
          conflictingCourses: [c.code, 'Existing enrolled course on ${c.examDay}'],
          severity: 'Critical',
          explanation: 'Both courses have examinations scheduled on ${c.examDay} in Time Slot ${c.examSlot}. Taking them together causes an immediate exam conflict.',
          recommendation: 'Register for an alternative elective or take one course in the subsequent trimester.',
        ));
        continue;
      }

      if (c.examDay != 'N/A') {
        selectedSlots[c.examDay] = c.examSlot;
      }

      recommended.add(CourseRecommendation(
        course: Course(
          code: c.code,
          title: c.title,
          credit: c.credit,
          grade: 'A',
          gradePoint: 4.0,
        ),
        priorityRank: rank++,
        reason: c.isLab
            ? 'Hands-on practical laboratory course. Reinforces core engineering concepts with minimal exam-cramming load.'
            : 'Core degree milestone for Trimester ${c.trimester}. Fulfills prerequisites for advanced upper-level courses.',
        unlockRationale: 'Prerequisites verified and satisfied under UIU curriculum guidelines.',
      ));

      currentAccumulatedCredits += c.credit;
      if (c.isLab) {
        labCredits += c.credit;
      } else {
        theoryCredits += c.credit;
      }
    }

    // If still empty (e.g. fresh 1st trimester student), give next curriculum defaults (excluding ongoing courses)
    if (recommended.isEmpty) {
      final eligibleFallbacks = uiuCurriculum
          .where((c) => !ongoingCourseCodes.contains(_normalizeCode(c.code)) && !completedCourseMap.containsKey(_normalizeCode(c.code)))
          .toList();
      eligibleFallbacks.sort((a, b) => a.trimester.compareTo(b.trimester));

      for (final c in eligibleFallbacks) {
        if (currentAccumulatedCredits + c.credit > maxCreditCap) continue;
        if (currentAccumulatedCredits >= (maxCreditCap - 2.0) && currentAccumulatedCredits >= 11.0) break;
        if (c.isLab && labCredits >= 2.0) continue;

        recommended.add(CourseRecommendation(
          course: Course(
            code: c.code,
            title: c.title,
            credit: c.credit,
            grade: 'A',
            gradePoint: 4.0,
          ),
          priorityRank: rank++,
          reason: 'UIU Foundation Curriculum Course. Essential stepping stone for your academic career.',
          unlockRationale: 'Curriculum pathway progression course.',
        ));
        currentAccumulatedCredits += c.credit;
        if (c.isLab) {
          labCredits += c.credit;
        } else {
          theoryCredits += c.credit;
        }
      }
    }

    // Additional common UIU workload warning if theory courses >= 4 or labs >= 3
    if (theoryCredits >= 12.0) {
      conflicts.add(const CourseConflictWarning(
        title: 'Heavy Theoretical Workload Notice',
        conflictingCourses: ['4+ Theory Courses Registered'],
        severity: 'Moderate',
        explanation: 'Enrolling in 4 heavy theory courses simultaneously results in 16+ hours of weekly study load and overlapping continuous assessment deadlines.',
        recommendation: 'Balance theory coursework with at least 1 lab or 1 General Education (GED) course to safeguard trimester SGPA.',
      ));
    }

    if (labCredits >= 3.0) {
      conflicts.add(const CourseConflictWarning(
        title: 'Excessive Laboratory Load Warning',
        conflictingCourses: ['3+ Lab Courses Registered'],
        severity: 'Moderate',
        explanation: 'Taking 3 or more lab courses in one trimester causes excessive weekly lab report submissions and conflicting project deadlines.',
        recommendation: 'Limit to at most 2 labs per trimester to preserve adequate study hours for major theory courses.',
      ));
    }

    // 5. Build Domain Analyses
    final domainAnalyses = <SubjectDomainAnalysis>[];
    gradesByDomain.forEach((domain, grades) {
      // Exclude domains where student hasn't completed any courses yet (no demo data)
      if (grades.isEmpty) return;

      final avgGp = grades.reduce((a, b) => a + b) / grades.length;
      final scorePct = ((avgGp / 4.0) * 100).clamp(0.0, 100.0);
      final isStrength = avgGp >= 3.65;
      final status = avgGp >= 3.75 ? 'Strong Proficiency' : avgGp >= 3.30 ? 'Good Standing' : 'Focus Needed';

      String insight = '';
      switch (domain) {
        case 'Programming & CS':
          insight = avgGp >= 3.65
              ? 'Demonstrating solid programming and algorithmic reasoning (Avg GP: ${avgGp.toStringAsFixed(2)}). Excellent candidate for competitive programming and advanced elective tracks.'
              : 'Keep practicing LeetCode/Codeforces and structured problem solving (Avg GP: ${avgGp.toStringAsFixed(2)}) to bolster your data structures foundation.';
          break;
        case 'Mathematics':
          insight = avgGp >= 3.65
              ? 'Strong mathematical and analytical aptitude (Avg GP: ${avgGp.toStringAsFixed(2)}). Provides an advantage in Machine Learning, Cryptography, and Signal Processing.'
              : 'Review calculus and linear algebra fundamentals (Avg GP: ${avgGp.toStringAsFixed(2)}) to maintain high performance in Probability & Statistics.';
          break;
        case 'Hardware & Architecture':
          insight = avgGp >= 3.65
              ? 'Well-rounded hardware logic understanding (Avg GP: ${avgGp.toStringAsFixed(2)}). Well positioned for Microprocessors and Embedded Systems.'
              : 'Dedicate extra simulation hours in Logisim and circuit design labs (Avg GP: ${avgGp.toStringAsFixed(2)}).';
          break;
        case 'Software & Systems':
          insight = avgGp >= 3.65
              ? 'High software architecture and system design capability (Avg GP: ${avgGp.toStringAsFixed(2)}). Ready for full-stack, enterprise DB, and OS labs.'
              : 'Engage actively in lab term-projects (Avg GP: ${avgGp.toStringAsFixed(2)}) to gain practical system implementation experience.';
          break;
        default:
          insight = 'Maintains balanced academic performance (Avg GP: ${avgGp.toStringAsFixed(2)}) across enrolled coursework.';
      }

      domainAnalyses.add(SubjectDomainAnalysis(
        domain: domain,
        scorePercent: scorePct,
        status: status,
        insight: insight,
        isStrength: isStrength,
      ));
    });

    final summary = realCompletedCredits == 0
        ? 'Welcome to UIU! As a 1st trimester student, your focus should be on building a strong foundation in Structured Programming and Calculus. Attending all quizzes and securing 26+ out of 30 in midterms will lock in an immediate Dean\'s Honor pace.'
        : 'Based on your completed ${realCompletedCredits.toStringAsFixed(1)} credits and current CGPA of ${realCGPA.toStringAsFixed(2)}, you are maintaining a ${(realCGPA >= 3.75 ? 'Dean\'s Honor' : 'solid academic')} trajectory. To hit your target of ${targetCGPA.toStringAsFixed(2)}, maintain an average SGPA of ${projectedPace.toStringAsFixed(2)} across your remaining ${remainingCredits.toInt()} credits.';

    return AIAdvisorReport(
      overallSummary: summary,
      currentPaceCGPA: realCGPA,
      projectedFinalCGPA: targetCGPA,
      domainAnalyses: domainAnalyses,
      recommendedCourses: recommended,
      conflictWarnings: conflicts,
      gpaBoosterTips: [
        'Secure 26+ in Midterms (30% weight) to reduce final exam pressure.',
        'Never skip class attendance and continuous assessment quizzes.',
        'Retake any D/F grade to replace it completely in your cumulative CGPA.',
      ],
      suggestedCreditLoad: currentAccumulatedCredits,
    );
  }

  static String _normalizeCode(String code) {
    return code.replaceAll(RegExp(r'\s+'), ' ').trim().toUpperCase();
  }

  static String _findCourseDomain(String code) {
    for (final c in uiuCurriculum) {
      if (_normalizeCode(c.code) == code) {
        return c.domain;
      }
    }
    if (code.startsWith('MATH')) return 'Mathematics';
    if (code.startsWith('CSE')) return 'Programming & CS';
    if (code.startsWith('EEE')) return 'Hardware & Architecture';
    if (code.startsWith('ENG') || code.startsWith('BDS') || code.startsWith('SOC') || code.startsWith('GED')) return 'General Education';
    return 'Programming & CS';
  }
}
