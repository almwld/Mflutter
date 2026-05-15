import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RecitationScreen extends StatefulWidget {
  const RecitationScreen({super.key});
  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  bool _playing = false;
  String _currentSurah = 'الفاتحة';
  final List<String> _surahs = ['الفاتحة', 'البقرة', 'الإخلاص', 'الفلق', 'الناس'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('التلاوة', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: Column(children: [
        Expanded(child: ListView.builder(padding: EdgeInsets.all(16), itemCount: _surahs.length, itemBuilder: (context, i) {
          return ListTile(title: Text(_surahs[i], style: TextStyle(color: Colors.white)), trailing: IconButton(icon: Icon(Icons.play_arrow, color: AppColors.primaryGold), onPressed: () { setState(() { _playing = true; _currentSurah = _surahs[i]; }); }));
        })),
        if (_playing) Container(padding: EdgeInsets.all(20), color: AppColors.surface, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text('🎵 $_currentSurah', style: TextStyle(color: AppColors.primaryGold)),
          IconButton(icon: Icon(Icons.pause, color: Colors.white, size: 40), onPressed: () => setState(() => _playing = false)),
          IconButton(icon: Icon(Icons.stop, color: Colors.white, size: 40), onPressed: () => setState(() => _playing = false)),
        ])),
      ]),
    );
  }
}
