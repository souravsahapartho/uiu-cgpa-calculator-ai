import '../models/course.dart';
import '../models/semester_transcript.dart';
import '../models/ai_recommendation.dart';
import '../models/student_profile.dart';

class UIUMockData {
  static const StudentProfile student = StudentProfile(
    name: 'Sourav Ahmed',
    studentId: '011 201 042',
    department: 'Department of Computer Science and Engineering',
    program: 'B.Sc. in Computer Science & Engineering',
    batch: '201',
    currentCGPA: 3.78,
    completedCredits: 76.0,
    totalDegreeCredits: 138.0,
    targetCGPA: 3.85,
    advisorName: 'Dr. Mohammad Nurul Huda',
    advisorEmail: 'mnhuda@cse.uiu.ac.bd',
    currentTrimester: 'Spring 2024',
    lastBackupTime: 'Just now (Synced to Local Disk)',
  );

  static final List<SemesterTranscript> transcriptSemesters = [
    SemesterTranscript(
      semesterName: 'Fall 2021',
      semesterIndex: 1,
      sgpa: 3.83,
      cgpa: 3.83,
      creditsEarned: 10.0,
      totalCompletedCredits: 10.0,
      courses: const [
        Course(code: 'CSE 1111', title: 'Structured Programming Language', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core, difficulty: CourseDifficulty.medium),
        Course(code: 'CSE 1112', title: 'Structured Programming Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.easy),
        Course(code: 'ENG 1011', title: 'Developing English Language Skills I', credit: 3.0, grade: 'A-', gradePoint: 3.67, category: CourseCategory.ged, difficulty: CourseDifficulty.easy),
        Course(code: 'MATH 1151', title: 'Differential and Integral Calculus', credit: 3.0, grade: 'A-', gradePoint: 3.67, category: CourseCategory.math, difficulty: CourseDifficulty.hard),
      ],
    ),
    SemesterTranscript(
      semesterName: 'Spring 2022',
      semesterIndex: 2,
      sgpa: 3.71,
      cgpa: 3.77,
      creditsEarned: 10.0,
      totalCompletedCredits: 20.0,
      courses: const [
        Course(code: 'CSE 1205', title: 'Object Oriented Programming', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core, difficulty: CourseDifficulty.medium),
        Course(code: 'CSE 1206', title: 'Object Oriented Programming Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.easy),
        Course(code: 'MATH 2183', title: 'Linear Algebra & Complex Variables', credit: 3.0, grade: 'B+', gradePoint: 3.33, category: CourseCategory.math, difficulty: CourseDifficulty.hard),
        Course(code: 'PHY 2105', title: 'Physics (Electricity & Magnetism)', credit: 3.0, grade: 'A-', gradePoint: 3.67, category: CourseCategory.physics, difficulty: CourseDifficulty.medium),
      ],
    ),
    SemesterTranscript(
      semesterName: 'Summer 2022',
      semesterIndex: 3,
      sgpa: 3.92,
      cgpa: 3.82,
      creditsEarned: 10.0,
      totalCompletedCredits: 30.0,
      courses: const [
        Course(code: 'CSE 2215', title: 'Data Structures', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core, difficulty: CourseDifficulty.hard),
        Course(code: 'CSE 2216', title: 'Data Structures Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.medium),
        Course(code: 'CSE 2213', title: 'Discrete Mathematics', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core, difficulty: CourseDifficulty.hard),
        Course(code: 'SOC 2101', title: 'Society, Environment & Engineering Ethics', credit: 3.0, grade: 'A-', gradePoint: 3.67, category: CourseCategory.ged, difficulty: CourseDifficulty.easy),
      ],
    ),
    SemesterTranscript(
      semesterName: 'Fall 2022',
      semesterIndex: 4,
      sgpa: 3.75,
      cgpa: 3.80,
      creditsEarned: 11.0,
      totalCompletedCredits: 41.0,
      courses: const [
        Course(code: 'CSE 2217', title: 'Algorithms Design & Analysis', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core, difficulty: CourseDifficulty.veryHard),
        Course(code: 'CSE 2218', title: 'Algorithms Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.hard),
        Course(code: 'CSE 2233', title: 'Digital Logic Design', credit: 3.0, grade: 'B+', gradePoint: 3.33, category: CourseCategory.core, difficulty: CourseDifficulty.medium),
        Course(code: 'CSE 2234', title: 'Digital Logic Design Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.easy),
        Course(code: 'MATH 2201', title: 'Coordinate Geometry & Vector Analysis', credit: 3.0, grade: 'A-', gradePoint: 3.67, category: CourseCategory.math, difficulty: CourseDifficulty.medium),
      ],
    ),
    SemesterTranscript(
      semesterName: 'Spring 2023',
      semesterIndex: 5,
      sgpa: 3.73,
      cgpa: 3.79,
      creditsEarned: 11.0,
      totalCompletedCredits: 52.0,
      courses: const [
        Course(code: 'CSE 3411', title: 'Database Management Systems', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core, difficulty: CourseDifficulty.medium),
        Course(code: 'CSE 3412', title: 'Database Management Systems Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.medium),
        Course(code: 'CSE 3521', title: 'Operating Systems', credit: 3.0, grade: 'B+', gradePoint: 3.33, category: CourseCategory.core, difficulty: CourseDifficulty.hard),
        Course(code: 'CSE 3522', title: 'Operating Systems Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.medium),
        Course(code: 'STAT 2111', title: 'Basic Graph Theory & Statistics', credit: 3.0, grade: 'A-', gradePoint: 3.67, category: CourseCategory.math, difficulty: CourseDifficulty.medium),
      ],
    ),
    SemesterTranscript(
      semesterName: 'Summer 2023',
      semesterIndex: 6,
      sgpa: 3.82,
      cgpa: 3.79,
      creditsEarned: 11.0,
      totalCompletedCredits: 63.0,
      courses: const [
        Course(code: 'CSE 3313', title: 'Computer Networks', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core, difficulty: CourseDifficulty.hard),
        Course(code: 'CSE 3314', title: 'Computer Networks Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.medium),
        Course(code: 'CSE 3711', title: 'Software Engineering', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core, difficulty: CourseDifficulty.medium),
        Course(code: 'CSE 3712', title: 'Software Engineering Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.medium),
        Course(code: 'ACT 2111', title: 'Financial & Managerial Accounting', credit: 3.0, grade: 'B+', gradePoint: 3.33, category: CourseCategory.ged, difficulty: CourseDifficulty.easy),
      ],
    ),
    SemesterTranscript(
      semesterName: 'Fall 2023',
      semesterIndex: 7,
      sgpa: 3.74,
      cgpa: 3.78,
      creditsEarned: 13.0,
      totalCompletedCredits: 76.0,
      courses: const [
        Course(code: 'CSE 4165', title: 'Web Technologies', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.elective, difficulty: CourseDifficulty.medium),
        Course(code: 'CSE 4166', title: 'Web Technologies Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.easy),
        Course(code: 'CSE 3811', title: 'Artificial Intelligence', credit: 3.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.core, difficulty: CourseDifficulty.hard),
        Course(code: 'CSE 3812', title: 'Artificial Intelligence Lab', credit: 1.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.lab, difficulty: CourseDifficulty.medium),
        Course(code: 'ECO 2101', title: 'Principles of Economics', credit: 3.0, grade: 'B', gradePoint: 3.00, category: CourseCategory.ged, difficulty: CourseDifficulty.easy),
        Course(code: 'CSE 3822', title: 'Competitive Programming Lab', credit: 2.0, grade: 'A', gradePoint: 4.00, category: CourseCategory.elective, difficulty: CourseDifficulty.hard),
      ],
    ),
  ];

  static const AIAdvisorReport aiReport = AIAdvisorReport(
    overallSummary: 'Outstanding standing in Core CS, Algorithms & Applied Systems. You are in the top 5% of UIU CSE batch 201. Your path to 3.85+ CGPA requires an average SGPA of 3.93 across your remaining 62 credits.',
    currentPaceCGPA: 3.78,
    projectedFinalCGPA: 3.86,
    suggestedCreditLoad: 11.0,
    domainAnalyses: [
      SubjectDomainAnalysis(
        domain: 'Data Structures & Algorithms',
        scorePercent: 96.0,
        status: 'Exceptional (A)',
        insight: 'Consistent 4.00 in SPL, OOP, DSA, and Algorithms. Prime candidate for Machine Learning & Thesis research.',
        isStrength: true,
      ),
      SubjectDomainAnalysis(
        domain: 'Software Engineering & Web',
        scorePercent: 94.0,
        status: 'Strong (A)',
        insight: 'Solid project execution in DBMS, SE, and Web Technologies.',
        isStrength: true,
      ),
      SubjectDomainAnalysis(
        domain: 'Mathematics & Statistics',
        scorePercent: 86.0,
        status: 'Very Good (A-/B+)',
        insight: 'Great performance in Calculus & Discrete Math; Linear Algebra was slightly lower (3.33).',
        isStrength: true,
      ),
      SubjectDomainAnalysis(
        domain: 'Hardware & Architecture',
        scorePercent: 82.0,
        status: 'Needs Focus (B+)',
        insight: 'Digital Logic Design had a minor dip. Ensure careful prep before taking Microprocessors.',
        isStrength: false,
      ),
      SubjectDomainAnalysis(
        domain: 'General Education (GED)',
        scorePercent: 78.0,
        status: 'Room for Optimization (B)',
        insight: 'Economics and Accounting pulled down overall semester weights. Aim for A grades in remaining GEDs.',
        isStrength: false,
      ),
    ],
    recommendedCourses: [
      CourseRecommendation(
        course: Course(
          code: 'CSE 4325',
          title: 'Microprocessors & Microcontrollers',
          credit: 3.0,
          category: CourseCategory.core,
          difficulty: CourseDifficulty.hard,
          prerequisite: 'CSE 2233 (DLD)',
        ),
        reason: 'Essential 4th-year core requirement. Recommended early to unlock embedded electives and senior design project.',
        unlockRationale: 'Prerequisite for CSE 4326 and Capstone Track B.',
        priorityRank: 1,
      ),
      CourseRecommendation(
        course: Course(
          code: 'CSE 4326',
          title: 'Microprocessors & Microcontrollers Lab',
          credit: 1.0,
          category: CourseCategory.lab,
          difficulty: CourseDifficulty.medium,
          prerequisite: 'CSE 2234',
        ),
        reason: 'Hands-on 8086 assembly & Arduino microcontroller interfacing.',
        unlockRationale: 'Co-requisite with CSE 4325.',
        priorityRank: 2,
      ),
      CourseRecommendation(
        course: Course(
          code: 'CSE 4889',
          title: 'Machine Learning',
          credit: 3.0,
          category: CourseCategory.elective,
          difficulty: CourseDifficulty.hard,
          prerequisite: 'CSE 3811 (AI) & STAT 2111',
        ),
        reason: 'Capitalizes on your high AI (4.00) & Math aptitude. Ideal for UIU Final Year Design Project (FYDP).',
        unlockRationale: 'Opens Research Publication Track.',
        priorityRank: 3,
      ),
      CourseRecommendation(
        course: Course(
          code: 'ENG 1013',
          title: 'Developing English Language Skills II',
          credit: 3.0,
          category: CourseCategory.ged,
          difficulty: CourseDifficulty.easy,
          prerequisite: 'ENG 1011',
        ),
        reason: 'Lightweight GED course that acts as a GPA stabilizer alongside heavy technical loads.',
        unlockRationale: 'Fulfills University Foundation Requirement.',
        priorityRank: 4,
      ),
    ],
    conflictWarnings: [
      CourseConflictWarning(
        title: 'Heavy Hardware Lab Conflict',
        conflictingCourses: ['CSE 4325 (Microprocessors)', 'CSE 4531 (Compiler Design)'],
        severity: 'High',
        explanation: 'Both courses require 15+ hours/week of rigorous low-level coding and weekly assembly/lexical lab submissions.',
        recommendation: 'Take Microprocessors this trimester and defer Compiler Design to next trimester.',
      ),
      CourseConflictWarning(
        title: 'Project Submission Overlap',
        conflictingCourses: ['CSE 4889 (ML)', 'CSE 4181 (Mobile App Dev)'],
        severity: 'Moderate',
        explanation: 'Both contain multi-phase group capstone deliverables during midterm and final examination weeks.',
        recommendation: 'Balance ML with a non-project GED elective like Engineering Ethics or Professional Ethics.',
      ),
    ],
    gpaBoosterTips: [
      'Retake Strategy: Your lowest grade is Economics (B - 3.00, 3 credits). Retaking it for an A would immediately boost your CGPA by +0.022.',
      'Lab Perfection: You currently hold a 4.00 GPA in all CSE labs. Keep prioritizing 1.0-credit labs as low-effort GPA anchors.',
      'Credit Balancing: Keep trimesters between 10.0 - 12.0 credits for optimal A-grade probability.',
      'Midterm Defense: UIU grading weights midterms heavily (30%). Secure 26+ marks before finals.',
    ],
  );

  static final List<Course> availableUpcomingCourses = [
    const Course(code: 'CSE 4325', title: 'Microprocessors & Microcontrollers', credit: 3.0, category: CourseCategory.core, difficulty: CourseDifficulty.hard, prerequisite: 'CSE 2233'),
    const Course(code: 'CSE 4326', title: 'Microprocessors Lab', credit: 1.0, category: CourseCategory.lab, difficulty: CourseDifficulty.medium, prerequisite: 'CSE 2234'),
    const Course(code: 'CSE 4531', title: 'Compiler Design', credit: 3.0, category: CourseCategory.core, difficulty: CourseDifficulty.veryHard, prerequisite: 'CSE 2215'),
    const Course(code: 'CSE 4532', title: 'Compiler Design Lab', credit: 1.0, category: CourseCategory.lab, difficulty: CourseDifficulty.hard, prerequisite: 'CSE 2216'),
    const Course(code: 'CSE 4889', title: 'Machine Learning', credit: 3.0, category: CourseCategory.elective, difficulty: CourseDifficulty.hard, prerequisite: 'CSE 3811'),
    const Course(code: 'CSE 4890', title: 'Machine Learning Lab', credit: 1.0, category: CourseCategory.lab, difficulty: CourseDifficulty.medium, prerequisite: 'CSE 3812'),
    const Course(code: 'CSE 4181', title: 'Mobile Application Development', credit: 3.0, category: CourseCategory.elective, difficulty: CourseDifficulty.medium, prerequisite: 'CSE 1205'),
    const Course(code: 'CSE 4182', title: 'Mobile App Dev Lab', credit: 1.0, category: CourseCategory.lab, difficulty: CourseDifficulty.easy, prerequisite: 'CSE 1206'),
    const Course(code: 'CSE 4900A', title: 'Senior Design Project I (FYDP I)', credit: 2.0, category: CourseCategory.core, difficulty: CourseDifficulty.hard, prerequisite: '100+ Credits completed'),
    const Course(code: 'ENG 1013', title: 'English Language Skills II', credit: 3.0, category: CourseCategory.ged, difficulty: CourseDifficulty.easy, prerequisite: 'ENG 1011'),
    const Course(code: 'ECO 3101', title: 'Engineering Economics', credit: 3.0, category: CourseCategory.ged, difficulty: CourseDifficulty.easy, prerequisite: 'ECO 2101'),
  ];
}

