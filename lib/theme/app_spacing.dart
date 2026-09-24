import 'package:flutter/material.dart';

class AppSpacing {
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s16 = 16.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s56 = 56.0;

  // Legacy mappings
  static const double xs = s4;
  static const double sm = s8;
  static const double md = s16;
  static const double base = s16;
  static const double lg = s24;
  static const double xl = s32;
  static const double xxl = s40;
  static const double xxxl = s56;

  // Insets
  static const EdgeInsets edgeInsetsAll4 = EdgeInsets.all(s4);
  static const EdgeInsets edgeInsetsAll8 = EdgeInsets.all(s8);
  static const EdgeInsets edgeInsetsAll16 = EdgeInsets.all(s16);
  static const EdgeInsets edgeInsetsAll24 = EdgeInsets.all(s24);
  static const EdgeInsets edgeInsetsAll32 = EdgeInsets.all(s32);

  static const EdgeInsets edgeInsetsScreen = EdgeInsets.symmetric(horizontal: s16, vertical: s8);
  static const EdgeInsets edgeInsetsCard = EdgeInsets.all(s16);
  static const EdgeInsets edgeInsetsCompactCard = EdgeInsets.all(s12);
  static const double s12 = 12.0;

  static const EdgeInsets edgeInsetsAllSm = edgeInsetsAll8;
  static const EdgeInsets edgeInsetsAllMd = EdgeInsets.all(s12);
  static const EdgeInsets edgeInsetsAllBase = edgeInsetsAll16;
  static const EdgeInsets edgeInsetsAllLg = edgeInsetsAll24;
  static const EdgeInsets edgeInsetsAllXl = edgeInsetsAll32;
}
