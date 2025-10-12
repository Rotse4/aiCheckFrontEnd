import 'package:flutter/material.dart';

class Breakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1200;
}

bool isWide(BuildContext context) => MediaQuery.of(context).size.width >= Breakpoints.medium;

double pageHorizontalPadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= Breakpoints.expanded) return 48;
  if (width >= Breakpoints.medium) return 32;
  if (width >= Breakpoints.compact) return 20;
  return 12;
}

Widget centeredConstrained({required Widget child, double maxWidth = 1100}) {
  return Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}