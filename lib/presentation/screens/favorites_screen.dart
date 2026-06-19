import 'package:flutter/material.dart';
import '../../services/bookmark_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await BookmarkService.getBookmarks();
    setState(() => _bookmarks = bookmarks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('⭐ المفضلة', style: TextStyle(color: Color(0xFFFFD700))),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: _bookmarks.isEmpty
          ? const Center(child: Text('لا توجد علامات مفضلة', style: TextStyle(color: Colors.white38)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _bookmarks.length,
              itemBuilder: (_, i) {
                final b = _bookmarks[i];
                return Card(
                  color: const Color(0xFF1A237E).withOpacity(0.6),
                  child: ListTile(
                    title: Text(b['text'] ?? '', style: const TextStyle(color: Color(0xFFFFECB3), fontFamily: 'Amiri'), textDirection: TextDirection.rtl, maxLines: 2),
                    subtitle: Text('${b['surah']}:${b['ayah']}', style: const TextStyle(color: Color(0xFFFFD700))),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await BookmarkService.removeBookmark(b['surah'], b['ayah']);
                        _loadBookmarks();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
