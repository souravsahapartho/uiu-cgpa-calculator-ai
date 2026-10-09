import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/course.dart';
import '../../models/semester_transcript.dart';
import '../constants/uiu_grading_scale.dart';

/// Extracts UIU batch from student ID.
/// UIU ID format: 011BBBNNNN where BBB = batch (3 digits at positions 3-5, 0-indexed)
/// e.g. 0112330538 → batch 233, 0112520445 → batch 252
String extractBatchFromId(String id) {
  final digits = id.replaceAll(RegExp(r'\D'), '');
  if (digits.length >= 7) {
    return digits.substring(3, 6); // digits at index 3,4,5 = batch
  }
  return '';
}

class UserProfile {
  final String name;
  final String studentId;
  final String department;
  final String program;
  final String batch;
  final double currentCGPA;
  final double completedCredits;
  final double totalDegreeCredits;
  final double targetCGPA;

  const UserProfile({
    required this.name,
    required this.studentId,
    required this.department,
    required this.program,
    required this.batch,
    required this.currentCGPA,
    required this.completedCredits,
    required this.totalDegreeCredits,
    required this.targetCGPA,
  });

  double get remainingCredits =>
      (totalDegreeCredits - completedCredits).clamp(0.0, totalDegreeCredits);
  double get progressPercentage =>
      totalDegreeCredits > 0 ? (completedCredits / totalDegreeCredits).clamp(0.0, 1.0) : 0.0;

  UserProfile copyWith({
    String? name,
    String? studentId,
    String? department,
    String? program,
    String? batch,
    double? currentCGPA,
    double? completedCredits,
    double? totalDegreeCredits,
    double? targetCGPA,
  }) {
    return UserProfile(
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      program: program ?? this.program,
      batch: batch ?? this.batch,
      currentCGPA: currentCGPA ?? this.currentCGPA,
      completedCredits: completedCredits ?? this.completedCredits,
      totalDegreeCredits: totalDegreeCredits ?? this.totalDegreeCredits,
      targetCGPA: targetCGPA ?? this.targetCGPA,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'studentId': studentId,
      'department': department,
      'program': program,
      'batch': batch,
      'currentCGPA': currentCGPA,
      'completedCredits': completedCredits,
      'totalDegreeCredits': totalDegreeCredits,
      'targetCGPA': targetCGPA,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      department: json['department'] as String? ?? 'Computer Science & Engineering',
      program: json['program'] as String? ?? 'B.Sc. in CSE',
      batch: json['batch'] as String? ?? '',
      currentCGPA: (json['currentCGPA'] as num?)?.toDouble() ?? 0.0,
      completedCredits: (json['completedCredits'] as num?)?.toDouble() ?? 0.0,
      totalDegreeCredits: (json['totalDegreeCredits'] as num?)?.toDouble() ?? 138.0,
      targetCGPA: (json['targetCGPA'] as num?)?.toDouble() ?? 3.75,
    );
  }
}

class UserProfileProvider extends ChangeNotifier {
  UserProfileProvider();

  static const _keyName = 'user_name';
  static const _keyId = 'user_id';
  static const _keyDept = 'user_dept';
  static const _keyProgram = 'user_program';
  static const _keyBatch = 'user_batch';
  static const _keyCGPA = 'user_cgpa';
  static const _keyCompletedCredits = 'user_completed_credits';
  static const _keyTotalCredits = 'user_total_credits';
  static const _keyTargetCGPA = 'user_target_cgpa';
  static const _keyOnboarded = 'user_onboarded';
  static const _keyThemeMode = 'theme_mode'; // 0=system,1=light,2=dark
  static const _keySemesters = 'user_semesters_json';

  bool _isOnboarded = false;
  ThemeMode _themeMode = ThemeMode.light;
  List<SemesterTranscript> _semesters = [];

  UserProfile _profile = const UserProfile(
    name: '',
    studentId: '',
    department: 'Computer Science & Engineering',
    program: 'B.Sc. in CSE',
    batch: '',
    currentCGPA: 0.0,
    completedCredits: 0.0,
    totalDegreeCredits: 0.0,
    targetCGPA: 0.0,
  );

  bool get isOnboarded => _isOnboarded;
  UserProfile get profile => _profile;
  ThemeMode get themeMode => _themeMode;
  List<SemesterTranscript> get semesters => _semesters;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboarded = prefs.getBool(_keyOnboarded) ?? false;
    final modeIdx = prefs.getInt(_keyThemeMode) ?? 1;
    _themeMode = ThemeMode.values[modeIdx.clamp(0, 2)];

    if (_isOnboarded) {
      _profile = UserProfile(
        name: prefs.getString(_keyName) ?? '',
        studentId: prefs.getString(_keyId) ?? '',
        department: prefs.getString(_keyDept) ?? 'Computer Science & Engineering',
        program: prefs.getString(_keyProgram) ?? 'B.Sc. in CSE',
        batch: prefs.getString(_keyBatch) ?? '',
        currentCGPA: prefs.getDouble(_keyCGPA) ?? 0.0,
        completedCredits: prefs.getDouble(_keyCompletedCredits) ?? 0.0,
        totalDegreeCredits: prefs.getDouble(_keyTotalCredits) ?? 0.0,
        targetCGPA: prefs.getDouble(_keyTargetCGPA) ?? 0.0,
      );
    }

    final rawSemesters = prefs.getString(_keySemesters);
    if (rawSemesters != null && rawSemesters.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSemesters) as List<dynamic>;
        _semesters = decoded
            .map((s) => SemesterTranscript.fromJson(s as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _semesters = [];
      }
    } else {
      _semesters = [];
    }

    _recomputeMetricsFromSemesters();
    notifyListeners();
  }

    static int getTrimesterWeight(String name) {
    if (name.trim().isEmpty) return 0;
    final clean = name.replaceAll('"', '').trim();

    // 1. Season with 4-digit year: Spring 2023, Summer-2023, Fall_2023, Spring2023
    final exp1 = RegExp(r'\b(spring|summer|fall)\s*[-_/#\s]?\s*(\d{4})\b', caseSensitive: false);
    final match1 = exp1.firstMatch(clean);
    if (match1 != null) {
      final season = match1.group(1)!.toLowerCase();
      final year = int.parse(match1.group(2)!);
      final seasonOrder = season == 'spring' ? 1 : (season == 'summer' ? 2 : 3);
      return year * 10 + seasonOrder;
    }

    // 2. Year then Season: 2023 Spring, 2023-Summer, 2023_Fall
    final exp2 = RegExp(r'\b(\d{4})\s*[-_/#\s]?\s*(spring|summer|fall)\b', caseSensitive: false);
    final match2 = exp2.firstMatch(clean);
    if (match2 != null) {
      final year = int.parse(match2.group(1)!);
      final season = match2.group(2)!.toLowerCase();
      final seasonOrder = season == 'spring' ? 1 : (season == 'summer' ? 2 : 3);
      return year * 10 + seasonOrder;
    }

    // 3. Season with 2-digit year: Spring 23, Summer'23, Fall-23
    final exp3 = RegExp(r"\b(spring|summer|fall)\s*[-_/'#\s]?\s*(\d{2})\b", caseSensitive: false);
    final match3 = exp3.firstMatch(clean);
    if (match3 != null) {
      final season = match3.group(1)!.toLowerCase();
      int yr = int.parse(match3.group(2)!);
      yr = yr < 50 ? 2000 + yr : 1900 + yr;
      final seasonOrder = season == 'spring' ? 1 : (season == 'summer' ? 2 : 3);
      return yr * 10 + seasonOrder;
    }

    // 4. UIU 3-digit term code: 231, 232, 233, 241, etc.
    final exp4 = RegExp(r'\b([12]\d)(1|2|3)\b');
    final match4 = exp4.firstMatch(clean);
    if (match4 != null) {
      final yrShort = int.parse(match4.group(1)!);
      final termDigit = int.parse(match4.group(2)!);
      final yr = yrShort < 50 ? 2000 + yrShort : 1900 + yrShort;
      return yr * 10 + termDigit;
    }

    // 5. Semester terms (Spring / Fall)
    final exp5 = RegExp(r'\b(spring|fall)\s*[-_/#\s]?\s*(\d{2,4})\b', caseSensitive: false);
    final match5 = exp5.firstMatch(clean);
    if (match5 != null) {
      final season = match5.group(1)!.toLowerCase();
      int yr = int.parse(match5.group(2)!);
      if (yr < 100) yr = yr < 50 ? 2000 + yr : 1900 + yr;
      final seasonOrder = season == 'spring' ? 1 : 2;
      return yr * 10 + seasonOrder;
    }

    return 0;
  }

  /// Detects and normalizes trimester names (e.g. Spring 2022, Summer'23, Fall-2024, 2023 Spring, 211, etc.)
  static String? detectTrimester(String text) {
    if (text.trim().isEmpty) return null;
    final clean = text.replaceAll('"', '').trim();

    // 1. Season with year: Spring 2021, Summer-22, Fall 2023, Spring'24
    final exp1 = RegExp(r'\b(spring|summer|fall)\s*[-_/\s]?\s*(\d{2,4})\b', caseSensitive: false);
    final match1 = exp1.firstMatch(clean);
    if (match1 != null) {
      final season = match1.group(1)![0].toUpperCase() + match1.group(1)!.substring(1).toLowerCase();
      int year = int.tryParse(match1.group(2)!) ?? 0;
      if (year < 100) {
        year = year < 50 ? 2000 + year : 1900 + year;
      }
      return '$season $year';
    }

    // 2. Year then Season: 2022 Spring, 2023-Fall
    final exp2 = RegExp(r'\b(20\d{2})\s*[-_/\s]?\s*(spring|summer|fall)\b', caseSensitive: false);
    final match2 = exp2.firstMatch(clean);
    if (match2 != null) {
      final year = match2.group(1)!;
      final season = match2.group(2)![0].toUpperCase() + match2.group(2)!.substring(1).toLowerCase();
      return '$season $year';
    }

    // 3. UIU 3-digit term code: 211, 212, 213, 221, etc.
    final exp3 = RegExp(r'\b([12]\d)(1|2|3)\b');
    final match3 = exp3.firstMatch(clean);
    if (match3 != null) {
      final yrShort = int.parse(match3.group(1)!);
      final termDigit = match3.group(2)!;
      final fullYear = yrShort < 50 ? 2000 + yrShort : 1900 + yrShort;
      final season = termDigit == '1' ? 'Spring' : (termDigit == '2' ? 'Summer' : 'Fall');
      return '$season $fullYear';
    }

    return null;
  }

  /// Returns the chronological next trimester in UIU sequence (Spring -> Summer -> Fall -> Spring (next year)).
  static String getNextTrimester(String term) {
    final detected = detectTrimester(term);
    if (detected != null) {
      final parts = detected.split(' ');
      if (parts.length == 2) {
        final season = parts[0].toLowerCase();
        final year = int.tryParse(parts[1]) ?? DateTime.now().year;
        if (season.startsWith('spr')) return 'Summer $year';
        if (season.startsWith('sum')) return 'Fall $year';
        if (season.startsWith('fal')) return 'Spring ${year + 1}';
      }
    }
    return getDynamicDefaultTrimester();
  }

  static String getDynamicDefaultTrimester() {
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;
    if (month >= 1 && month <= 4) {
      return 'Spring $year';
    } else if (month >= 5 && month <= 8) {
      return 'Summer $year';
    } else {
      return 'Fall $year';
    }
  }

  static String getCourseKey(Course course) {
    final cleanCode = course.code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (cleanCode.isNotEmpty) return cleanCode;
    return course.title.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();
  }

    void _sortAndRecomputeSemesters() {
    if (_semesters.isEmpty) return;

    // 1. Sort chronologically ascending to compute progressive CGPA (Spring -> Summer -> Fall)
    _semesters.sort((a, b) {
      final wa = getTrimesterWeight(a.semesterName);
      final wb = getTrimesterWeight(b.semesterName);
      if (wa != wb) return wa.compareTo(wb);
      return a.semesterName.compareTo(b.semesterName);
    });

    final updatedSemesters = <SemesterTranscript>[];
    // Map of unique course key -> best attempt up to current semester
    final bestAttemptsUpToNow = <String, Map<String, double>>{};

    for (final sem in _semesters) {
      double termPoints = 0.0;
      double termCredits = 0.0;
      double termEarned = 0.0;

      for (final course in sem.courses) {
        final grade = course.grade?.trim().toUpperCase() ?? '';
        if (course.isOngoing) continue; // Ongoing course: do not calculate GPA or earned credits yet
        if (UIUGradingScale.isWithdrawn(grade)) continue; // 'W' completely excluded
        final gp = UIUGradingScale.isIncomplete(grade)
            ? 0.0 // 'I' counts as Fail (0.00 gp)
            : (course.gradePoint ?? (course.grade != null ? UIUGradingScale.getGradePoint(course.grade!) : 0.0));
        if (course.credit > 0) {
          termPoints += (gp * course.credit);
          termCredits += course.credit;
          if (gp > 0.0) {
            termEarned += course.credit;
          }

          // Track best attempt for overall cumulative CGPA & credits
          final key = getCourseKey(course);
          if (!bestAttemptsUpToNow.containsKey(key) || gp > (bestAttemptsUpToNow[key]!['gp'] ?? 0.0)) {
            bestAttemptsUpToNow[key] = {'gp': gp, 'credit': course.credit};
          }
        }
      }

      final termGPA = termCredits > 0 ? (termPoints / termCredits) : 0.0;

      // Cumulative progressive CGPA using best attempts of unique courses up to this trimester
      double progPoints = 0.0;
      double progCredits = 0.0;
      for (final item in bestAttemptsUpToNow.values) {
        progPoints += item['gp']! * item['credit']!;
        progCredits += item['credit']!;
      }
      final progressiveCGPA = progCredits > 0 ? (progPoints / progCredits) : 0.0;

      final totalSemCredits = sem.courses.fold(0.0, (s, c) => s + c.credit);
      updatedSemesters.add(sem.copyWith(
        creditsEarned: termEarned > 0 ? termEarned : (sem.isOngoing ? totalSemCredits : 0.0),
        sgpa: double.parse(termGPA.toStringAsFixed(2)),
        cgpa: double.parse(progressiveCGPA.toStringAsFixed(2)),
      ));
    }

    // 2. Sort descending so the most recent trimester is at the top for transcript view
    // (Spring 2023 is at the very bottom, Summer 2023 above it, Fall 2023 above that, Spring 2024 above that, etc.)
    updatedSemesters.sort((a, b) {
      final wa = getTrimesterWeight(a.semesterName);
      final wb = getTrimesterWeight(b.semesterName);
      if (wa != wb) return wb.compareTo(wa);
      return b.semesterName.compareTo(a.semesterName);
    });

    _semesters = updatedSemesters;

    if (_semesters.isNotEmpty) {
      final cum = getTranscriptCumulativeMetrics();
      _profile = _profile.copyWith(
        completedCredits: cum['credits'] ?? 0.0,
        currentCGPA: cum['cgpa'] ?? 0.0,
      );
    } else {
      _profile = _profile.copyWith(
        completedCredits: 0.0,
        currentCGPA: 0.0,
      );
    }
  }

  void _recomputeMetricsFromSemesters() {
    _sortAndRecomputeSemesters();
  }

  
  Map<String, double> getTranscriptCumulativeMetrics() {
    final bestAttempts = <String, Map<String, double>>{};
    for (final sem in _semesters) {
      for (final course in sem.courses) {
        if (course.credit <= 0) continue;
        if (course.isOngoing) continue; // Exclude ongoing courses from cumulative metrics
        final grade = course.grade?.trim().toUpperCase() ?? '';
        if (UIUGradingScale.isWithdrawn(grade)) continue; // 'W' completely excluded
        final key = getCourseKey(course);
        final gp = UIUGradingScale.isIncomplete(grade)
            ? 0.0 // 'I' counts as 0.00
            : (course.gradePoint ??
                (course.grade != null ? UIUGradingScale.getGradePoint(course.grade!) : 0.0));
        if (!bestAttempts.containsKey(key) || gp > (bestAttempts[key]!['gp'] ?? 0.0)) {
          bestAttempts[key] = {'gp': gp, 'credit': course.credit};
        }
      }
    }

    double totalPoints = 0.0;
    double totalGpaCredits = 0.0;
    double completedEarnedCredits = 0.0;

    for (final item in bestAttempts.values) {
      final gp = item['gp']!;
      final cr = item['credit']!;
      totalPoints += gp * cr;
      totalGpaCredits += cr;
      if (gp > 0.0) {
        completedEarnedCredits += cr;
      }
    }

    final cumulativeCGPA = totalGpaCredits > 0 ? (totalPoints / totalGpaCredits) : 0.0;
    return {
      'cgpa': double.parse(cumulativeCGPA.toStringAsFixed(2)),
      'credits': completedEarnedCredits,
    };
  }

  Future<void> updateProfileFromTranscript(double cgpa, double credits) async {
    final updated = _profile.copyWith(
      currentCGPA: cgpa,
      completedCredits: credits,
    );
    await saveProfile(updated);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    _profile = profile;
    _isOnboarded = true;
    await prefs.setString(_keyName, profile.name);
    await prefs.setString(_keyId, profile.studentId);
    await prefs.setString(_keyDept, profile.department);
    await prefs.setString(_keyProgram, profile.program);
    await prefs.setString(_keyBatch, profile.batch);
    await prefs.setDouble(_keyCGPA, profile.currentCGPA);
    await prefs.setDouble(_keyCompletedCredits, profile.completedCredits);
    await prefs.setDouble(_keyTotalCredits, profile.totalDegreeCredits);
    await prefs.setDouble(_keyTargetCGPA, profile.targetCGPA);
    await prefs.setBool(_keyOnboarded, true);
    notifyListeners();
  }

  Future<void> _saveSemestersToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_semesters.map((s) => s.toJson()).toList());
    await prefs.setString(_keySemesters, encoded);
    _recomputeMetricsFromSemesters();
    await prefs.setDouble(_keyCGPA, _profile.currentCGPA);
    await prefs.setDouble(_keyCompletedCredits, _profile.completedCredits);
    notifyListeners();
  }

  Future<void> addSemester(SemesterTranscript semester) async {
    final existingIndex = _semesters.indexWhere(
      (s) => s.semesterName.trim().toLowerCase() == semester.semesterName.trim().toLowerCase(),
    );
    if (existingIndex >= 0) {
      final existingCourses = List<Course>.from(_semesters[existingIndex].courses);
      for (final nc in semester.courses) {
        final cIdx = existingCourses.indexWhere(
          (c) => c.code.trim().toUpperCase() == nc.code.trim().toUpperCase(),
        );
        if (cIdx >= 0) {
          existingCourses[cIdx] = nc;
        } else {
          existingCourses.add(nc);
        }
      }
      _semesters[existingIndex] = _semesters[existingIndex].copyWith(courses: existingCourses);
    } else {
      _semesters.add(semester);
    }

    _sortAndRecomputeSemesters();
    await _saveSemestersToPrefs();
  }

  Future<void> deleteSemester(int index) async {
    if (index >= 0 && index < _semesters.length) {
      _semesters.removeAt(index);
      _sortAndRecomputeSemesters();
      await _saveSemestersToPrefs();
    }
  }

  Future<void> addCourseToSemester(String semesterName, Course course) async {
    final sIdx = _semesters.indexWhere(
      (s) => s.semesterName.trim().toLowerCase() == semesterName.trim().toLowerCase(),
    );
    if (sIdx >= 0) {
      final updatedCourses = List<Course>.from(_semesters[sIdx].courses);
      final cIdx = updatedCourses.indexWhere(
        (c) => c.code.trim().toUpperCase() == course.code.trim().toUpperCase(),
      );
      if (cIdx != -1) {
        updatedCourses[cIdx] = course;
      } else {
        updatedCourses.add(course);
      }
      _semesters[sIdx] = _semesters[sIdx].copyWith(courses: updatedCourses);
    } else {
      _semesters.add(SemesterTranscript(
        semesterName: semesterName,
        courses: [course],
        creditsEarned: course.credit,
        sgpa: course.gradePoint ?? 0.0,
        cgpa: course.gradePoint ?? 0.0,
      ));
    }
    _sortAndRecomputeSemesters();
    await _saveSemestersToPrefs();
  }

  Future<void> deleteCourse(String semesterName, Course course) async {
    final sIdx = _semesters.indexWhere(
      (s) => s.semesterName.trim().toLowerCase() == semesterName.trim().toLowerCase(),
    );
    if (sIdx >= 0) {
      final updatedCourses = List<Course>.from(_semesters[sIdx].courses);
      updatedCourses.removeWhere(
        (c) =>
            c.code.trim().toUpperCase() == course.code.trim().toUpperCase() &&
            c.title.trim().toLowerCase() == course.title.trim().toLowerCase(),
      );
      if (updatedCourses.isEmpty) {
        _semesters.removeAt(sIdx);
      } else {
        _semesters[sIdx] = _semesters[sIdx].copyWith(courses: updatedCourses);
      }
      _sortAndRecomputeSemesters();
      await _saveSemestersToPrefs();
    }
  }

  Future<void> updateCourse(String semesterName, Course oldCourse, Course updatedCourse) async {
    final sIdx = _semesters.indexWhere(
      (s) => s.semesterName.trim().toLowerCase() == semesterName.trim().toLowerCase(),
    );
    if (sIdx >= 0) {
      final updatedCourses = List<Course>.from(_semesters[sIdx].courses);
      final cIdx = updatedCourses.indexWhere(
        (c) =>
            c.code.trim().toUpperCase() == oldCourse.code.trim().toUpperCase() &&
            c.title.trim().toLowerCase() == oldCourse.title.trim().toLowerCase(),
      );
      if (cIdx >= 0) {
        updatedCourses[cIdx] = updatedCourse;
      } else {
        final codeIdx = updatedCourses.indexWhere(
          (c) => c.code.trim().toUpperCase() == oldCourse.code.trim().toUpperCase(),
        );
        if (codeIdx >= 0) {
          updatedCourses[codeIdx] = updatedCourse;
        } else {
          updatedCourses.add(updatedCourse);
        }
      }
      _semesters[sIdx] = _semesters[sIdx].copyWith(courses: updatedCourses);
      _sortAndRecomputeSemesters();
      await _saveSemestersToPrefs();
    }
  }

  String exportBackupJson() {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': _profile.toJson(),
      'semesters': _semesters.map((s) => s.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<bool> importBackupJson(String jsonStr) async {
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (decoded.containsKey('profile')) {
        final pMap = decoded['profile'] as Map<String, dynamic>;
        _profile = UserProfile.fromJson(pMap);
        _isOnboarded = true;
      }
      if (decoded.containsKey('semesters')) {
        final semList = decoded['semesters'] as List<dynamic>;
        final incomingSemesters = semList
            .map((s) => SemesterTranscript.fromJson(s as Map<String, dynamic>))
            .toList();

        // Merge incoming semesters with existing ones
        for (final inc in incomingSemesters) {
          final existingIdx = _semesters.indexWhere(
            (s) => s.semesterName.trim().toLowerCase() == inc.semesterName.trim().toLowerCase(),
          );
          if (existingIdx >= 0) {
            final mergedCourses = List<Course>.from(_semesters[existingIdx].courses);
            for (final nc in inc.courses) {
              final cIdx = mergedCourses.indexWhere(
                (c) => c.code.trim().toUpperCase() == nc.code.trim().toUpperCase(),
              );
              if (cIdx >= 0) {
                mergedCourses[cIdx] = nc;
              } else {
                mergedCourses.add(nc);
              }
            }
            _semesters[existingIdx] = _semesters[existingIdx].copyWith(courses: mergedCourses);
          } else {
            _semesters.add(inc);
          }
        }
      }
      await saveProfile(_profile);
      await _saveSemestersToPrefs();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Imports multi-trimester content (CSV, PDF text, OCR) by auto-detecting trimester headers or columns.
  /// Imports multi-trimester content (CSV, PDF text, OCR) by auto-detecting trimester headers or columns.
  /// Automatically creates and groups courses into their respective trimesters according to UIU order.
  Future<Map<String, int>> importMultiTrimesterContent(String defaultTerm, String content) async {
    final trimestersMap = <String, List<Course>>{};

    // Determine the baseline running trimester for this import session
    String sessionRunningTrimester = '';
    if (_semesters.isNotEmpty) {
      final ongoingExisting = _semesters.where((s) => s.isOngoing).toList();
      if (ongoingExisting.isNotEmpty) {
        sessionRunningTrimester = ongoingExisting.first.semesterName;
      } else {
        sessionRunningTrimester = getNextTrimester(_semesters.first.semesterName);
      }
    } else {
      sessionRunningTrimester = detectTrimester(defaultTerm) ?? getDynamicDefaultTrimester();
    }

    String currentTerm = detectTrimester(defaultTerm) ?? sessionRunningTrimester;
    String? lastGradedTerm; // Tracks the most recent trimester with graded courses in this import

    final lines = content.split(RegExp(r'\r?\n'));
    final codeRegex = RegExp(r'^[A-Za-z]{2,5}\s*[-]?\s*\d{3,4}[A-Za-z]?$', caseSensitive: false);
    final gradeRegex = RegExp(r'^(A|A-|B\+|B|B-|C\+|C|C-|D\+|D|F|W|I)$', caseSensitive: false);

    bool isOngoingGrade(String str) {
      final s = str.trim().toLowerCase();
      return s.isEmpty ||
          s == 'running' ||
          s == 'running course' ||
          s == 'ongoing' ||
          s == 'in progress' ||
          s == 'enrolled' ||
          s == 'registered' ||
          s == 'current' ||
          s == 'current course' ||
          s == 'ip' ||
          s == 'tbd' ||
          s == 'n/a' ||
          s == 'na' ||
          s == '-' ||
          s == '--' ||
          s.contains('running') ||
          s.contains('ongoing') ||
          s.contains('progress') ||
          s.contains('enrolled') ||
          s.contains('registered');
    }

    String cleanCourseTitle(String rawTitle) {
      return rawTitle
          .replaceAll(RegExp(r'[\(\[]?\s*(?:running(?:\s*course)?|ongoing|enrolled|registered|current(?:\s*course)?)\s*[\)\]]?', caseSensitive: false), '')
          .trim();
    }

    // Graded: CSE 1111 Structured Programming 3.00 A (or W, I)
    final spaceCourseRegex = RegExp(
      r'([A-Za-z]{2,5}\s*\d{3,4}[A-Za-z]?)\s+(.+?)\s+([0-9.]+)\s+([A-D][+-]?|F|W|I)\b',
      caseSensitive: false,
    );

    // Graded with points after or before: e.g. CSE 1111 SPL 3.00 4.00 A  OR  CSE 1111 SPL 3.00 A 4.00
    final spaceCourseGradePointRegex = RegExp(
      r'([A-Za-z]{2,5}\s*\d{3,4}[A-Za-z]?)\s+(.+?)\s+([0-9.]+)\s+(?:([A-D][+-]?|F|W|I)\s+[0-9.]+|[0-9.]+\s+([A-D][+-]?|F|W|I))\b',
      caseSensitive: false,
    );

    // Explicit Ongoing: CSE 4325 Microprocessors 3.00 Ongoing or Running Course
    final spaceOngoingWithKeywordRegex = RegExp(
      r'([A-Za-z]{2,5}\s*\d{3,4}[A-Za-z]?)\s+(.+?)\s+([0-9.]+)\s+(?:[-–—]|n/?a|tbd|ip|(?:\(?\s*(?:running(?:\s*course)?|ongoing|in\s*progress|enrolled|registered|current(?:\s*course)?)\s*\)?))\s*$',
      caseSensitive: false,
    );

    // Ongoing course without grade at end of line: CSE 1111 Structured Programming 3.00
    final spaceOngoingRegex = RegExp(
      r'([A-Za-z]{2,5}\s*\d{3,4}[A-Za-z]?)\s+(.+?)\s+([0-9.]+)\s*$',
      caseSensitive: false,
    );

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // 1. Check for Running / Ongoing Trimester header (e.g. "Running Trimester:", "Current Courses:", "Running Courses:")
      final isRunningHeader = RegExp(
        r'^\s*(?:#+\s*)?(?:running|current|ongoing|currently\s+enrolled|enrolled)\s*(?:trimester|semester|term|courses?)?\s*:?\s*$',
        caseSensitive: false,
      ).hasMatch(line);

      if (isRunningHeader) {
        currentTerm = lastGradedTerm != null ? getNextTrimester(lastGradedTerm) : sessionRunningTrimester;
        continue;
      }

      // Check if line contains an explicit trimester mention (e.g. "Spring 2024", "Fall 2025")
      final lineTrimester = detectTrimester(line);
      final hasGrade = gradeRegex.hasMatch(line) || spaceCourseRegex.hasMatch(line) || spaceCourseGradePointRegex.hasMatch(line);
      final isHeaderKeyword = RegExp(r'(trimester|semester|term|academic year)', caseSensitive: false).hasMatch(line);

      // If this line indicates a trimester header, switch currentTerm
      if (lineTrimester != null && (isHeaderKeyword || !hasGrade || line.length < 45)) {
        currentTerm = lineTrimester;
        if (!hasGrade && !line.contains(',')) {
          continue;
        }
      }

      // 2. CSV / Tab-separated row
      if (line.contains(',') || line.contains('\t')) {
        final rawParts = line
            .split(RegExp(r'[,\t]'))
            .map((s) => s.replaceAll('"', '').trim())
            .toList();

        if (rawParts.where((s) => s.isNotEmpty).length >= 2) {
          String rowTerm = currentTerm;

          // Check if any column contains a trimester name or running keyword
          int termColIdx = -1;
          for (int i = 0; i < rawParts.length; i++) {
            final p = rawParts[i];
            if (p.isEmpty) continue;
            if (RegExp(r'^(?:running|current|ongoing|enrolled)(?:\s*(?:trimester|term))?$', caseSensitive: false).hasMatch(p)) {
              rowTerm = lastGradedTerm != null ? getNextTrimester(lastGradedTerm) : sessionRunningTrimester;
              currentTerm = rowTerm;
              termColIdx = i;
              break;
            }
            final detected = detectTrimester(p);
            if (detected != null) {
              rowTerm = detected;
              currentTerm = detected;
              termColIdx = i;
              break;
            }
          }
          if (termColIdx != -1) {
            rawParts.removeAt(termColIdx);
          }

          final nonEmpties = rawParts.where((s) => s.isNotEmpty).toList();
          if (nonEmpties.length < 2) continue;

          // Skip header rows like "Course Code, Title, Credit, Grade"
          if (nonEmpties[0].toLowerCase().contains('code') || nonEmpties[0].toLowerCase().contains('course')) {
            continue;
          }

          String code = '';
          String title = '';
          double cr = 3.0;
          String gr = '';

          int codeIdx = -1;
          int gradeIdx = -1;
          int creditIdx = -1;

          for (int i = 0; i < rawParts.length; i++) {
            final p = rawParts[i];
            if (codeIdx == -1 && codeRegex.hasMatch(p)) {
              codeIdx = i;
            } else if (creditIdx == -1) {
              final d = double.tryParse(p);
              if (d != null && d > 0 && d <= 9.0) {
                creditIdx = i;
              }
            } else if (gradeIdx == -1 && (gradeRegex.hasMatch(p) || isOngoingGrade(p))) {
              gradeIdx = i;
            }
          }

          if (codeIdx != -1) {
            code = rawParts[codeIdx].toUpperCase();
            if (creditIdx != -1) {
              cr = double.tryParse(rawParts[creditIdx]) ?? 3.0;
            }
            if (gradeIdx != -1) {
              gr = rawParts[gradeIdx].toUpperCase();
            } else {
              // Search after credit/code for empty or ongoing indicator column
              final afterIdx = (creditIdx > codeIdx ? creditIdx : codeIdx);
              if (rawParts.length > afterIdx + 1) {
                gr = rawParts[afterIdx + 1].toUpperCase();
              }
            }

            final titleParts = <String>[];
            for (int i = 0; i < rawParts.length; i++) {
              if (i != codeIdx && i != gradeIdx && i != creditIdx) {
                if (rawParts[i].isNotEmpty && int.tryParse(rawParts[i]) == null) {
                  titleParts.add(rawParts[i]);
                }
              }
            }
            title = titleParts.isNotEmpty ? titleParts.join(' ') : code;
          } else {
            code = nonEmpties[0];
            title = nonEmpties.length >= 3 ? nonEmpties[1] : code;
            cr = double.tryParse(nonEmpties.length >= 3 ? nonEmpties[2] : nonEmpties[1]) ?? 3.0;
            gr = nonEmpties.length >= 4 ? nonEmpties[3].toUpperCase() : '';
          }

          final lineHasRunningCourse = RegExp(r'\b(?:running(?:\s*course)?|ongoing|enrolled|registered)\b', caseSensitive: false).hasMatch(line);
          final isOngoingCourse = isOngoingGrade(gr) || lineHasRunningCourse;
          final isGradeValid = UIUGradingScale.isValidGrade(gr) || gr == 'F' || gr == 'W' || gr == 'I';

          if (code.isNotEmpty && (isGradeValid || isOngoingCourse)) {
            final double? gp = (isOngoingCourse || gr == 'W') ? null : UIUGradingScale.getGradePoint(gr);
            final cleanTitle = cleanCourseTitle(title);

            // If this is an ongoing/running course, but rowTerm was a past completed trimester:
            String targetTerm = rowTerm;
            if (isOngoingCourse) {
              if (trimestersMap.containsKey(rowTerm) && trimestersMap[rowTerm]!.any((c) => !c.isOngoing)) {
                targetTerm = getNextTrimester(rowTerm);
              } else if (lastGradedTerm != null && rowTerm == lastGradedTerm) {
                targetTerm = getNextTrimester(lastGradedTerm);
              }
            } else {
              lastGradedTerm = rowTerm;
            }

            trimestersMap.putIfAbsent(targetTerm, () => []);
            trimestersMap[targetTerm]!.add(Course(
              code: code,
              title: cleanTitle.isEmpty ? code : cleanTitle,
              credit: cr,
              grade: isOngoingCourse ? null : gr,
              gradePoint: gp,
            ));
            continue;
          }
        }
      }

      // 3. Space-separated format:
      final lineHasRunningKeyword = RegExp(r'\b(?:running(?:\s*course)?|ongoing|enrolled|registered)\b', caseSensitive: false).hasMatch(line);

      // A) Graded with Grade & Points: CSE 1111 SPL 3.00 4.00 A OR CSE 1111 SPL 3.00 A 4.00
      final sgpMatch = spaceCourseGradePointRegex.firstMatch(line);
      if (sgpMatch != null && !lineHasRunningKeyword) {
        final code = sgpMatch.group(1)!.trim().toUpperCase();
        final title = cleanCourseTitle(sgpMatch.group(2)!.trim());
        final cr = double.tryParse(sgpMatch.group(3)!) ?? 3.0;
        final gr = (sgpMatch.group(4) ?? sgpMatch.group(5) ?? '').toUpperCase();
        final gp = (gr == 'W' || gr.isEmpty) ? null : UIUGradingScale.getGradePoint(gr);

        lastGradedTerm = currentTerm;
        trimestersMap.putIfAbsent(currentTerm, () => []);
        trimestersMap[currentTerm]!.add(Course(
          code: code,
          title: title.isEmpty ? code : title,
          credit: cr,
          grade: gr,
          gradePoint: gp,
        ));
        continue;
      }

      // B) Graded: CSE 1111 Structured Programming 3.00 A
      final sMatch = spaceCourseRegex.firstMatch(line);
      if (sMatch != null && !lineHasRunningKeyword) {
        final code = sMatch.group(1)!.trim().toUpperCase();
        final title = cleanCourseTitle(sMatch.group(2)!.trim());
        final cr = double.tryParse(sMatch.group(3)!) ?? 3.0;
        final gr = sMatch.group(4)!.toUpperCase();
        final gp = (gr == 'W' || gr.isEmpty) ? null : UIUGradingScale.getGradePoint(gr);

        lastGradedTerm = currentTerm;
        trimestersMap.putIfAbsent(currentTerm, () => []);
        trimestersMap[currentTerm]!.add(Course(
          code: code,
          title: title.isEmpty ? code : title,
          credit: cr,
          grade: gr,
          gradePoint: gp,
        ));
        continue;
      }

      // C) Explicit ongoing course keyword (e.g. "Running Course", "Ongoing", "Enrolled", "-"):
      final sExpMatch = spaceOngoingWithKeywordRegex.firstMatch(line);
      if (sExpMatch != null || (lineHasRunningKeyword && spaceOngoingRegex.firstMatch(line) != null)) {
        final match = sExpMatch ?? spaceOngoingRegex.firstMatch(line)!;
        final code = match.group(1)!.trim().toUpperCase();
        final title = cleanCourseTitle(match.group(2)!.trim());
        final cr = double.tryParse(match.group(3)!) ?? 3.0;

        String targetTerm = currentTerm;
        if (trimestersMap.containsKey(currentTerm) && trimestersMap[currentTerm]!.any((c) => !c.isOngoing)) {
          targetTerm = getNextTrimester(currentTerm);
        } else if (lastGradedTerm != null && currentTerm == lastGradedTerm) {
          targetTerm = getNextTrimester(lastGradedTerm);
        }

        trimestersMap.putIfAbsent(targetTerm, () => []);
        trimestersMap[targetTerm]!.add(Course(
          code: code,
          title: title.isEmpty ? code : title,
          credit: cr,
          grade: null,
          gradePoint: null,
        ));
        continue;
      }

      // D) Ongoing course without grade at end of line: CSE 1111 Structured Programming 3.00
      final sOngoingMatch = spaceOngoingRegex.firstMatch(line);
      if (sOngoingMatch != null) {
        final code = sOngoingMatch.group(1)!.trim().toUpperCase();
        final title = cleanCourseTitle(sOngoingMatch.group(2)!.trim());
        final cr = double.tryParse(sOngoingMatch.group(3)!) ?? 3.0;

        String targetTerm = currentTerm;
        if (trimestersMap.containsKey(currentTerm) && trimestersMap[currentTerm]!.any((c) => !c.isOngoing)) {
          targetTerm = getNextTrimester(currentTerm);
        } else if (lastGradedTerm != null && currentTerm == lastGradedTerm) {
          targetTerm = getNextTrimester(lastGradedTerm);
        }

        trimestersMap.putIfAbsent(targetTerm, () => []);
        trimestersMap[targetTerm]!.add(Course(
          code: code,
          title: title.isEmpty ? code : title,
          credit: cr,
          grade: null,
          gradePoint: null,
        ));
      }
    }

    if (trimestersMap.isEmpty) {
      return {'courses': 0, 'trimesters': 0};
    }

    int totalCourses = 0;
    trimestersMap.forEach((term, newCourses) {
      totalCourses += newCourses.length;
      final existingIndex = _semesters.indexWhere(
        (s) => s.semesterName.trim().toLowerCase() == term.trim().toLowerCase(),
      );

      if (existingIndex >= 0) {
        final existingCourses = List<Course>.from(_semesters[existingIndex].courses);
        for (final nc in newCourses) {
          final cIdx = existingCourses.indexWhere(
            (c) => c.code.trim().toUpperCase() == nc.code.trim().toUpperCase(),
          );
          if (cIdx >= 0) {
            existingCourses[cIdx] = nc;
          } else {
            existingCourses.add(nc);
          }
        }
        _semesters[existingIndex] = _semesters[existingIndex].copyWith(courses: existingCourses);
      } else {
        _semesters.add(SemesterTranscript(
          semesterName: term,
          courses: newCourses,
          creditsEarned: 0,
          sgpa: 0,
          cgpa: 0,
        ));
      }
    });

    _sortAndRecomputeSemesters();
    await _saveSemestersToPrefs();

    return {'courses': totalCourses, 'trimesters': trimestersMap.length};
  }

  Future<bool> importCsvCourses(String semesterName, String csv) async {
    final res = await importMultiTrimesterContent(semesterName, csv);
    return (res['courses'] ?? 0) > 0;
  }

  Future<void> updateCGPAData({
    required double currentCGPA,
    required double completedCredits,
    required double targetCGPA,
  }) async {
    await saveProfile(_profile.copyWith(
      currentCGPA: currentCGPA,
      completedCredits: completedCredits,
      targetCGPA: targetCGPA,
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
