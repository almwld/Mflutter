import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../utils/abjad_constants.dart';
import '../../utils/divine_names_descriptions.dart';

class DivineNamesScreen extends StatefulWidget {
  const DivineNamesScreen({super.key});

  @override
  State<DivineNamesScreen> createState() => _DivineNamesScreenState();

;
}

class _DivineNamesScreenState extends State<DivineNamesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalize(String value) => value
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll(RegExp(r'[ؤئ]'), 'ء')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .trim();

  @override
  Widget build(BuildContext context) {
    final query = _normalize(_searchController.text);
    final names = AbjadConstants.divineNames.asMap().entries
        .where((entry) =>
            query.isEmpty || _normalize(entry.value).contains(query))
        .toList(growable: false);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'الأسماء الحسنى',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGold.withOpacity(.25)),
            ),
            child: const Text(
              'تعرض الشاشة قائمة شائعة من الأسماء الحسنى؛ قد تختلف بعض القوائم في ترتيب بعض الأسماء أو عدّها. المعاني مختصرة للتعريف وليست تفسيرًا جامعًا.',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ابحث عن اسم...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'مسح البحث',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: names.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.12,
              ),
              itemBuilder: (context, index) {
                final entry = names[index];
                final name = entry.value;
                return Card(
                  color: AppColors.primaryNavy.withOpacity(0.6),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 17,
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          DivineNamesDescriptions.meanings[name] ?? 'اسم في القائمة المتداولة',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
