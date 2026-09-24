import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusBase = Radius.circular(base);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);

  static const BorderRadius borderSm = BorderRadius.all(radiusSm);
  static const BorderRadius borderMd = BorderRadius.all(radiusMd);
  static const BorderRadius borderBase = BorderRadius.all(radiusBase);
  static const BorderRadius borderLg = BorderRadius.all(radiusLg);
  static const BorderRadius borderXl = BorderRadius.all(radiusXl);
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));
}
