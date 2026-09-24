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
    totalDegreeCredits: 138.0,
    targetCGPA: 3.75,
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
        totalDegreeCredits: prefs.getDouble(_keyTotalCredits) ?? 138.0,
        targetCGPA: prefs.getDouble(_keyTargetCGPA) ?? 3.75,
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

  void _recomputeMetricsFromSemesters() {
    if (_semesters.isEmpty) return;

    double totalPoints = 0.0;
    double totalCredits = 0.0;

    for (final sem in _semesters) {
      for (final course in sem.courses) {
        final gp = course.gradePoint ?? (course.grade != null ? UIUGradingScale.getGradePoint(course.grade!) : null);
        if (gp != null && course.credit > 0) {
          totalPoints += (gp * course.credit);
          totalCredits += course.credit;
        }
      }
    }

    if (totalCredits > 0) {
      final calculatedCGPA = totalPoints / totalCredits;
      _profile = _profile.copyWith(
        currentCGPA: double.parse(calculatedCGPA.toStringAsFixed(2)),
        completedCredits: totalCredits,
      );
    }
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
    _semesters.insert(0, semester);
    await _saveSemestersToPrefs();
  }

  Future<void> deleteSemester(int index) async {
    if (index >= 0 && index < _semesters.length) {
      _semesters.removeAt(index);
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
        _semesters = semList
            .map((s) => SemesterTranscript.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      await saveProfile(_profile);
      await _saveSemestersToPrefs();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> importCsvCourses(String semesterName, String csv) async {
    try {
      final lines = csv.split('\n');
      final courses = <Course>[];
      double semCredits = 0.0;
      double semPoints = 0.0;

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;
        final parts = line.split(',');
        if (parts.length >= 3) {
          final code = parts[0].trim();
          final title = parts.length >= 4 ? parts[1].trim() : code;
          final creditStr = parts.length >= 4 ? parts[2].trim() : parts[1].trim();
          final gradeStr = parts.length >= 4 ? parts[3].trim().toUpperCase() : parts[2].trim().toUpperCase();

          final credit = double.tryParse(creditStr) ?? 3.0;
          final gp = UIUGradingScale.getGradePoint(gradeStr);

          courses.add(Course(
            code: code,
            title: title,
            credit: credit,
            grade: gradeStr,
            gradePoint: gp,
          ));

          semCredits += credit;
          semPoints += (gp * credit);
        }
      }

      if (courses.isEmpty) return false;

      final semGPA = semCredits > 0 ? (semPoints / semCredits) : 0.0;
      final newSem = SemesterTranscript(
        semesterName: semesterName,
        courses: courses,
        creditsEarned: semCredits,
        sgpa: double.parse(semGPA.toStringAsFixed(2)),
        cgpa: double.parse(semGPA.toStringAsFixed(2)),
      );

      await addSemester(newSem);
      return true;
    } catch (_) {
      return false;
    }
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
