/// Shared AI Prompts for UIU UCAM Result Conversion
class AIPromptConstants {
  static const String ucamToCsvPrompt =
      'Convert my UIU UCAM result history into CSV format for UIU Grade Calculator app.\n\n'
      'Output columns: Trimester,Course Code,Course Title,Credit,Grade\n\n'
      'Instructions:\n'
      '1. Extract every trimester (e.g., Fall 2023, Spring 2024, etc.).\n'
      '2. For each course, extract Course Code (e.g., CSE 1111), Title, Credit (e.g., 3.0), and Grade (e.g., A, B+, etc.).\n'
      '3. Provide ONLY pure CSV text without markdown or conversational commentary so I can save as .csv directly.\n\n'
      'Here is my UCAM result:';
}

