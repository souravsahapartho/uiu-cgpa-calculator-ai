class StudentProfile {
  final String name;
  final String studentId;
  final String department;
  final String program;
  final String batch;
  final double currentCGPA;
  final double completedCredits;
  final double totalDegreeCredits;
  final double targetCGPA;
  final String advisorName;
  final String advisorEmail;
  final String currentTrimester;
  final String lastBackupTime;

  const StudentProfile({
    required this.name,
    required this.studentId,
    required this.department,
    required this.program,
    required this.batch,
    required this.currentCGPA,
    required this.completedCredits,
    required this.totalDegreeCredits,
    required this.targetCGPA,
    required this.advisorName,
    required this.advisorEmail,
    required this.currentTrimester,
    required this.lastBackupTime,
  });

  double get remainingCredits => (totalDegreeCredits - completedCredits).clamp(0.0, totalDegreeCredits);
  double get progressPercentage => (completedCredits / totalDegreeCredits).clamp(0.0, 1.0);
}

