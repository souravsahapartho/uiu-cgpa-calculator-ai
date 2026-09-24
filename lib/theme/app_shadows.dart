import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A0D1B2A),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x050D1B2A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x140D1B2A),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> primary = [
    BoxShadow(
      color: Color(0x330F4C81),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> secondary = [
    BoxShadow(
      color: Color(0x33F59E0B),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];
}
