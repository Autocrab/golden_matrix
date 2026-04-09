import 'package:flutter/material.dart';

/// Represents a theme configuration for matrix golden testing.
///
/// Use [data] to attach arbitrary context (custom theme objects, feature
/// flags, brand config, etc.) that can be accessed in builders via
/// `combination.theme.data`.
///
/// Example with a custom theme system:
/// ```dart
/// axes: MatrixAxes(
///   themes: [
///     MatrixTheme.custom('light', ThemeData.light(), data: MyTheme.light()),
///     MatrixTheme.custom('dark', ThemeData.dark(), data: MyTheme.dark()),
///   ],
/// )
///
/// // In builder:
/// final myTheme = combination.theme.data as MyTheme;
/// ```
class MatrixTheme {
  final String name;
  final ThemeData? themeData;

  /// Arbitrary data attached to this theme.
  ///
  /// Use this to pass custom theme objects, brand configurations,
  /// or any other context needed in widget builders.
  final Object? data;

  const MatrixTheme._(this.name, [this.themeData, this.data]);

  static const light = MatrixTheme._('light');
  static const dark = MatrixTheme._('dark');

  /// Creates a custom theme with a [name], [ThemeData], and optional [data].
  factory MatrixTheme.custom(String name, ThemeData themeData, {Object? data}) =>
      MatrixTheme._(name, themeData, data);

  /// Returns the resolved ThemeData.
  ThemeData resolve() {
    if (themeData != null) return themeData!;
    return name == 'dark' ? ThemeData.dark() : ThemeData.light();
  }

  String get slug => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  @override
  String toString() => 'MatrixTheme($name)';
}
