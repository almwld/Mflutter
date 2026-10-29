import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart' show getVerse;
import 'package:mudabbir_al_asrar/services/bookmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('adds, reads, and removes a saved verse using one store', () async {
    await BookmarkService.addBookmark(2, 255, 'sample verse');

    expect(await BookmarkService.isBookmarked(2, 255), isTrue);
    final saved = await BookmarkService.getBookmarks();
    expect(saved, hasLength(1));
    expect(saved.single['surah'], 2);
    expect(saved.single['ayah'], 255);
    final canonical = getVerse(2, 255, verseEndSymbol: false).trim();
    expect(saved.single['text'], canonical.length > 100 ? canonical.substring(0, 100) : canonical);

    await BookmarkService.removeBookmark(2, 255);
    expect(await BookmarkService.isBookmarked(2, 255), isFalse);
    expect(await BookmarkService.getBookmarks(), isEmpty);
  });

  test('re-adding the same verse does not create duplicate bookmarks', () async {
    await BookmarkService.addBookmark(1, 1, 'first');
    await BookmarkService.addBookmark(1, 1, 'updated');

    final saved = await BookmarkService.getBookmarks();
    expect(saved, hasLength(1));
    final canonical = getVerse(1, 1, verseEndSymbol: false).trim();
    expect(saved.single['text'], canonical.length > 100 ? canonical.substring(0, 100) : canonical);
  });

  test('rejects invalid Quran references', () async {
    expect(
      () => BookmarkService.addBookmark(115, 1, 'invalid'),
      throwsArgumentError,
    );
    expect(
      () => BookmarkService.addBookmark(1, 0, 'invalid'),
      throwsArgumentError,
    );
  });
}
