import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../models/matrix_combination.dart';

/// Wraps a widget in a configured [MaterialApp] shell for golden testing.
///
/// Applies theme, locale, directionality, text scale, and device safe area
/// from the given [MatrixCombination].
class MatrixWidgetWrapper extends StatelessWidget {
  final MatrixCombination combination;
  final Widget child;
  final List<LocalizationsDelegate<dynamic>> extraLocalizationsDelegates;

  const MatrixWidgetWrapper({
    super.key,
    required this.combination,
    required this.child,
    this.extraLocalizationsDelegates = const [],
  });

  @override
  Widget build(BuildContext context) {
    final themeData = combination.theme.resolve();

    final delegates = [
      ...extraLocalizationsDelegates,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      locale: combination.locale,
      supportedLocales: [combination.locale],
      localizationsDelegates: delegates,
      home: Directionality(
        textDirection: combination.direction,
        child: MediaQuery(
          data: MediaQueryData(
            size: combination.device.logicalSize,
            devicePixelRatio: combination.device.pixelRatio,
            textScaler: TextScaler.linear(combination.textScale),
            padding: combination.device.safeArea,
          ),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }
}
