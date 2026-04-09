import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:golden_matrix/golden_matrix.dart';

import 'package:golden_matrix_example/widgets/sample_button.dart';
import 'package:golden_matrix_example/widgets/sample_card.dart';
import 'package:golden_matrix_example/widgets/user_avatar.dart';
import 'package:golden_matrix_example/widgets/notification_badge.dart';
import 'package:golden_matrix_example/screens/login_screen.dart';
import 'package:golden_matrix_example/screens/profile_screen.dart';

void main() {
  // ---------------------------------------------------------------------------
  // 1. Basic component test with explicit axes
  // ---------------------------------------------------------------------------
  matrixGolden(
    'SampleButton',
    scenarios: [
      MatrixScenario(
        'default',
        builder: () => const SampleButton(label: 'Continue'),
        tags: ['core', 'interactive'],
      ),
      MatrixScenario(
        'disabled',
        builder: () => const SampleButton(label: 'Continue', enabled: false),
        tags: ['core', 'state'],
      ),
      MatrixScenario(
        'long_text',
        builder: () => const SampleButton(label: 'Continue with a very long label text'),
        tags: ['core', 'edge'],
      ),
    ],
    axes: MatrixAxes(
      themes: const [MatrixTheme.light, MatrixTheme.dark],
      locales: const [Locale('en'), Locale('ar')],
      textScales: const [1.0, 2.0],
      devices: const [MatrixDevice.phoneSmall, MatrixDevice.phoneLarge],
    ),
  );

  // ---------------------------------------------------------------------------
  // 2. Component test using preset (smoke — much fewer combinations)
  // ---------------------------------------------------------------------------
  matrixGolden(
    'SampleCard',
    scenarios: [
      MatrixScenario(
        'with_subtitle',
        builder: () => const SampleCard(
          title: 'Transfer Complete',
          subtitle: 'Your money has been sent',
        ),
      ),
      MatrixScenario(
        'without_subtitle',
        builder: () => const SampleCard(title: 'Transfer Complete'),
      ),
    ],
    preset: MatrixPreset.componentSmoke,
  );

  // ---------------------------------------------------------------------------
  // 3. Component with named device aliases
  // ---------------------------------------------------------------------------
  matrixGolden(
    'UserAvatar',
    scenarios: [
      MatrixScenario(
        'small_offline',
        builder: () => const UserAvatar(name: 'John Doe', size: AvatarSize.small),
      ),
      MatrixScenario(
        'medium_online',
        builder: () => const UserAvatar(name: 'Jane Smith', isOnline: true),
      ),
      MatrixScenario(
        'large_online',
        builder: () => const UserAvatar(
          name: 'Alex Johnson',
          isOnline: true,
          size: AvatarSize.large,
        ),
      ),
    ],
    axes: MatrixAxes(
      themes: const [MatrixTheme.light, MatrixTheme.dark],
      devices: const [MatrixDevice.iphoneSE, MatrixDevice.galaxyA51],
    ),
  );

  // ---------------------------------------------------------------------------
  // 4. Component with tags and severity states
  // ---------------------------------------------------------------------------
  matrixGolden(
    'NotificationBadge',
    scenarios: [
      MatrixScenario(
        'info',
        builder: () => const NotificationBadge(count: 3, label: 'Messages'),
        tags: ['severity'],
      ),
      MatrixScenario(
        'warning',
        builder: () => const NotificationBadge(
          count: 1,
          label: 'Updates pending',
          severity: BadgeSeverity.warning,
        ),
        tags: ['severity'],
      ),
      MatrixScenario(
        'error',
        builder: () => const NotificationBadge(
          count: 5,
          label: 'Errors',
          severity: BadgeSeverity.error,
        ),
        tags: ['severity', 'critical'],
      ),
    ],
    preset: MatrixPreset.componentFull,
  );

  // ---------------------------------------------------------------------------
  // 5. Full screen test with screenMatrixGolden + appBuilder
  // ---------------------------------------------------------------------------
  screenMatrixGolden(
    'LoginScreen',
    appBuilder: (combination) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: combination.theme.resolve(),
      locale: combination.locale,
      home: LoginScreen(
        errorMessage: combination.scenario.name == 'error'
            ? 'Invalid email or password'
            : null,
      ),
    ),
    states: [
      MatrixScenario('default', builder: () => const SizedBox.shrink()),
      MatrixScenario('error', builder: () => const SizedBox.shrink()),
    ],
    preset: MatrixPreset.screenSmoke,
  );

  // ---------------------------------------------------------------------------
  // 6. Full screen with priorityBased sampling + maxCombinations
  // ---------------------------------------------------------------------------
  screenMatrixGolden(
    'ProfileScreen',
    appBuilder: (combination) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: combination.theme.resolve(),
      locale: combination.locale,
      home: ProfileScreen(
        name: 'John Doe',
        email: 'john@example.com',
        bio: 'Flutter developer & open source contributor',
        followers: 1234,
        following: 567,
        isOwnProfile: combination.scenario.name != 'other_profile',
      ),
    ),
    states: [
      MatrixScenario('own_profile', builder: () => const SizedBox.shrink()),
      MatrixScenario('other_profile', builder: () => const SizedBox.shrink()),
    ],
    axes: MatrixAxes(
      themes: const [MatrixTheme.light, MatrixTheme.dark],
      locales: const [Locale('en')],
      textScales: const [1.0, 1.5],
      devices: const [
        MatrixDevice.phoneSmall,
        MatrixDevice.phoneLarge,
        MatrixDevice.tablet,
      ],
    ),
    sampling: MatrixSampling.priorityBased,
    maxCombinations: 8,
  );

  // ---------------------------------------------------------------------------
  // 7. Exclude rule: skip RTL for non-Arabic locales
  // ---------------------------------------------------------------------------
  matrixGolden(
    'SampleButton_WithRules',
    scenarios: [
      MatrixScenario(
        'default',
        builder: () => const SampleButton(label: 'Submit'),
      ),
    ],
    axes: MatrixAxes(
      themes: const [MatrixTheme.light, MatrixTheme.dark],
      locales: const [Locale('en'), Locale('ar')],
      directions: const [TextDirection.ltr, TextDirection.rtl],
      devices: const [MatrixDevice.phoneSmall],
    ),
    rules: [
      // Don't test RTL with English — only Arabic is RTL
      MatrixRule.exclude(
        (c) => c.locale.languageCode != 'ar' && c.direction == TextDirection.rtl,
      ),
    ],
  );
}
