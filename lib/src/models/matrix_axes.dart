import 'package:flutter/widgets.dart';

import 'matrix_device.dart';
import 'matrix_theme.dart';

/// Describes the dimensions of the test matrix.
class MatrixAxes {
  final List<MatrixTheme> themes;
  final List<Locale> locales;
  final List<double> textScales;
  final List<MatrixDevice> devices;
  final List<TextDirection> directions;

  const MatrixAxes({
    this.themes = const [MatrixTheme.light],
    this.locales = const [Locale('en')],
    this.textScales = const [1.0],
    this.devices = const [MatrixDevice.phoneSmall],
    this.directions = const [],
  });
}
