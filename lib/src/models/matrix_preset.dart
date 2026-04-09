import 'package:flutter/widgets.dart';

import 'matrix_axes.dart';
import 'matrix_device.dart';
import 'matrix_rule.dart';
import 'matrix_sampling.dart';
import 'matrix_theme.dart';

/// A reusable bundle of axes, sampling strategy, and rules.
///
/// Presets simplify test declarations by providing sensible defaults
/// for common testing scenarios.
///
/// Example:
/// ```dart
/// matrixGolden(
///   'MyWidget',
///   scenarios: [...],
///   preset: MatrixPreset.componentSmoke,
/// );
/// ```
class MatrixPreset {
  final MatrixAxes axes;
  final MatrixSampling sampling;
  final List<MatrixRule> rules;

  const MatrixPreset({
    required this.axes,
    this.sampling = MatrixSampling.full,
    this.rules = const [],
  });

  /// Quick smoke test for components: light/dark theme, single device.
  static const componentSmoke = MatrixPreset(
    axes: MatrixAxes(
      themes: [MatrixTheme.light, MatrixTheme.dark],
      devices: [MatrixDevice.phoneSmall],
    ),
    sampling: MatrixSampling.smoke,
  );

  /// Full coverage for components: light/dark, 2 locales, 2 text scales, 2 devices.
  static const componentFull = MatrixPreset(
    axes: MatrixAxes(
      themes: [MatrixTheme.light, MatrixTheme.dark],
      locales: [Locale('en'), Locale('ar')],
      textScales: [1.0, 2.0],
      devices: [MatrixDevice.phoneSmall, MatrixDevice.tablet],
    ),
  );

  /// Quick smoke test for screens: light/dark, 2 locales, 2 devices.
  static const screenSmoke = MatrixPreset(
    axes: MatrixAxes(
      themes: [MatrixTheme.light, MatrixTheme.dark],
      locales: [Locale('en'), Locale('ar')],
      devices: [MatrixDevice.phoneSmall, MatrixDevice.tablet],
    ),
    sampling: MatrixSampling.smoke,
  );
}
