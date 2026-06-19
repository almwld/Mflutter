import 'package:flutter/material.dart';

class DivineNamesScreen extends StatelessWidget {
  const DivineNamesScreen({super.key});

  static const names = [
    {'name': 'الرحمن', 'desc': 'ذو الرحمة الشاملة'},
    {'name': 'الرحيم', 'desc': 'ذو الرحمة الواصلة'},
    {'name': 'الملك', 'desc': 'المالك لكل شيء'},
    {'name': 'القدوس', 'desc': 'المنزه عن النقائص'},
    {'name': 'السلام', 'desc': 'مصدر السلام'},
    {'name': 'المؤمن', 'desc': 'واهب الأمان'},
    {'name': 'المهيمن', 'desc': 'الرقيب الحفيظ'},
    {'name': 'العزيز', 'desc': 'الغالب القوي'},
    {'name': 'الجبار', 'desc': 'جابر الكسور'},
    {'name': 'المتكبر', 'desc': 'المتعالي عن السوء'},
    {'name': 'الخالق', 'desc': 'المبدع من العدم'},
    {'name': 'البارئ', 'desc': 'المنشئ المخترع'},
    {'name': 'المصور', 'desc': 'مبدع الصور'},
    {'name': 'الغفار', 'desc': 'كثير المغفرة'},
    {'name': 'القهار', 'desc': 'القاهر فوق عباده'},
    {'name': 'الوهاب', 'desc': 'كثير العطاء'},
    {'name': 'الرزاق', 'desc': 'متكفل بالرزق'},
    {'name': 'الفتاح', 'desc': 'فاتح الأبواب'},
    {'name': 'العليم', 'desc': 'كثير العلم'},
    {'name': 'الحكيم', 'desc': 'ذو الحكمة'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('🕌 الأسماء الحسنى', style: TextStyle(color: Color(0xFFFFD700)))),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(10),
        children: names.map((n) => Card(
          color: const Color(0xFF1A237E).withOpacity(0.6),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(n['name']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(n['desc']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ]),
        )).toList(),
      ),
    );
  }
}
