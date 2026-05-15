import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});
  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _controller = TextEditingController();
  String _result = '';

  void _search() {
    setState(() => _result = 'نتائج البحث عن: ${_controller.text}\n\n﴿اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ﴾ (النور:35)\n﴿وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ﴾ (الذاريات:47)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('بحث متقدم', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        TextField(controller: _controller, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'ابحث بالكلمة أو الجذر أو الجمل...', hintStyle: TextStyle(color: Colors.white38), filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        SizedBox(height: 12),
        ElevatedButton(onPressed: _search, child: Text('بحث')),
        if (_result.isNotEmpty) ...[SizedBox(height: 20), Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)), child: Text(_result, style: TextStyle(color: Colors.white70, fontSize: 16)))]
      ])),
    );
  }
}
