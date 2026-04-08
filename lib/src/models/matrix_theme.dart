import 'package:flutter/material.dart';

/// Represents a theme configuration for matrix golden testing.
class MatrixTheme {
  final String name;
  final ThemeData? themeData;

  const MatrixTheme._(this.name, [this.themeData]);

  static const light = MatrixTheme._('light');
  static const dark = MatrixTheme._('dark');

  factory MatrixTheme.custom(String name, ThemeData themeData) =>
      MatrixTheme._(name, themeData);

  /// Returns the resolved ThemeData.
  ThemeData resolve() {
    if (themeData != null) return themeData!;
    return name == 'dark' ? ThemeData.dark() : ThemeData.light();
  }

  String get slug => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  @override
  String toString() => 'MatrixTheme($name)';
}
