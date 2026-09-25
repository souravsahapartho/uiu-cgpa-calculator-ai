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

  static int getTrimesterWeight(String name) {
    if (name.isEmpty) return 0;
    final exp = RegExp(r'(spring|summer|fall)\s*(\d{4})', caseSensitive: false);
    final match = exp.firstMatch(name);
    if (match != null) {
      final season = match.group(1)!.toLowerCase();
      final year = int.tryParse(match.group(2)!) ?? 0;
      int seasonOrder = 1;
      if (season == 'spring') {
        seasonOrder = 1;
      } else if (season == 'summer') {
        seasonOrder = 2;
      } else if (season == 'fall') {
        seasonOrder = 3;
      }
      return year * 10 + seasonOrder;
    }
    final shortExp = RegExp(r"(spring|summer|fall)\s*'?(\d{2})\b", caseSensitive: false);
    final shortMatch = shortExp.firstMatch(name);
    if (shortMatch != null) {
      final season = shortMatch.group(1)!.toLowerCase();
      int year = int.tryParse(shortMatch.group(2)!) ?? 0;
      year = year < 50 ? 2000 + year : 1900 + year;
      int seasonOrder = season == 'spring' ? 1 : (season == 'summer' ? 2 : 3);
      return year * 10 + seasonOrder;
    }
    return 0;
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

    double runningPoints = 0.0;
    double runningCredits = 0.0;

    final updatedSemesters = <SemesterTranscript>[];

    for (final sem in _semesters) {
      double termPoints = 0.0;
      double termCredits = 0.0;

      for (final course in sem.courses) {
        final gp = course.gradePoint ?? (course.grade != null ? UIUGradingScale.getGradePoint(course.grade!) : 0.0);
        if (course.credit > 0) {
          termPoints += (gp * course.credit);
          termCredits += course.credit;
        }
      }

      final termGPA = termCredits > 0 ? (termPoints / termCredits) : 0.0;
      runningPoints += termPoints;
      runningCredits += termCredits;
      final progressiveCGPA = runningCredits > 0 ? (runningPoints / runningCredits) : 0.0;

      updatedSemesters.add(sem.copyWith(
        creditsEarned: termCredits,
        sgpa: double.parse(termGPA.toStringAsFixed(2)),
        cgpa: double.parse(progressiveCGPA.toStringAsFixed(2)),
      ));
    }

    // 2. Sort descending so the most recent trimester is at the top for transcript view
    updatedSemesters.sort((a, b) {
      final wa = getTrimesterWeight(a.semesterName);
      final wb = getTrimesterWeight(b.semesterName);
      if (wa != wb) return wb.compareTo(wa);
      return b.semesterName.compareTo(a.semesterName);
    });

    _semesters = updatedSemesters;

    if (runningCredits > 0) {
      final cumulativeCGPA = runningPoints / runningCredits;
      _profile = _profile.copyWith(
        currentCGPA: double.parse(cumulativeCGPA.toStringAsFixed(2)),
        completedCredits: runningCredits,
      );
    }
  }

  void _recomputeMetricsFromSemesters() {
    _sortAndRecomputeSemesters();
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

  /// Imports multi-trimester content (CSV, PDF text, OCR) by auto-detecting trimester headers or columns.
  /// Automatically creates and groups courses into their respective trimesters according to UIU order.
  Future<Map<String, int>> importMultiTrimesterContent(String defaultTerm, String content) async {
    final trimestersMap = <String, List<Course>>{};
    String currentTerm = defaultTerm.trim().isEmpty ? 'Spring 2024' : defaultTerm.trim();

    final lines = content.split(RegExp(r'\r?\n'));
    final headerRegex = RegExp(r'^(?:trimester|semester|term)?\s*[:\-]?\s*(spring|summer|fall)\s*(\d{4})', caseSensitive: false);
    final rowTermRegex = RegExp(r'^(spring|summer|fall)\s*(\d{4})$', caseSensitive: false);
    final spaceCourseRegex = RegExp(r'^([A-Za-z]{2,5}\s*\d{3,4})\s+(.+?)\s+([0-9.]+)\s+([A-D][+-]?|F)\b', caseSensitive: false);

    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // 1. Check if line is an explicit header e.g. "Spring 2022" or "Trimester: Summer 2023"
      if (line.length < 35 && !line.contains(',')) {
        final hMatch = headerRegex.firstMatch(line);
        if (hMatch != null) {
          final season = hMatch.group(1)![0].toUpperCase() + hMatch.group(1)!.substring(1).toLowerCase();
          final yr = hMatch.group(2)!;
          currentTerm = '$season $yr';
          continue;
        }
      }

      // 2. CSV / Tab-separated row
      if (line.contains(',') || line.contains('\t')) {
        final parts = line.split(RegExp(r'[,\t]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        if (parts.length >= 3) {
          String rowTerm = currentTerm;
          String code = '';
          String title = '';
          double cr = 3.0;
          String gr = 'A';

          if (rowTermRegex.hasMatch(parts[0])) {
            final m = rowTermRegex.firstMatch(parts[0])!;
            final s = m.group(1)![0].toUpperCase() + m.group(1)!.substring(1).toLowerCase();
            rowTerm = '$s ${m.group(2)}';
            code = parts[1];
            title = parts.length >= 4 ? parts[2] : code;
            if (parts.length >= 5) {
              cr = double.tryParse(parts[3]) ?? 3.0;
              gr = parts[4].toUpperCase();
            } else if (parts.length == 4) {
              if (double.tryParse(parts[2]) != null) {
                cr = double.tryParse(parts[2]) ?? 3.0;
                gr = parts[3].toUpperCase();
                title = code;
              } else {
                title = parts[2];
                gr = parts[3].toUpperCase();
              }
            }
          } else if (rowTermRegex.hasMatch(parts.last)) {
            final m = rowTermRegex.firstMatch(parts.last)!;
            final s = m.group(1)![0].toUpperCase() + m.group(1)!.substring(1).toLowerCase();
            rowTerm = '$s ${m.group(2)}';
            code = parts[0];
            title = parts.length >= 4 ? parts[1] : code;
            cr = double.tryParse(parts.length >= 4 ? parts[2] : '') ?? 3.0;
            gr = (parts.length >= 5 ? parts[3] : parts[parts.length - 2]).toUpperCase();
          } else {
            code = parts[0];
            title = parts.length >= 4 ? parts[1] : code;
            cr = double.tryParse(parts.length >= 4 ? parts[2] : parts[1]) ?? 3.0;
            gr = (parts.length >= 4 ? parts[3] : parts[2]).toUpperCase();
          }

          final gp = UIUGradingScale.getGradePoint(gr);
          if (code.isNotEmpty) {
            trimestersMap.putIfAbsent(rowTerm, () => []);
            trimestersMap[rowTerm]!.add(Course(
              code: code,
              title: title,
              credit: cr,
              grade: gr,
              gradePoint: gp,
            ));
            continue;
          }
        }
      }

      // 3. Space-separated format: CSE 1111 Structured Programming 3.00 A
      final sMatch = spaceCourseRegex.firstMatch(line);
      if (sMatch != null) {
        final code = sMatch.group(1)!.trim();
        final title = sMatch.group(2)!.trim();
        final cr = double.tryParse(sMatch.group(3)!) ?? 3.0;
        final gr = sMatch.group(4)!.toUpperCase();
        final gp = UIUGradingScale.getGradePoint(gr);

        trimestersMap.putIfAbsent(currentTerm, () => []);
        trimestersMap[currentTerm]!.add(Course(
          code: code,
          title: title,
          credit: cr,
          grade: gr,
          gradePoint: gp,
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
