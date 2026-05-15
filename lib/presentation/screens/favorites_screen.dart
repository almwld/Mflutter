import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<Map<String, String>> _favorites = [
    {'verse': 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ', 'ref': 'النور:35'},
    {'verse': 'وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ', 'ref': 'الذاريات:47'},
    {'verse': 'قُلْ هُوَ اللَّهُ أَحَدٌ', 'ref': 'الإخلاص:1'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('المفضلة', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: ListView.builder(padding: EdgeInsets.all(16), itemCount: _favorites.length, itemBuilder: (context, i) {
        final f = _favorites[i];
        return Card(color: AppColors.surface, child: ListTile(
          title: Text(f['verse']!, style: TextStyle(color: Colors.white, fontFamily: 'Amiri')),
          subtitle: Text(f['ref']!, style: TextStyle(color: Colors.white54)),
          trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() => _favorites.removeAt(i)); }),
        ));
      }),
    );
  }
}
