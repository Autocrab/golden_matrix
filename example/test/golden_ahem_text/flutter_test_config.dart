import 'dart:async';

import 'package:golden_matrix/golden_matrix.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Demo of the 0.18.0 feature: text rendered with Ahem placeholder
  // (predictable square-box geometry), icons rendered with real glyphs.
  await loadAppFonts(textFonts: false);
  return testMain();
}
