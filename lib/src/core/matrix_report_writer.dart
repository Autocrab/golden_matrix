import 'dart:convert';
import 'dart:io';

import '../models/matrix_result.dart';

/// Writes a [MatrixResult] as a JSON report file.
class MatrixReportWriter {
  /// Writes the report to `goldens/<name>_report.json`.
  static Future<void> write(MatrixResult result) async {
    final json = const JsonEncoder.withIndent('  ').convert(result.toJson());
    final slug =
        result.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final file = File('goldens/${slug}_report.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(json);
  }
}
