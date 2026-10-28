import 'package:flutter/material.dart';

import 'home_screen.dart';

/// Backwards-compatible entry point for callers that still open
/// [MainNavigation].
///
/// The application now has one canonical primary navigation implementation:
/// [HomeScreen]. Keeping this thin adapter avoids maintaining a second tab
/// shell with a different set of destinations and a duplicate More screen.
class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) => const HomeScreen();
}

/// Preserve the legacy import path for the shared tools directory.
export 'home_screen.dart' show MoreScreen;
