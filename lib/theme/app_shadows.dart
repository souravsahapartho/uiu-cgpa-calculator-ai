import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x180F172A),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> primary = [
    BoxShadow(
      color: Color(0x35F26522),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> secondary = [
    BoxShadow(
      color: Color(0x281E293B),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> accent = [
    BoxShadow(
      color: Color(0x28EA580C),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
