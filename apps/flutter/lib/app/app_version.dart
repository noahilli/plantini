import 'package:flutter/services.dart';

/// Uses the bundled pubspec on every platform. Builds overriding --build-name
/// must also supply `--dart-define=PLANTINI_APP_VERSION=<build-name>` (Web too).
/// Build numbers do not affect the manifest's major.minor.patch requirement.
abstract final class AppVersion {
  static Future<String> read() async {
    const override = String.fromEnvironment('PLANTINI_APP_VERSION');
    if (override.isNotEmpty) return override;
    final pubspec = await rootBundle.loadString('pubspec.yaml');
    final version = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+(?:\+\d+)?)\s*$',
      multiLine: true,
    ).firstMatch(pubspec)?.group(1);
    if (version == null) {
      throw const FormatException('Bundled pubspec has no valid app version.');
    }
    return version;
  }

  static List<int> components(String version) {
    if (!RegExp(r'^\d+\.\d+\.\d+(?:\+\d+)?$').hasMatch(version)) {
      throw const FormatException('Invalid app version.');
    }
    return version.split('+').first.split('.').map(int.parse).toList();
  }
}
