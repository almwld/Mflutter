import 'package:flutter/material.dart';

class SurahBanner extends StatelessWidget {
  final String surahName;
  final bool showBismillah;

  const SurahBanner({
    super.key,
    required this.surahName,
    this.showBismillah = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // البانر الذهبي
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1A237E)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: const Color(0xFFFFD700)),
              const SizedBox(width: 16),
              Text(
                'سُورَةُ $surahName',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 40, height: 1, color: const Color(0xFFFFD700)),
            ],
          ),
        ),
        // البسملة
        if (showBismillah) ...[
          const SizedBox(height: 12),
          const Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
