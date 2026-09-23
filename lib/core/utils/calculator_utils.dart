import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum GPAFeasibility {
  alreadyAchieved,
  easilyAchieved,
  moderatelyChallenging,
  highlyDemanding,
  impossible,
  invalidInput,
}

class RequiredGPAResult {
  final double requiredGPA;
  final GPAFeasibility feasibility;
  final String message;
  final Color statusColor;

  const RequiredGPAResult({
    required this.requiredGPA,
    required this.feasibility,
    required this.message,
    required this.statusColor,
  });
}

class CalculatorUtils {
  /// Calculate Required GPA to reach Target CGPA
  static RequiredGPAResult calculateRequiredGPA({
    required double currentCGPA,
    required double completedCredits,
    required double targetCGPA,
    required double remainingCredits,
  }) {
    if (completedCredits < 0 || remainingCredits <= 0 || targetCGPA <= 0) {
      return const RequiredGPAResult(
        requiredGPA: 0.0,
        feasibility: GPAFeasibility.invalidInput,
        message: 'Please enter valid credits and target CGPA',
        statusColor: AppColors.textTertiary,
      );
    }

    final totalCredits = completedCredits + remainingCredits;
    final targetQualityPoints = targetCGPA * totalCredits;
    final currentQualityPoints = currentCGPA * completedCredits;
    final requiredQualityPoints = targetQualityPoints - currentQualityPoints;
    final requiredGPA = requiredQualityPoints / remainingCredits;

    if (requiredGPA <= 0) {
      return RequiredGPAResult(
        requiredGPA: 0.00,
        feasibility: GPAFeasibility.alreadyAchieved,
        message: 'You have already surpassed this target! Keep it up.',
        statusColor: AppColors.success,
      );
    } else if (requiredGPA <= 3.30) {
      return RequiredGPAResult(
        requiredGPA: requiredGPA,
        feasibility: GPAFeasibility.easilyAchieved,
        message: 'Easily attainable with consistent performance (B/B+ average).',
        statusColor: AppColors.success,
      );
    } else if (requiredGPA <= 3.75) {
      return RequiredGPAResult(
        requiredGPA: requiredGPA,
        feasibility: GPAFeasibility.moderatelyChallenging,
        message: 'Challenging but reachable with solid focus (A-/A average).',
        statusColor: AppColors.secondary,
      );
    } else if (requiredGPA <= 4.00) {
      return RequiredGPAResult(
        requiredGPA: requiredGPA,
        feasibility: GPAFeasibility.highlyDemanding,
        message: 'Extremely demanding! Requires near straight 4.00s (A grades).',
        statusColor: AppColors.warning,
      );
    } else {
      return RequiredGPAResult(
        requiredGPA: requiredGPA,
        feasibility: GPAFeasibility.impossible,
        message: 'Mathematically unreachable (> 4.00 max GPA limit). Adjust target or retake courses.',
        statusColor: AppColors.error,
      );
    }
  }

  /// Calculate Semester GPA (SGPA)
  static double calculateSGPA(List<Map<String, dynamic>> courses) {
    if (courses.isEmpty) return 0.0;
    double totalQualityPoints = 0.0;
    double totalCredits = 0.0;

    for (var course in courses) {
      final double credit = (course['credit'] as num?)?.toDouble() ?? 0.0;
      final double gradePoint = (course['gradePoint'] as num?)?.toDouble() ?? 0.0;
      totalQualityPoints += (credit * gradePoint);
      totalCredits += credit;
    }

    if (totalCredits == 0) return 0.0;
    return totalQualityPoints / totalCredits;
  }

  /// UIU Distinction Level
  static String getGraduationDistinction(double cgpa) {
    if (cgpa >= 3.90) return 'Summa Cum Laude (Highest Distinction)';
    if (cgpa >= 3.75) return 'Magna Cum Laude (High Distinction)';
    if (cgpa >= 3.50) return 'Cum Laude (Distinction)';
    if (cgpa >= 3.00) return 'Second Class (Upper)';
    if (cgpa >= 2.00) return 'Passing Standing';
    return 'Academic Probation';
  }
}

