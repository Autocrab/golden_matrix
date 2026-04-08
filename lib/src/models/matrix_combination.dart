import 'package:flutter/widgets.dart';

import 'matrix_device.dart';
import 'matrix_scenario.dart';
import 'matrix_theme.dart';

/// Represents a single combination of all axis values.
/// This is the basic unit of test execution.
class MatrixCombination {
  final MatrixScenario scenario;
  final MatrixTheme theme;
  final Locale locale;
  final double textScale;
  final MatrixDevice device;
  final TextDirection direction;

  const MatrixCombination({
    required this.scenario,
    required this.theme,
    required this.locale,
    required this.textScale,
    required this.device,
    required this.direction,
  });

  @override
  String toString() =>
      'MatrixCombination(${scenario.name}, ${theme.name}, $locale, ${textScale}x, ${device.name}, ${direction.name})';
}
