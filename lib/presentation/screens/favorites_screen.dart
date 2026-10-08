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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('المفضلة'),
      ),
      body: _bookmarks.isEmpty
          ? Center(child: Text('لا توجد علامات مفضلة', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(.55))))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _bookmarks.length,
              itemBuilder: (_, i) {
                final b = _bookmarks[i];
                return Card(
                  
                  child: ListTile(
                    title: Text(b['text'] ?? '', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'Amiri'), textDirection: TextDirection.rtl, maxLines: 2),
                    subtitle: Text('${b['surah']}:${b['ayah']}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
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
