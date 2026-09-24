import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Extracts UIU batch from student ID.
/// UIU ID format: 011BBBNNNN where BBB = batch (3 digits at positions 3-5, 0-indexed)
/// e.g. 0112330538 → batch 233, 0112520445 → batch 252
String extractBatchFromId(String id) {
  var digits = id.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 9 && digits.startsWith('11')) {
    digits = '0$digits';
  }
  if (digits.length >= 6 && digits.startsWith('011')) {
    return digits.substring(3, 6);
  } else if (digits.length >= 7) {
    return digits.substring(3, 6);
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
      (completedCredits / totalDegreeCredits).clamp(0.0, 1.0);

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

  bool _isOnboarded = false;
  ThemeMode _themeMode = ThemeMode.light;

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
    notifyListeners();
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
