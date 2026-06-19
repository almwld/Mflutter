import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MiraclesScreen extends StatelessWidget {
  const MiraclesScreen({super.key});

  static const List<Map<String, String>> _miracles = [
    {'title': 'العدد ١٩', 'desc': '﴿عَلَيْهَا تِسْعَةَ عَشَرَ﴾ (المدثر:30). بسم الله الرحمن الرحيم = 19 حرفاً.'},
    {'title': 'العدد ٧', 'desc': 'السموات السبع، الطواف ٧ أشواط، السعي ٧، آيات الفاتحة ٧.'},
    {'title': 'توازن الكلمات', 'desc': 'الدنيا وردت ١١٥ مرة والآخرة ١١٥ مرة. الملائكة ٨٨ والشياطين ٨٨.'},
    {'title': 'سورة الحديد', 'desc': 'الحديد رقم ٥٧ في القرآن = وزنه الذري. ﴿وَأَنزَلْنَا الْحَدِيدَ﴾.'},
    {'title': 'النسبة الذهبية', 'desc': 'نسبة كلمة "البحر" إلى "البر" = 71.4% - النسبة الفعلية للماء على الأرض.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الإعجاز العددي', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _miracles.length,
        itemBuilder: (context, index) {
          final m = _miracles[index];
          return Card(
            color: AppColors.surface,
            margin: EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('🔢 ${m['title']}', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(m['desc']!, style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
