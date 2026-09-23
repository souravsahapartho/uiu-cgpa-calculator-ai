# UIU CGPA Calculator AI - Academic & CGPA Intelligence (Android)

**UIU CGPA Calculator AI** is a production-grade, Google Play Store ready Android mobile application crafted specifically for students of **United International University (UIU)**.

Built with a warm, authentic academic design system inspired by UIU branding, Material 3 components, 18–24px rounded corners, responsive layout architecture, and complete local privacy.

---

## 🎨 Design System & Palette

- **Primary**: UIU Orange (`#F57C00` / `#FF9800`)
- **Secondary**: Warm Amber (`#FFA000`)
- **Accent**: Deep Academic Navy (`#0D1B2A` / `#1B2A4A`)
- **Background**: Soft Off-White Slate (`#F8FAFC`)
- **Card Surfaces**: Pure White (`#FFFFFF`) with 1px border and soft depth
- **Success**: Emerald (`#10B981`)
- **Error**: Crimson (`#EF4444`)
- **Storage Badge**: _"Progress is saved locally on your device."_

---

## 📱 Core Features & Screens

1. **Splash Screen (`splash_screen.dart`)**
   - UIU-inspired orange background with smooth emblem scaling and fade-in animations.
   - 100% offline security indicator.

2. **Home Dashboard (`home_screen.dart`)**
   - Hero Cumulative GPA Card (3.78 / 4.00) with animated progress ring.
   - Dean's List Honor Standing badge.
   - Degree completion progress bar (76.0 / 138.0 Credits).
   - 4-grid key stats: Earned credits, Remaining credits, Current term, and Target SGPA.
   - AI Academic advisor spotlight banner and Quick Actions hub.
   - Recent term course cards with UIU grade badges.

3. **GPA Calculator & Target Planner (`gpa_calculator_screen.dart`)**
   - **Target CGPA Planner**: Computes exact required future SGPA per term with attainability warnings (e.g. _Easily Achieved_, _Challenging_, or _Mathematically Impossible > 4.00_).
   - **Term SGPA Simulator**: Interactive course builder with live grade selectors (A, A-, B+, etc.) showing real-time impact on overall cumulative CGPA.
   - Convocation honors forecast (_Summa Cum Laude_, _Magna Cum Laude_, _Cum Laude_).

4. **Transcript Import & History (`transcript_import_screen.dart`)**
   - Drag-and-drop styled PDF / CSV upload cards (UI only).
   - Instant sample UIU transcript loader (Batch 201).
   - Filter chips for Trimesters (All, Spring, Summer, Fall).
   - Expandable `SemesterAccordion` cards showing course codes, titles, credits, grades, and grade points.

5. **AI Academic Advisor (`ai_advisor_screen.dart`) [Hero Feature]**
   - Academic performance digest and projected graduation CGPA.
   - Subject mastery domain breakdown (Algorithms, Software Eng, Hardware, Math, GED).
   - Recommended next semester courses ranked by prerequisite unlock logic.
   - **Course Conflict Warnings**: Identifies dangerous overlaps (e.g., Heavy Hardware Lab conflict: Microprocessors + Compiler Design).
   - Real-time Workload & Difficulty Meter.
   - High-impact GPA improvement tips.

6. **Semester Planner (`semester_planner_screen.dart`)**
   - Visual drag-and-drop future semester course arrangement.
   - Live workload meter (_Light_, _Balanced (Recommended)_, _Heavy_).
   - Prerequisite checking and add/remove catalog courses.

7. **Academic Analytics (`analytics_screen.dart`)**
   - Custom-painted GPA progression line chart across 7 trimesters with gradient fill.
   - Grade distribution histogram (A through F frequency).
   - Credit velocity and completion ring.

8. **Student Profile (`profile_screen.dart`)**
   - UIU Student ID card layout (Sourav Ahmed, 011 201 042, B.Sc. in CSE).
   - Academic Advisor details (Dr. Mohammad Nurul Huda).
   - Local device storage status indicator.
   - UIU Official Grading Scale bottom sheet viewer.

---

## 🏛️ Official UIU Grading Scale Embedded

| Grade  | Grade Point | Mark Range | Remarks        |
| ------ | ----------- | ---------- | -------------- |
| **A**  | 4.00        | 80% - 100% | Outstanding    |
| **A-** | 3.67        | 75% - 79%  | Excellent      |
| **B+** | 3.33        | 70% - 74%  | Very Good      |
| **B**  | 3.00        | 65% - 69%  | Good           |
| **B-** | 2.67        | 60% - 64%  | Satisfactory   |
| **C+** | 2.33        | 55% - 59%  | Above Average  |
| **C**  | 2.00        | 50% - 54%  | Average        |
| **D+** | 1.67        | 45% - 49%  | Pass           |
| **D**  | 1.00        | 40% - 44%  | Barely Passing |
| **F**  | 0.00        | 0% - 39%   | Fail           |

---

## 🚀 Directory Structure

```
d:/Project/UIU Grade Calculator/
├── android/
│   └── app/src/main/AndroidManifest.xml
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── uiu_grading_scale.dart
│   │   └── utils/
│   │       ├── calculator_utils.dart
│   │       └── responsive_utils.dart
│   ├── data/
│   │   └── uiu_mock_data.dart
│   ├── models/
│   │   ├── ai_recommendation.dart
│   │   ├── course.dart
│   │   ├── semester_transcript.dart
│   │   └── student_profile.dart
│   ├── screens/
│   │   ├── ai_advisor_screen.dart
│   │   ├── analytics_screen.dart
│   │   ├── gpa_calculator_screen.dart
│   │   ├── home_screen.dart
│   │   ├── main_navigation_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── semester_planner_screen.dart
│   │   ├── splash_screen.dart
│   │   └── transcript_import_screen.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── app_typography.dart
│   ├── widgets/
│   │   ├── course_card.dart
│   │   ├── custom_charts.dart
│   │   ├── gpa_progress_ring.dart
│   │   ├── semester_accordion.dart
│   │   ├── stat_card.dart
│   │   ├── uiu_bottom_sheet.dart
│   │   ├── uiu_header.dart
│   │   └── workload_indicator.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```
