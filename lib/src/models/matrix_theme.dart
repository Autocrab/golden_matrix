import 'package:flutter/material.dart';

import '../core/slug.dart';

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

  static const light = MatrixTheme._('light', null, null);
  static const dark = MatrixTheme._('dark', null, null);

  /// Creates a custom theme with a [name], [ThemeData], and optional [data].
  factory MatrixTheme.custom(String name, ThemeData themeData, {Object? data}) =>
      MatrixTheme._(name, themeData, data);

  /// Whether this is the built-in dark theme.
  bool get isDark => identical(this, dark) || (themeData?.brightness == Brightness.dark);

  /// Returns the resolved ThemeData.
  ThemeData resolve() {
    if (themeData != null) return themeData!;
    return isDark ? ThemeData.dark() : ThemeData.light();
  }

  String get slug => slugify(name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MatrixTheme && other.name == name);

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'MatrixTheme($name)';
}
