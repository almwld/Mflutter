import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;
  Map<String, dynamic>? _quran;

  @override
  void initState() {
    super.initState();
    _loadQuran();
  }

  Future<void> _loadQuran() async {
    final jsonStr = await rootBundle.loadString('assets/unified_quran.json');
    setState(() => _quran = jsonDecode(jsonStr));
  }

  void _search(String query) {
    if (_quran == null || query.trim().isEmpty) return;

    setState(() {
      _searching = true;
      _results = [];
    });

    final results = <Map<String, dynamic>>[];
    final q = query.trim();

    for (final surahNum in _quran!.keys) {
      final verses = _quran![surahNum] as List<dynamic>;
      for (int i = 0; i < verses.length; i++) {
        final text = verses[i]['text'] ?? '';
        if (text.contains(q)) {
          results.add({
            'surah': int.parse(surahNum),
            'ayah': i + 1,
            'text': text,
          });
          if (results.length >= 50) break;
        }
      }
      if (results.length >= 50) break;
    }

    setState(() {
      _results = results;
      _searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('🔍 بحث في القرآن', style: TextStyle(color: Color(0xFFFFD700))),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1A237E),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن كلمة أو آية...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                filled: true,
                fillColor: const Color(0xFF0A0E27),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onSubmitted: _search,
            ),
          ),

          // النتائج
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                : _results.isEmpty
                    ? const Center(child: Text('اكتب كلمة للبحث عنها في القرآن', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final r = _results[i];
                          return Card(
                            color: const Color(0xFF1A237E).withOpacity(0.6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    r['text'],
                                    style: const TextStyle(color: Color(0xFFFFECB3), fontSize: 16, fontFamily: 'Amiri', height: 1.8),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${r['surah']}:${r['ayah']}',
                                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12),
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
