import 'package:flutter/widgets.dart';

/// Represents a device configuration for matrix golden testing.
class MatrixDevice {
  final String name;
  final Size logicalSize;
  final double pixelRatio;
  final EdgeInsets safeArea;

  const MatrixDevice({
    required this.name,
    required this.logicalSize,
    this.pixelRatio = 1.0,
    this.safeArea = EdgeInsets.zero,
  });

  // iOS devices
  static const phoneSmall = MatrixDevice(
    name: 'phoneSmall',
    logicalSize: Size(375, 667),
    pixelRatio: 2.0,
    safeArea: EdgeInsets.only(top: 20),
  );

  static const phoneMedium = MatrixDevice(
    name: 'phoneMedium',
    logicalSize: Size(390, 844),
    pixelRatio: 3.0,
    safeArea: EdgeInsets.only(top: 47, bottom: 34),
  );

  static const phoneLarge = MatrixDevice(
    name: 'phoneLarge',
    logicalSize: Size(414, 896),
    pixelRatio: 3.0,
    safeArea: EdgeInsets.only(top: 44, bottom: 34),
  );

  // Android devices
  static const androidSmall = MatrixDevice(
    name: 'androidSmall',
    logicalSize: Size(360, 800),
    pixelRatio: 4.0,
  );

  static const androidMedium = MatrixDevice(
    name: 'androidMedium',
    logicalSize: Size(412, 915),
    pixelRatio: 2.625,
  );

  // Tablet
  static const tablet = MatrixDevice(
    name: 'tablet',
    logicalSize: Size(768, 1024),
    pixelRatio: 2.0,
    safeArea: EdgeInsets.only(top: 20),
  );

  // Named aliases for real devices
  static const iphoneSE = phoneSmall;
  static const iphone15 = phoneMedium;
  static const iphone15ProMax = phoneLarge;
  static const galaxyS20 = androidSmall;
  static const galaxyA51 = androidMedium;
  static const ipadPortrait = tablet;

  // Tablet landscape
  static const tabletLandscape = MatrixDevice(
    name: 'tabletLandscape',
    logicalSize: Size(1024, 768),
    pixelRatio: 2.0,
    safeArea: EdgeInsets.only(top: 20),
  );

  String get slug => name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  @override
  String toString() => 'MatrixDevice($name, ${logicalSize.width}x${logicalSize.height})';
}
