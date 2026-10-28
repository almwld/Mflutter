import 'package:flutter/material.dart';

import 'favorites_screen.dart';

/// Dedicated Quran-bookmarks entry point backed by the app's existing
/// bookmark service through [FavoritesScreen]. This intentionally avoids a
/// second persistence layer for the same saved verses.
class QuranBookmarksScreen extends StatelessWidget {
  const QuranBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const FavoritesScreen(title: 'علامات المصحف');
}
