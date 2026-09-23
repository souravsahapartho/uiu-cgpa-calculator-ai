import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Official United International University (UIU) Grading Scale & Policy
class UIUGradingItem {
  final String grade;
  final double gradePoint;
  final String markRange;
  final String remarks;
  final Color color;

  const UIUGradingItem({
    required this.grade,
    required this.gradePoint,
    required this.markRange,
    required this.remarks,
    required this.color,
  });
}

class UIUGradingScale {
  static const List<UIUGradingItem> scale = [
    UIUGradingItem(
      grade: 'A',
      gradePoint: 4.00,
      markRange: '90 - 100',
      remarks: 'Plain',
      color: AppColors.success,
    ),
    UIUGradingItem(
      grade: 'A-',
      gradePoint: 3.67,
      markRange: '86 - 89',
      remarks: 'Minus',
      color: Color(0xFF059669),
    ),
    UIUGradingItem(
      grade: 'B+',
      gradePoint: 3.33,
      markRange: '82 - 85',
      remarks: 'Plus',
      color: Color(0xFF0284C7),
    ),
    UIUGradingItem(
      grade: 'B',
      gradePoint: 3.00,
      markRange: '78 - 81',
      remarks: 'Plain',
      color: Color(0xFF2563EB),
    ),
    UIUGradingItem(
      grade: 'B-',
      gradePoint: 2.67,
      markRange: '74 - 77',
      remarks: 'Minus',
      color: AppColors.secondary,
    ),
    UIUGradingItem(
      grade: 'C+',
      gradePoint: 2.33,
      markRange: '70 - 73',
      remarks: 'Plus',
      color: Color(0xFFD97706),
    ),
    UIUGradingItem(
      grade: 'C',
      gradePoint: 2.00,
      markRange: '66 - 69',
      remarks: 'Plain',
      color: AppColors.warning,
    ),
    UIUGradingItem(
      grade: 'C-',
      gradePoint: 1.67,
      markRange: '62 - 65',
      remarks: 'Minus',
      color: Color(0xFFEA580C),
    ),
    UIUGradingItem(
      grade: 'D+',
      gradePoint: 1.33,
      markRange: '58 - 61',
      remarks: 'Plus',
      color: Color(0xFFDC2626),
    ),
    UIUGradingItem(
      grade: 'D',
      gradePoint: 1.00,
      markRange: '55 - 57',
      remarks: 'Plain',
      color: Color(0xFFB91C1C),
    ),
    UIUGradingItem(
      grade: 'F',
      gradePoint: 0.00,
      markRange: '0 - 54',
      remarks: 'Fail',
      color: AppColors.error,
    ),
  ];

  static double getGradePoint(String grade) {
    for (var item in scale) {
      if (item.grade.toUpperCase() == grade.toUpperCase()) {
        return item.gradePoint;
      }
    }
    return 0.0;
  }

  static Color getGradeColor(String grade) {
    for (var item in scale) {
      if (item.grade.toUpperCase() == grade.toUpperCase()) {
        return item.color;
      }
    }
    return AppColors.textSecondary;
  }

  static String getGradeFromPoint(double point) {
    if (point >= 3.85) return 'A';
    if (point >= 3.50) return 'A-';
    if (point >= 3.15) return 'B+';
    if (point >= 2.85) return 'B';
    if (point >= 2.50) return 'B-';
    if (point >= 2.15) return 'C+';
    if (point >= 1.85) return 'C';
    if (point >= 1.50) return 'C-';
    if (point >= 1.15) return 'D+';
    if (point >= 0.85) return 'D';
    return 'F';
  }

  static String getGradeFromMarks(double marks) {
    if (marks >= 90) return 'A';
    if (marks >= 86) return 'A-';
    if (marks >= 82) return 'B+';
    if (marks >= 78) return 'B';
    if (marks >= 74) return 'B-';
    if (marks >= 70) return 'C+';
    if (marks >= 66) return 'C';
    if (marks >= 62) return 'C-';
    if (marks >= 58) return 'D+';
    if (marks >= 55) return 'D';
    return 'F';
  }
}
