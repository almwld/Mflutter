import 'package:flutter/material.dart';
import 'quran_index_screen.dart';

/// Keeps the legacy route compatible while sharing the canonical 114-surah index.
class SurahIndexScreen extends StatelessWidget {
  const SurahIndexScreen({super.key});

  @override
  Widget build(BuildContext context) => const QuranIndexScreen();
}
