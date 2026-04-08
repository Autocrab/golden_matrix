import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_matrix/golden_matrix.dart';

void main() {
  group('MatrixAxes', () {
    test('default values', () {
      const axes = MatrixAxes();

      expect(axes.themes.length, 1);
      expect(axes.themes.first.name, 'light');
      expect(axes.locales.length, 1);
      expect(axes.locales.first, const Locale('en'));
      expect(axes.textScales.length, 1);
      expect(axes.textScales.first, 1.0);
      expect(axes.devices.length, 1);
      expect(axes.devices.first.name, 'phoneSmall');
      expect(axes.directions, isEmpty);
    });

    test('custom values are preserved', () {
      final axes = MatrixAxes(
        themes: const [MatrixTheme.light, MatrixTheme.dark],
        locales: const [Locale('en'), Locale('ru'), Locale('ar')],
        textScales: const [1.0, 1.5, 2.0],
        devices: const [MatrixDevice.phoneSmall, MatrixDevice.tablet],
        directions: const [TextDirection.ltr, TextDirection.rtl],
      );

      expect(axes.themes.length, 2);
      expect(axes.locales.length, 3);
      expect(axes.textScales.length, 3);
      expect(axes.devices.length, 2);
      expect(axes.directions.length, 2);
    });
  });
}
