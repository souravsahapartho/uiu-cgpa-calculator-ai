import '../../models/ai_recommendation.dart';
import '../../models/course.dart';
import '../../models/semester_transcript.dart';
import '../providers/user_profile_provider.dart';

/// Official UIU Course Offering Curriculum Definition
class UIUCurriculumCourse {
  final int trimester; // 1 to 12
  final int sl;
  final String code;
  final String title;
  final double credit;
  final String prerequisite;
  final String examDay;
  final String examSlot;
  final bool isLab;
  final bool isProject;
  final bool isGedOptional;
  final bool isElective;
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
    this.isProject = false,
    this.isGedOptional = false,
    this.isElective = false,
    required this.domain,
  });
}

class AcademicAdvisorEngine {
  /// Complete UIU CSE Curriculum & Course Sequence with Exam Schedules (Fall 2026 Dept. of CSE)
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
    UIUCurriculumCourse(trimester: 6, sl: 2, code: 'CSE 3522', title: 'Database Management Systems Lab', credit: 1.0, prerequisite: 'CSE 2216', examDay: 'N/A', examSlot: 'N/A', isLab: true, isProject: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 6, sl: 3, code: 'EEE 2123', title: 'Electronics', credit: 3.0, prerequisite: 'EEE 2113', examDay: 'Day 6', examSlot: 'T3', isLab: false, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 6, sl: 4, code: 'EEE 2124', title: 'Electronics Lab', credit: 1.0, prerequisite: 'X', examDay: 'N/A', examSlot: 'N/A', isLab: true, isProject: true, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 6, sl: 5, code: 'CSE 4165', title: 'Web Programming', credit: 3.0, prerequisite: 'CSE 1115, CSE 1116', examDay: 'Day 7', examSlot: 'T1', isLab: false, domain: 'Programming & CS'),

    // Trimester 7
    UIUCurriculumCourse(trimester: 7, sl: 1, code: 'CSE 3313', title: 'Computer Architecture', credit: 3.0, prerequisite: 'CSE 1325', examDay: 'Day 1', examSlot: 'T3', isLab: false, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 7, sl: 2, code: 'CSE 2118', title: 'Advanced Object Oriented Programming Lab', credit: 1.0, prerequisite: 'CSE 1116', examDay: 'N/A', examSlot: 'N/A', isLab: true, isProject: true, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 7, sl: 3, code: 'BIO 3105', title: 'Biology for Engineers', credit: 3.0, prerequisite: 'X', examDay: 'Day 3', examSlot: 'T3', isLab: false, domain: 'Sciences'),
    UIUCurriculumCourse(trimester: 7, sl: 4, code: 'CSE 3411', title: 'System Analysis and Design', credit: 3.0, prerequisite: 'CSE 3521', examDay: 'Day 5', examSlot: 'T1', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 7, sl: 5, code: 'CSE 3412', title: 'System Analysis and Design Lab', credit: 1.0, prerequisite: 'CSE 3522', examDay: 'N/A', examSlot: 'N/A', isLab: true, isProject: true, domain: 'Software & Systems'),

    // Trimester 8
    UIUCurriculumCourse(trimester: 8, sl: 1, code: 'CSE 4325', title: 'Microprocessors and Microcontrollers', credit: 3.0, prerequisite: 'CSE 3313', examDay: 'Day 2', examSlot: 'T2', isLab: false, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 8, sl: 2, code: 'CSE 4326', title: 'Microprocessors and Microcontrollers Lab', credit: 1.0, prerequisite: 'EEE 2124', examDay: 'N/A', examSlot: 'N/A', isLab: true, isProject: true, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 8, sl: 3, code: 'CSE 3421', title: 'Software Engineering', credit: 3.0, prerequisite: 'CSE 3411', examDay: 'Day 5', examSlot: 'T3', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 8, sl: 4, code: 'CSE 3422', title: 'Software Engineering Lab', credit: 1.0, prerequisite: 'CSE 3412', examDay: 'N/A', examSlot: 'N/A', isLab: true, isProject: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 8, sl: 5, code: 'CSE 3811', title: 'Artificial Intelligence', credit: 3.0, prerequisite: 'MATH 2205, CSE 2217', examDay: 'Day 3', examSlot: 'T1', isLab: false, domain: 'Artificial Intelligence'),
    UIUCurriculumCourse(trimester: 8, sl: 6, code: 'CSE 3812', title: 'Artificial Intelligence Lab', credit: 1.0, prerequisite: 'MATH 2205, CSE 2218', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Artificial Intelligence'),

    // Trimester 9
    UIUCurriculumCourse(trimester: 9, sl: 1, code: 'CSE 2233', title: 'Theory of Computation', credit: 3.0, prerequisite: 'X', examDay: 'Day 7', examSlot: 'T2', isLab: false, domain: 'Programming & CS'),
    UIUCurriculumCourse(trimester: 9, sl: 2, code: 'GED 1005', title: 'AI Literacy and Prompt Engineering', credit: 3.0, prerequisite: 'X', examDay: 'Day 1', examSlot: 'T1', isLab: false, isGedOptional: true, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 9, sl: 3, code: 'PMG 4101', title: 'Project Management', credit: 3.0, prerequisite: 'CSE 3411', examDay: 'Day 3', examSlot: 'T2', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 9, sl: 4, code: 'CSE 3711', title: 'Computer Networks', credit: 3.0, prerequisite: 'CSE 2217', examDay: 'Day 4', examSlot: 'T3', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 9, sl: 5, code: 'CSE 3712', title: 'Computer Networks Lab', credit: 1.0, prerequisite: 'X', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Software & Systems'),

    // Trimester 10
    UIUCurriculumCourse(trimester: 10, sl: 1, code: 'ECO 4101', title: 'Economics', credit: 3.0, prerequisite: 'X', examDay: 'Day 6', examSlot: 'T1', isLab: false, isGedOptional: true, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 10, sl: 2, code: 'CSE 4000A', title: 'Final Year Design Project - I', credit: 2.0, prerequisite: 'CREDITS_85', examDay: 'N/A', examSlot: 'N/A', isLab: false, isProject: true, domain: 'Project & Thesis'),
    UIUCurriculumCourse(trimester: 10, sl: 3, code: 'CSE 4509', title: 'Operating Systems', credit: 3.0, prerequisite: 'CSE 2217, CSE 3313', examDay: 'Day 1', examSlot: 'T1', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 4, code: 'CSE 4510', title: 'Operating Systems Laboratory', credit: 1.0, prerequisite: 'CSE 2218', examDay: 'N/A', examSlot: 'N/A', isLab: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 5, code: 'CSE 4611', title: 'Compiler Design', credit: 3.0, prerequisite: 'CSE 2233', examDay: 'Day 4', examSlot: 'T1', isLab: false, domain: 'Programming & CS'),

    // Trimester 11
    UIUCurriculumCourse(trimester: 11, sl: 1, code: 'ACT 2111', title: 'Financial and Managerial Accounting', credit: 3.0, prerequisite: 'X', examDay: 'Day 2', examSlot: 'T3', isLab: false, isGedOptional: true, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 11, sl: 2, code: 'CSE 4000B', title: 'Final Year Design Project - II', credit: 2.0, prerequisite: 'CSE 4000A', examDay: 'N/A', examSlot: 'N/A', isLab: false, isProject: true, domain: 'Project & Thesis'),
    UIUCurriculumCourse(trimester: 11, sl: 3, code: 'CSE 4531', title: 'Computer Security', credit: 3.0, prerequisite: 'CSE 3711, CSE 4509', examDay: 'Day 6', examSlot: 'T3', isLab: false, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 11, sl: 4, code: 'CSE 4889', title: 'Machine Learning', credit: 3.0, prerequisite: 'CSE 3811, CSE 3812, MATH 2183', examDay: 'Day 1', examSlot: 'T3', isLab: false, domain: 'Artificial Intelligence'),
    UIUCurriculumCourse(trimester: 11, sl: 5, code: 'CSE 4621', title: 'Computer Graphics', credit: 3.0, prerequisite: 'MATH 2201, MATH 2183', examDay: 'Day 2', examSlot: 'T1', isLab: false, domain: 'Programming & CS'),

    // Trimester 12
    UIUCurriculumCourse(trimester: 12, sl: 1, code: 'CSE 4000C', title: 'Final Year Design Project - III', credit: 2.0, prerequisite: 'CSE 4000A, CSE 4000B', examDay: 'N/A', examSlot: 'N/A', isLab: false, isProject: true, domain: 'Project & Thesis'),
    UIUCurriculumCourse(trimester: 12, sl: 2, code: 'EEE 4261', title: 'Green Computing', credit: 3.0, prerequisite: 'X', examDay: 'Day 5', examSlot: 'T1', isLab: false, isElective: true, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 12, sl: 3, code: 'CSE 4587', title: 'Cloud Computing', credit: 3.0, prerequisite: 'CSE 4509, CSE 3711', examDay: 'Day 5', examSlot: 'T3', isLab: false, isElective: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 12, sl: 4, code: 'CSE 4451', title: 'Human Computer Interaction', credit: 3.0, prerequisite: 'CREDITS_70', examDay: 'Day 3', examSlot: 'T1', isLab: false, isElective: true, domain: 'Software & Systems'),

    // Specialized Electives & Additional GED Optionals
    UIUCurriculumCourse(trimester: 10, sl: 6, code: 'TEC 2499', title: 'Technology Entrepreneurship', credit: 3.0, prerequisite: 'X', examDay: 'Day 3', examSlot: 'T2', isLab: false, isGedOptional: true, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 10, sl: 7, code: 'CSE 4125', title: 'Ethical Hacking and Network Defense', credit: 3.0, prerequisite: 'CSE 4531', examDay: 'Day 1', examSlot: 'T3', isLab: false, isElective: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 8, code: 'CSE 4777', title: 'Network Security', credit: 3.0, prerequisite: 'CSE 4531', examDay: 'Day 3', examSlot: 'T3', isLab: false, isElective: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 9, code: 'CSE 4435', title: 'Software Architecture', credit: 3.0, prerequisite: 'X', examDay: 'Day 4', examSlot: 'T2', isLab: false, isElective: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 10, code: 'CSE 4181', title: 'Mobile Application Development', credit: 3.0, prerequisite: 'CSE 4165', examDay: 'Day 6', examSlot: 'T3', isLab: false, isElective: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 11, code: 'CSE 4945', title: 'UI: Concepts and Design', credit: 3.0, prerequisite: 'X', examDay: 'Day 1', examSlot: 'T2', isLab: false, isElective: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 12, code: 'CSE 4495', title: 'Software Testing and Quality Assurance', credit: 3.0, prerequisite: 'CSE 3421', examDay: 'Day 7', examSlot: 'T3', isLab: false, isElective: true, domain: 'Software & Systems'),
    UIUCurriculumCourse(trimester: 10, sl: 13, code: 'CSE 4327', title: 'VLSI Design', credit: 3.0, prerequisite: 'CSE 4325', examDay: 'Day 4', examSlot: 'T1', isLab: false, isElective: true, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 10, sl: 14, code: 'CSE 4399', title: 'Embedded Machine Learning', credit: 3.0, prerequisite: 'CSE 1111, CSE 4325', examDay: 'Day 7', examSlot: 'T2', isLab: false, isElective: true, domain: 'Hardware & Architecture'),
    UIUCurriculumCourse(trimester: 11, sl: 6, code: 'CSE 4891', title: 'Data Mining', credit: 3.0, prerequisite: 'CSE 4889', examDay: 'Day 7', examSlot: 'T1', isLab: false, isElective: true, domain: 'Artificial Intelligence'),
    UIUCurriculumCourse(trimester: 11, sl: 7, code: 'CSE 4817', title: 'Big Data Analytics', credit: 3.0, prerequisite: 'CSE 4889', examDay: 'Day 5', examSlot: 'T3', isLab: false, isElective: true, domain: 'Artificial Intelligence'),
    UIUCurriculumCourse(trimester: 11, sl: 8, code: 'CSE 4883', title: 'Digital Image Processing', credit: 3.0, prerequisite: 'CSE 4889', examDay: 'Day 4', examSlot: 'T1', isLab: false, isElective: true, domain: 'Artificial Intelligence'),
    UIUCurriculumCourse(trimester: 11, sl: 9, code: 'CSE 4811', title: 'Natural Language Processing', credit: 3.0, prerequisite: 'CSE 4889', examDay: 'Day 4', examSlot: 'T1', isLab: false, isElective: true, domain: 'Artificial Intelligence'),
    UIUCurriculumCourse(trimester: 11, sl: 10, code: 'CSE 4813', title: 'Deep Learning', credit: 3.0, prerequisite: 'CSE 4889', examDay: 'Day 1', examSlot: 'T3', isLab: false, isElective: true, domain: 'Artificial Intelligence'),
    UIUCurriculumCourse(trimester: 11, sl: 11, code: 'CSE 4893', title: 'Introduction to Bioinformatics', credit: 3.0, prerequisite: 'CSE 4889', examDay: 'Day 4', examSlot: 'T3', isLab: false, isElective: true, domain: 'Artificial Intelligence'),
    UIUCurriculumCourse(trimester: 11, sl: 12, code: 'CSE 4133', title: 'Business Intelligence', credit: 3.0, prerequisite: 'CSE 3411', examDay: 'Day 6', examSlot: 'T3', isLab: false, isElective: true, domain: 'Software & Systems'),
  ];

  /// Official UIU GED Optional Course Pool (Students must complete any 3 courses)
  static const List<UIUCurriculumCourse> gedOptionalCatalog = [
    UIUCurriculumCourse(trimester: 9, sl: 2, code: 'GED 1005', title: 'AI Literacy and Prompt Engineering', credit: 3.0, prerequisite: 'X', examDay: 'Day 1', examSlot: 'T1', isLab: false, isGedOptional: true, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 10, sl: 6, code: 'TEC 2499', title: 'Technology Entrepreneurship', credit: 3.0, prerequisite: 'X', examDay: 'Day 3', examSlot: 'T2', isLab: false, isGedOptional: true, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 10, sl: 1, code: 'ECO 4101', title: 'Economics', credit: 3.0, prerequisite: 'X', examDay: 'Day 6', examSlot: 'T1', isLab: false, isGedOptional: true, domain: 'General Education'),
    UIUCurriculumCourse(trimester: 11, sl: 1, code: 'ACT 2111', title: 'Financial and Managerial Accounting', credit: 3.0, prerequisite: 'X', examDay: 'Day 2', examSlot: 'T3', isLab: false, isGedOptional: true, domain: 'General Education'),
  ];

  /// Specialization Tracks Course Mappings
  static const List<String> trackAiDataCodes = [
    'CSE 4889', // Machine Learning (Gateway)
    'CSE 4813', // Deep Learning
    'CSE 4811', // Natural Language Processing
    'CSE 4891', // Data Mining
    'CSE 4883', // Digital Image Processing
    'CSE 4817', // Big Data Analytics
    'CSE 4893', // Introduction to Bioinformatics
  ];

  static const List<String> trackSoftwareCodes = [
    'CSE 4181', // Mobile Application Development (Gateway)
    'CSE 4435', // Software Architecture (Gateway)
    'CSE 4945', // UI: Concepts and Design (Gateway)
    'CSE 4495', // Software Testing and Quality Assurance
    'CSE 4133', // Business Intelligence
    'CSE 4451', // Human Computer Interaction
  ];

  static const List<String> trackSecurityCodes = [
    'CSE 4777', // Network Security (Gateway)
    'CSE 4125', // Ethical Hacking and Network Defense
    'CSE 4587', // Cloud Computing
  ];

  static const List<String> trackHardwareCodes = [
    'CSE 4327', // VLSI Design (Gateway)
    'CSE 4399', // Embedded Machine Learning
    'EEE 4261', // Green Computing
  ];

  /// Generates a personalized AI advisor report based on official UIU course sequences
  static AIAdvisorReport generateReport({
    required UserProfile profile,
    required List<SemesterTranscript> semesters,
  }) {
    // 1. Gather all completed course codes & their best grade point
    final completedAttempts = <Course>[];
    final ongoingCourses = <Course>[];
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

        // Track ongoing / in-progress courses
        if (course.isOngoing || sem.isOngoing) {
          ongoingCourses.add(course);
          ongoingCredits += course.credit;
          continue; // Ongoing courses must not be recorded as failed or finished with 0 GP!
        }

        final grade = (course.grade ?? '').trim().toUpperCase();
        if (grade == 'W' || grade.isEmpty) continue; // Withdraw excluded

        final gp = course.gradePoint ?? 0.0;
        completedAttempts.add(course);

        // Domain tracking
        final domain = _findCourseDomain(course.code);
        gradesByDomain.putIfAbsent(domain, () => []).add(gp);
      }
    }

    // Recompute transcript stats using best attempts per unique course
    final bestAttemptsMap = <String, Course>{};
    for (final course in completedAttempts) {
      final key = _cleanCode(course.code);
      final gp = course.gradePoint ?? 0.0;
      if (!bestAttemptsMap.containsKey(key) || gp > (bestAttemptsMap[key]!.gradePoint ?? 0.0)) {
        bestAttemptsMap[key] = course;
      }
    }

    for (final course in bestAttemptsMap.values) {
      final gp = course.gradePoint ?? 0.0;
      final cr = course.credit;
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

    for (final course in bestAttemptsMap.values) {
      final gp = course.gradePoint ?? 0.0;

      // Exclude courses that student is currently taking in ongoing trimester!
      if (ongoingCourses.any((o) => _isCourseMatch(o.code, o.title, course.code, course.title))) {
        continue;
      }

      if (gp < 2.50) {
        // find matching curriculum course to get exam day and slot
        UIUCurriculumCourse? match;
        for (final c in uiuCurriculum) {
          if (_isCourseMatch(c.code, c.title, course.code, course.title)) {
            match = c;
            break;
          }
        }
        if (match != null && !retakeRecommendations.any((r) => _isCourseMatch(r.course.code, r.course.title, match!.code, match.title))) {
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
            examDay: match.examDay,
            examSlot: match.examSlot,
            isProject: match.isProject,
            isLab: match.isLab,
            isGed: match.isGedOptional,
            isElective: match.isElective,
          ));
        }
      }
    }

    // 3. Quota tracking: UIU BSCSE degree requires exactly 3 GED Optionals and 5 Electives
    int completedGedOptionalCount = 0;
    int completedElectiveCount = 0;
    for (final c in bestAttemptsMap.values) {
      if ((c.gradePoint ?? 0.0) > 0.0) {
        if (_isGedOptionalCourse(c.code, c.title)) completedGedOptionalCount++;
        if (_isElectiveCourse(c.code, c.title)) completedElectiveCount++;
      }
    }
    for (final c in ongoingCourses) {
      if (_isGedOptionalCourse(c.code, c.title)) completedGedOptionalCount++;
      if (_isElectiveCourse(c.code, c.title)) completedElectiveCount++;
    }

    // Track detection for Major / Specialization Electives
    int countTrackEnrollments(List<String> codes) {
      int count = 0;
      for (final code in codes) {
        final taken = bestAttemptsMap.values.any((comp) =>
            (comp.gradePoint ?? 0.0) >= 2.0 && _isCourseMatch(comp.code, comp.title, code, ''));
        final ongoing = ongoingCourses.any((ong) => _isCourseMatch(ong.code, ong.title, code, ''));
        if (taken || ongoing) count++;
      }
      return count;
    }

    final int aiTrackCount = countTrackEnrollments(trackAiDataCodes);
    final int seTrackCount = countTrackEnrollments(trackSoftwareCodes);
    final int secTrackCount = countTrackEnrollments(trackSecurityCodes);
    final int hwTrackCount = countTrackEnrollments(trackHardwareCodes);
    final int maxTrackScore = [aiTrackCount, seTrackCount, secTrackCount, hwTrackCount].reduce((a, b) => a > b ? a : b);

    // Prerequisite satisfaction helper
    bool isPrereqSatisfied(String prerequisite) {
      if (prerequisite == 'X') return true;
      if (prerequisite == 'CREDITS_85' || prerequisite.contains('85')) {
        return (realCompletedCredits + ongoingCredits) >= 85.0;
      }
      if (prerequisite == 'CREDITS_70' || prerequisite.contains('70')) {
        return (realCompletedCredits + ongoingCredits) >= 70.0;
      }
      final reqs = prerequisite
          .replaceAll('&', ',')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s != 'X')
          .toList();
      return reqs.every((r) {
        final isComp = bestAttemptsMap.values.any((comp) =>
            (comp.gradePoint ?? 0.0) > 0.0 &&
            _isCourseMatch(comp.code, comp.title, r, ''));
        final isOng = ongoingCourses.any((o) => _isCourseMatch(o.code, o.title, r, ''));
        return isComp || isOng;
      });
    }

    // Determine student's earliest incomplete core trimester milestone
    int earliestIncompleteCoreTrimester = 12;
    for (final c in uiuCurriculum) {
      if (!c.isElective && !c.isGedOptional) {
        final isDone = bestAttemptsMap.values.any((comp) =>
            (comp.gradePoint ?? 0.0) >= 2.50 && _isCourseMatch(comp.code, comp.title, c.code, c.title));
        final isOngoing = ongoingCourses.any((o) => _isCourseMatch(o.code, o.title, c.code, c.title));
        if (!isDone && !isOngoing && c.trimester < earliestIncompleteCoreTrimester) {
          earliestIncompleteCoreTrimester = c.trimester;
        }
      }
    }

    // 4. Build Smart GED Choice Recommendation (if quota < 3 and eligible)
    CourseRecommendation? gedChoiceRec;
    if (completedGedOptionalCount < 3) {
      final remainingGedPool = <UIUCurriculumCourse>[];
      for (final ged in gedOptionalCatalog) {
        final isDone = bestAttemptsMap.values.any((comp) =>
            (comp.gradePoint ?? 0.0) > 0.0 && _isCourseMatch(comp.code, comp.title, ged.code, ged.title));
        final isOng = ongoingCourses.any((ong) => _isCourseMatch(ong.code, ong.title, ged.code, ged.title));
        if (!isDone && !isOng && isPrereqSatisfied(ged.prerequisite)) {
          remainingGedPool.add(ged);
        }
      }

      if (remainingGedPool.isNotEmpty) {
        final choices = remainingGedPool.take(3).toList();
        final slashCodes = choices.map((c) => c.code).join(' / ');
        final slashTitles = choices.map((c) => c.title.replaceAll(' and ', ' & ')).join(' / ');
        final choiceDetails = choices.map((c) => ChoiceOptionDetail(
          code: c.code,
          title: c.title,
          examDay: c.examDay,
          examSlot: c.examSlot,
          credit: c.credit,
        )).toList();

        gedChoiceRec = CourseRecommendation(
          course: Course(
            code: slashCodes,
            title: slashTitles,
            credit: 3.0,
            grade: 'A',
            gradePoint: 4.0,
          ),
          priorityRank: rank++,
          reason: 'UIU BSCSE requires 3 GED Optionals ($completedGedOptionalCount/3 completed). Choose 1 course among the remaining available options: ${choices.map((c) => c.code).join(", ")}.',
          unlockRationale: 'No prerequisite restrictions. Choose according to career orientation.',
          examDay: choices.map((c) => c.examDay).toSet().join(' / '),
          examSlot: choices.map((c) => c.examSlot).toSet().join(' / '),
          isGed: true,
          isChoiceOption: choices.length > 1,
          trackName: 'GED Optional Choice ($completedGedOptionalCount/3 Completed)',
          optionCodes: choices.map((c) => c.code).toList(),
          choiceDetails: choiceDetails,
        );
      }
    }

    // 5. Build Smart Specialization / Major Elective Choice Recommendation (if quota < 5 and eligible)
    CourseRecommendation? electiveChoiceRec;
    if (completedElectiveCount < 5) {
      if (maxTrackScore == 0) {
        // Gateway choice across multiple tracks
        final gatewayCodes = ['CSE 4889', 'CSE 4181', 'CSE 4435', 'CSE 4777'];
        final eligibleGateways = <UIUCurriculumCourse>[];
        for (final code in gatewayCodes) {
          final c = uiuCurriculum.firstWhere((x) => _isCourseMatch(x.code, x.title, code, ''));
          final isDone = bestAttemptsMap.values.any((comp) =>
              (comp.gradePoint ?? 0.0) >= 2.0 && _isCourseMatch(comp.code, comp.title, c.code, c.title));
          final isOng = ongoingCourses.any((ong) => _isCourseMatch(ong.code, ong.title, c.code, c.title));
          if (!isDone && !isOng && isPrereqSatisfied(c.prerequisite)) {
            eligibleGateways.add(c);
          }
        }

        if (eligibleGateways.isNotEmpty) {
          final choices = eligibleGateways.take(3).toList();
          final slashCodes = choices.map((c) => c.code).join(' / ');
          final slashTitles = choices.map((c) => c.title.replaceAll(' and ', ' & ')).join(' / ');
          final choiceDetails = choices.map((c) => ChoiceOptionDetail(
            code: c.code,
            title: c.title,
            examDay: c.examDay,
            examSlot: c.examSlot,
            credit: c.credit,
          )).toList();

          electiveChoiceRec = CourseRecommendation(
            course: Course(
              code: slashCodes,
              title: slashTitles,
              credit: 3.0,
              grade: 'A',
              gradePoint: 4.0,
            ),
            priorityRank: rank++,
            reason: 'Specialization Track Gateway. You have not initiated a major track yet. Choose an introductory gateway course to declare your focus area (AI & Data Science, Software Eng, or Cybersecurity).',
            unlockRationale: 'Prerequisites verified. Selecting one gateway sets your major specialization track.',
            examDay: choices.map((c) => c.examDay).toSet().join(' / '),
            examSlot: choices.map((c) => c.examSlot).toSet().join(' / '),
            isElective: true,
            isChoiceOption: choices.length > 1,
            trackName: 'Major Track Gateway Choice',
            optionCodes: choices.map((c) => c.code).toList(),
            choiceDetails: choiceDetails,
          );
        }
      } else {
        // Track declared: suggest follow-up courses from the declared track
        String activeTrackName = '';
        List<String> activeTrackCodes = [];
        if (aiTrackCount == maxTrackScore) {
          activeTrackName = 'AI & Data Science';
          activeTrackCodes = trackAiDataCodes;
        } else if (seTrackCount == maxTrackScore) {
          activeTrackName = 'Software Engineering';
          activeTrackCodes = trackSoftwareCodes;
        } else if (secTrackCount == maxTrackScore) {
          activeTrackName = 'Cybersecurity & Networks';
          activeTrackCodes = trackSecurityCodes;
        } else {
          activeTrackName = 'Hardware & Embedded';
          activeTrackCodes = trackHardwareCodes;
        }

        final eligibleTrackCourses = <UIUCurriculumCourse>[];
        for (final code in activeTrackCodes) {
          final match = uiuCurriculum.where((x) => _isCourseMatch(x.code, x.title, code, ''));
          if (match.isEmpty) continue;
          final c = match.first;
          final isDone = bestAttemptsMap.values.any((comp) =>
              (comp.gradePoint ?? 0.0) >= 2.0 && _isCourseMatch(comp.code, comp.title, c.code, c.title));
          final isOng = ongoingCourses.any((ong) => _isCourseMatch(ong.code, ong.title, c.code, c.title));
          if (!isDone && !isOng && isPrereqSatisfied(c.prerequisite)) {
            eligibleTrackCourses.add(c);
          }
        }

        if (eligibleTrackCourses.isNotEmpty) {
          final choices = eligibleTrackCourses.take(3).toList();
          final slashCodes = choices.map((c) => c.code).join(' / ');
          final slashTitles = choices.map((c) => c.title.replaceAll(' and ', ' & ')).join(' / ');
          final choiceDetails = choices.map((c) => ChoiceOptionDetail(
            code: c.code,
            title: c.title,
            examDay: c.examDay,
            examSlot: c.examSlot,
            credit: c.credit,
          )).toList();

          electiveChoiceRec = CourseRecommendation(
            course: Course(
              code: slashCodes,
              title: slashTitles,
              credit: 3.0,
              grade: 'A',
              gradePoint: 4.0,
            ),
            priorityRank: rank++,
            reason: 'Active Specialization Track: You have initiated $activeTrackName. Choose an advanced follow-up course aligned with your specialization.',
            unlockRationale: 'Prerequisites verified under UIU specialization guidelines.',
            examDay: choices.map((c) => c.examDay).toSet().join(' / '),
            examSlot: choices.map((c) => c.examSlot).toSet().join(' / '),
            isElective: true,
            isChoiceOption: choices.length > 1,
            trackName: '$activeTrackName Track Follow-up',
            optionCodes: choices.map((c) => c.code).toList(),
            choiceDetails: choiceDetails,
          );
        }
      }
    }

    // 6. Find eligible core curriculum courses based on completed prerequisites
    // (GED Optionals & Electives are handled via our smart choice recommenders above)
    final eligibleCourses = <UIUCurriculumCourse>[];

    for (final c in uiuCurriculum) {
      if (c.isGedOptional || c.isElective) {
        continue; // Handled intelligently above
      }

      // EXCLUDE courses already enrolled in ongoing trimester!
      if (ongoingCourses.any((o) => _isCourseMatch(o.code, o.title, c.code, c.title))) {
        continue;
      }

      // Skip if already passed with gp >= 2.50!
      if (bestAttemptsMap.values.any((comp) =>
          (comp.gradePoint ?? 0.0) >= 2.50 &&
          _isCourseMatch(comp.code, comp.title, c.code, c.title))) {
        continue;
      }

      // Check prerequisites
      if (isPrereqSatisfied(c.prerequisite)) {
        eligibleCourses.add(c);
      }
    }

    // Sort eligible core courses: prioritize earliest trimesters
    eligibleCourses.sort((a, b) => a.trimester.compareTo(b.trimester));

    // 7. Select balanced set of courses adhering to UIU Credit Capacity policy
    // (3.00-4.00: 16 Cr, 2.50-3.00: 14 Cr, 2.00-2.49: 12 Cr, <2.00: 10 Cr)
    final double maxCreditCap = realCGPA >= 3.00
        ? 16.0
        : (realCGPA >= 2.50 ? 14.0 : (realCGPA >= 2.00 ? 12.0 : 10.0));

    final recommended = <CourseRecommendation>[...retakeRecommendations];
    double currentAccumulatedCredits = recommended.fold(0.0, (sum, r) => sum + r.course.credit);
    double theoryCredits = recommended.where((r) => !r.course.isLab && !r.isProject).fold(0.0, (sum, r) => sum + r.course.credit);
    double labCredits = recommended.where((r) => r.course.isLab).fold(0.0, (sum, r) => sum + r.course.credit);
    int recommendedGedCount = 0;
    int recommendedElectiveCount = 0;

    final conflicts = <CourseConflictWarning>[];
    
    // Register used exam days and time slots
    final usedExamDays = <String>{};
    final occupiedTimeSlots = <String, String>{};
    for (final r in recommended) {
      final hasExam = r.examDay != 'N/A' && r.examDay != '----' && !r.isLab && !r.isProject;
      if (hasExam) {
        usedExamDays.add(r.examDay);
        if (r.examSlot != 'N/A' && r.examSlot != '----') {
          occupiedTimeSlots['${r.examDay}_${r.examSlot}'] = r.course.code;
        }
      }
    }

    // Check if eligible to inject GED Choice
    final bool canInjectGed = gedChoiceRec != null &&
        completedGedOptionalCount < 3 &&
        (realCompletedCredits + ongoingCredits >= 50.0 || earliestIncompleteCoreTrimester >= 8) &&
        (currentAccumulatedCredits + 3.0 <= maxCreditCap);

    if (canInjectGed) {
      recommended.add(gedChoiceRec);
      currentAccumulatedCredits += 3.0;
      theoryCredits += 3.0;
      recommendedGedCount++;
    }

    // Check if eligible to inject Specialization Elective Choice
    final bool canInjectElective = electiveChoiceRec != null &&
        completedElectiveCount < 5 &&
        (realCompletedCredits + ongoingCredits >= 70.0 || earliestIncompleteCoreTrimester >= 9) &&
        (currentAccumulatedCredits + 3.0 <= maxCreditCap);

    if (canInjectElective) {
      recommended.add(electiveChoiceRec);
      currentAccumulatedCredits += 3.0;
      theoryCredits += 3.0;
      recommendedElectiveCount++;
    }

    String getCourseReason(UIUCurriculumCourse c) {
      if (c.isProject && !c.isLab) {
        return 'Final Year Design Project (FYDP). Continuous supervisor assessment & milestone defense with no written final exam.';
      } else if (c.isProject && c.isLab) {
        return 'Practical Term Project Lab. Continuous evaluation and project submission with no conflicting written final exam.';
      } else if (c.isLab) {
        return 'Hands-on laboratory practical course. Continuous assessment with no conflicting theory final.';
      } else if (c.isGedOptional) {
        return 'General Education (GED) Optional requirement towards degree completion.';
      } else if (c.isElective) {
        return 'Specialized Elective course fulfilling degree track focus area.';
      } else {
        return 'Core degree milestone for Trimester ${c.trimester}. Fulfills prerequisites for advanced upper-level courses.';
      }
    }

    // PASS 1: STRICT SINGLE EXAM PER DAY (ZERO SAME-DAY EXAMS)
    for (final c in eligibleCourses) {
      if (ongoingCourses.any((o) => _isCourseMatch(o.code, o.title, c.code, c.title))) continue;
      if (bestAttemptsMap.values.any((comp) => (comp.gradePoint ?? 0.0) >= 2.50 && _isCourseMatch(comp.code, comp.title, c.code, c.title))) continue;
      if (recommended.any((r) => _isCourseMatch(r.course.code, r.course.title, c.code, c.title))) continue;
      if (c.isGedOptional && (completedGedOptionalCount + recommendedGedCount >= 3)) continue;
      if (c.isElective && (completedElectiveCount + recommendedElectiveCount >= 5)) continue;
      if (currentAccumulatedCredits + c.credit > maxCreditCap) continue;
      if (currentAccumulatedCredits >= (maxCreditCap - 2.0) && currentAccumulatedCredits >= 11.0) break;
      if (c.isLab && labCredits >= 2.0) continue;

      final hasExam = c.examDay != 'N/A' && c.examDay != '----' && !c.isLab && !c.isProject;

      // In Pass 1: NEVER allow 2 exams on the same day!
      if (hasExam && usedExamDays.contains(c.examDay)) {
        continue; // Skip course to maintain 0 same-day clashes
      }

      final slotKey = hasExam && c.examSlot != 'N/A' && c.examSlot != '----' ? '${c.examDay}_${c.examSlot}' : null;
      if (slotKey != null && occupiedTimeSlots.containsKey(slotKey)) {
        continue;
      }

      if (hasExam) {
        usedExamDays.add(c.examDay);
        if (slotKey != null) occupiedTimeSlots[slotKey] = c.code;
      }

      if (c.isGedOptional) recommendedGedCount++;
      if (c.isElective) recommendedElectiveCount++;

      recommended.add(CourseRecommendation(
        course: Course(
          code: c.code,
          title: c.title,
          credit: c.credit,
          grade: 'A',
          gradePoint: 4.0,
        ),
        priorityRank: rank++,
        reason: getCourseReason(c),
        unlockRationale: 'Prerequisites verified and satisfied under UIU curriculum guidelines.',
        examDay: c.examDay,
        examSlot: c.examSlot,
        isProject: c.isProject,
        isLab: c.isLab,
        isGed: c.isGedOptional,
        isElective: c.isElective,
      ));

      currentAccumulatedCredits += c.credit;
      if (c.isLab) {
        labCredits += c.credit;
      } else if (!c.isProject) {
        theoryCredits += c.credit;
      }
    }

    // PASS 2: EMERGENCY FALLBACK (Absolute Worst-Case Only: if student load < 11.0 credits)
    if (currentAccumulatedCredits < 11.0) {
      for (final c in eligibleCourses) {
        if (ongoingCourses.any((o) => _isCourseMatch(o.code, o.title, c.code, c.title))) continue;
        if (bestAttemptsMap.values.any((comp) => (comp.gradePoint ?? 0.0) >= 2.50 && _isCourseMatch(comp.code, comp.title, c.code, c.title))) continue;
        if (recommended.any((r) => _isCourseMatch(r.course.code, r.course.title, c.code, c.title))) continue;
        if (c.isGedOptional && (completedGedOptionalCount + recommendedGedCount >= 3)) continue;
        if (c.isElective && (completedElectiveCount + recommendedElectiveCount >= 5)) continue;
        if (currentAccumulatedCredits + c.credit > maxCreditCap) continue;
        if (currentAccumulatedCredits >= 11.0) break;
        if (c.isLab && labCredits >= 2.0) continue;

        final hasExam = c.examDay != 'N/A' && c.examDay != '----' && !c.isLab && !c.isProject;
        final slotKey = hasExam && c.examSlot != 'N/A' && c.examSlot != '----' ? '${c.examDay}_${c.examSlot}' : null;

        // Strictly avoid exact time slot collisions
        if (slotKey != null && occupiedTimeSlots.containsKey(slotKey)) {
          final clashingCourse = occupiedTimeSlots[slotKey]!;
          conflicts.add(CourseConflictWarning(
            title: 'Exam Time Conflict Prevented (${c.examDay} • Slot ${c.examSlot})',
            conflictingCourses: [c.code, clashingCourse],
            severity: 'Critical',
            explanation: 'Both ${c.code} and $clashingCourse have examinations scheduled at the exact same time on ${c.examDay} (Slot ${c.examSlot}). Skipped to avoid an exam hall clash.',
            recommendation: 'Register for an alternative elective or take ${c.code} in the next trimester.',
          ));
          continue;
        }

        if (slotKey != null) occupiedTimeSlots[slotKey] = c.code;
        if (hasExam) usedExamDays.add(c.examDay);
        if (c.isGedOptional) recommendedGedCount++;
        if (c.isElective) recommendedElectiveCount++;

        recommended.add(CourseRecommendation(
          course: Course(
            code: c.code,
            title: c.title,
            credit: c.credit,
            grade: 'A',
            gradePoint: 4.0,
          ),
          priorityRank: rank++,
          reason: getCourseReason(c),
          unlockRationale: 'Prerequisites verified and satisfied under UIU curriculum guidelines.',
          examDay: c.examDay,
          examSlot: c.examSlot,
          isProject: c.isProject,
          isLab: c.isLab,
          isGed: c.isGedOptional,
          isElective: c.isElective,
        ));

        currentAccumulatedCredits += c.credit;
        if (c.isLab) {
          labCredits += c.credit;
        } else if (!c.isProject) {
          theoryCredits += c.credit;
        }
      }
    }

    // Fallback for 1st trimester fresh students or empty transcripts
    if (recommended.isEmpty) {
      final eligibleFallbacks = uiuCurriculum
          .where((c) =>
              !ongoingCourses.any((o) => _isCourseMatch(o.code, o.title, c.code, c.title)) &&
              !bestAttemptsMap.values.any((comp) => (comp.gradePoint ?? 0.0) >= 2.50 && _isCourseMatch(comp.code, comp.title, c.code, c.title)))
          .toList();
      eligibleFallbacks.sort((a, b) => a.trimester.compareTo(b.trimester));

      for (final c in eligibleFallbacks) {
        if (currentAccumulatedCredits + c.credit > maxCreditCap) continue;
        if (currentAccumulatedCredits >= (maxCreditCap - 2.0) && currentAccumulatedCredits >= 11.0) break;
        if (c.isLab && labCredits >= 2.0) continue;

        final hasExam = c.examDay != 'N/A' && c.examDay != '----' && !c.isLab && !c.isProject;
        if (hasExam && usedExamDays.contains(c.examDay)) continue;

        final slotKey = hasExam && c.examSlot != 'N/A' && c.examSlot != '----' ? '${c.examDay}_${c.examSlot}' : null;
        if (slotKey != null && occupiedTimeSlots.containsKey(slotKey)) continue;

        if (slotKey != null) occupiedTimeSlots[slotKey] = c.code;
        if (hasExam) usedExamDays.add(c.examDay);

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
          examDay: c.examDay,
          examSlot: c.examSlot,
          isProject: c.isProject,
          isLab: c.isLab,
          isGed: c.isGedOptional,
          isElective: c.isElective,
        ));
        currentAccumulatedCredits += c.credit;
        if (c.isLab) {
          labCredits += c.credit;
        } else if (!c.isProject) {
          theoryCredits += c.credit;
        }
      }
    }

    // SAME-DAY 2 EXAMS DETECTION & ALERT (If any emergency occurrence in Pass 2)
    final examsByDay = <String, List<CourseRecommendation>>{};
    for (final rec in recommended) {
      if (rec.examDay != 'N/A' && rec.examDay != '----' && !rec.course.isLab && !rec.isProject) {
        examsByDay.putIfAbsent(rec.examDay, () => []).add(rec);
      }
    }

    final finalRecommended = <CourseRecommendation>[];
    for (final rec in recommended) {
      final peers = examsByDay[rec.examDay] ?? [];
      final otherPeers = peers.where((p) => p.course.code != rec.course.code).toList();
      if (otherPeers.isNotEmpty) {
        final otherDesc = otherPeers.map((p) => '${p.course.code} (${p.examSlot})').join(', ');
        finalRecommended.add(rec.copyWith(
          hasSameDayExam: true,
          sameDayWithCourse: otherDesc,
        ));
      } else {
        finalRecommended.add(rec);
      }
    }

    // Inject high-visibility warnings for every day with 2 or more exams (without emoji in title)
    examsByDay.forEach((day, dayCourses) {
      if (dayCourses.length >= 2) {
        final courseDetails = dayCourses.map((c) => '${c.course.code} (Slot ${c.examSlot})').join(' & ');
        final codes = dayCourses.map((c) => c.course.code).toList();
        conflicts.insert(0, CourseConflictWarning(
          title: '2 Exams on Same Day Alert ($day)',
          conflictingCourses: codes,
          severity: 'High',
          explanation: 'You have ${dayCourses.length} exams scheduled on the SAME DAY ($day): $courseDetails. While their time slots do not directly clash, preparing and sitting for two major final exams on the same date creates intense exam pressure.',
          recommendation: 'Start your study preparations early in the trimester. If you prefer a lighter finals routine, consider swapping one of these courses with a laboratory or another course scheduled on a different exam day.',
        ));
      }
    });

    // Workload warning if theory courses >= 4 or labs >= 3
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

    final bool isMeritScholarshipEligible = realCGPA >= 3.50;
    final String? meritScholarshipNotice = isMeritScholarshipEligible
        ? '🏆 UIU Trimester Merit Scholarship Track (Top 10% Waiver Pace):\n'
          '• Top 2%: 100% Tuition Waiver | Next 4%: 50% Waiver | Next 4%: 25% Waiver\n'
          '• Official Policy: Minimum 3.50 GPA and regular credit completion required.\n'
          '• ⚠️ Important Exclusion Rule: Retake, Repeat, Project (FYDP), Internship, and Thesis courses are EXCLUDED from the merit scholarship calculation. Maintain at least 9–12 credits of regular fresh courses to protect your waiver eligibility!'
        : null;

    final summary = realCompletedCredits == 0
        ? 'Welcome to UIU! As a 1st trimester student, your focus should be on building a strong foundation in Structured Programming and Calculus. Attending all quizzes and securing 26+ out of 30 in midterms will lock in an immediate Dean\'s Honor pace.'
        : 'Based on your completed ${realCompletedCredits.toStringAsFixed(1)} credits and current CGPA of ${realCGPA.toStringAsFixed(2)}, you are maintaining a ${(realCGPA >= 3.75 ? 'Dean\'s Honor' : 'solid academic')} trajectory. To hit your target of ${targetCGPA.toStringAsFixed(2)}, maintain an average SGPA of ${projectedPace.toStringAsFixed(2)} across your remaining ${remainingCredits.toInt()} credits.';

    return AIAdvisorReport(
      overallSummary: summary,
      currentPaceCGPA: realCGPA,
      projectedFinalCGPA: targetCGPA,
      domainAnalyses: domainAnalyses,
      recommendedCourses: finalRecommended,
      conflictWarnings: conflicts,
      gpaBoosterTips: [
        'Secure 26+ in Midterms (30% weight) to reduce final exam pressure.',
        'Never skip class attendance and continuous assessment quizzes.',
        'Retake any D/F grade to replace it completely in your cumulative CGPA.',
      ],
      suggestedCreditLoad: currentAccumulatedCredits,
      isMeritScholarshipEligible: isMeritScholarshipEligible,
      meritScholarshipNotice: meritScholarshipNotice,
    );
  }

  static bool _isGedOptionalCourse(String code, String title) {
    final clean = _cleanCode(code);
    final cleanT = _cleanTitle(title);
    return clean == 'GED1005' ||
        clean == 'ECO4101' ||
        clean == 'ECO2101' ||
        clean == 'ACT2111' ||
        clean == 'TEC2499' ||
        clean == 'IPE3401' ||
        clean == 'IPE2101' ||
        cleanT.contains('promptengineering') ||
        cleanT.contains('entrepreneurship') ||
        cleanT.contains('economics') ||
        cleanT.contains('accounting') ||
        cleanT.contains('industrial') ||
        cleanT.contains('operationalmanagement');
  }

  static bool _isElectiveCourse(String code, String title) {
    for (final c in uiuCurriculum) {
      if (c.isElective && _isCourseMatch(c.code, c.title, code, title)) {
        return true;
      }
    }
    return false;
  }

  static String _cleanCode(String code) {
    return code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  }

  static String _cleanTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll('laboratory', 'lab')
        .replaceAll('engineering', 'eng')
        .replaceAll('fundamental', 'fund')
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }

  /// Known UIU Course Code Equivalences across old and new catalog curricula
  static final Map<String, Set<String>> _uiuEquivalents = {
    'CSE3711': {'CSE3711', 'CSE4531'}, // Computer Networks
    'CSE4531': {'CSE3711', 'CSE4531'},
    'CSE3712': {'CSE3712', 'CSE4532', 'CSE3714'}, // Computer Networks Lab
    'CSE4532': {'CSE3712', 'CSE4532', 'CSE3714'},
    'CSE3714': {'CSE3712', 'CSE4532', 'CSE3714'},

    'CSE4325': {'CSE4325', 'CSE3825'}, // Microprocessors
    'CSE3825': {'CSE4325', 'CSE3825'},
    'CSE4326': {'CSE4326', 'CSE3826'}, // Microprocessors Lab
    'CSE3826': {'CSE4326', 'CSE3826'},

    'CSE3421': {'CSE3421', 'CSE4121'}, // Software Engineering
    'CSE4121': {'CSE3421', 'CSE4121'},
    'CSE3422': {'CSE3422', 'CSE4122'}, // Software Engineering Lab
    'CSE4122': {'CSE3422', 'CSE4122'},

    'CSE4329': {'CSE4329', 'CSE4509', 'CSE3715', 'CSE3729'}, // Operating Systems
    'CSE4509': {'CSE4329', 'CSE4509', 'CSE3715', 'CSE3729'},
    'CSE3715': {'CSE4329', 'CSE4509', 'CSE3715', 'CSE3729'},
    'CSE3729': {'CSE4329', 'CSE4509', 'CSE3715', 'CSE3729'},
    'CSE4330': {'CSE4330', 'CSE4510', 'CSE3716', 'CSE3730'}, // Operating Systems Lab
    'CSE4510': {'CSE4330', 'CSE4510', 'CSE3716', 'CSE3730'},
    'CSE3716': {'CSE4330', 'CSE4510', 'CSE3716', 'CSE3730'},
    'CSE3730': {'CSE4330', 'CSE4510', 'CSE3716', 'CSE3730'},

    'PMG4101': {'PMG4101', 'CSE4101'}, // Project Management
    'CSE4101': {'PMG4101', 'CSE4101'},

    'CSE4611': {'CSE4611', 'CSE4111'}, // Compiler Design
    'CSE4111': {'CSE4611', 'CSE4111'},

    'ECO4101': {'ECO4101', 'ECO2101'}, // Economics
    'ECO2101': {'ECO4101', 'ECO2101'},

    'IPE3401': {'IPE3401', 'IPE2101'}, // Industrial and Operational Management
    'IPE2101': {'IPE3401', 'IPE2101'},
  };

  static bool _areCodesEquivalent(String codeA, String codeB) {
    final cleanA = _cleanCode(codeA);
    final cleanB = _cleanCode(codeB);
    if (cleanA.isEmpty || cleanB.isEmpty) return false;
    if (cleanA == cleanB) return true;
    if (_uiuEquivalents.containsKey(cleanA) && _uiuEquivalents[cleanA]!.contains(cleanB)) {
      return true;
    }
    return false;
  }

  static bool isCourseMatch(String codeA, String titleA, String codeB, String titleB) {
    return _isCourseMatch(codeA, titleA, codeB, titleB);
  }

  static bool _isCourseMatch(String codeA, String titleA, String codeB, String titleB) {
    // 1. Direct or catalogue equivalent code match
    if (_areCodesEquivalent(codeA, codeB)) return true;

    // 2. Title matching
    final tA = _cleanTitle(titleA);
    final tB = _cleanTitle(titleB);
    if (tA.isNotEmpty && tB.isNotEmpty) {
      if (tA == tB) return true;
      if (tA.contains(tB) || tB.contains(tA)) {
        final cleanA = _cleanCode(codeA);
        final cleanB = _cleanCode(codeB);
        final isLabA = tA.contains('lab') || cleanA.endsWith('2') || cleanA.endsWith('4') || cleanA.endsWith('6') || cleanA.endsWith('8');
        final isLabB = tB.contains('lab') || cleanB.endsWith('2') || cleanB.endsWith('4') || cleanB.endsWith('6') || cleanB.endsWith('8');
        if (isLabA == isLabB) return true;
      }
    }

    return false;
  }

  static String _findCourseDomain(String code) {
    for (final c in uiuCurriculum) {
      if (_areCodesEquivalent(c.code, code)) {
        return c.domain;
      }
    }
    final clean = _cleanCode(code);
    if (clean.startsWith('MATH')) return 'Mathematics';
    if (clean.startsWith('CSE')) return 'Programming & CS';
    if (clean.startsWith('EEE')) return 'Hardware & Architecture';
    if (clean.startsWith('ENG') || clean.startsWith('BDS') || clean.startsWith('SOC') || clean.startsWith('GED')) return 'General Education';
    return 'Programming & CS';
  }
}
