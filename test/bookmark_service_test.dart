import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    expect(saved.single['text'], 'sample verse');

    await BookmarkService.removeBookmark(2, 255);
    expect(await BookmarkService.isBookmarked(2, 255), isFalse);
    expect(await BookmarkService.getBookmarks(), isEmpty);
  });

  test('re-adding the same verse does not create duplicate bookmarks', () async {
    await BookmarkService.addBookmark(1, 1, 'first');
    await BookmarkService.addBookmark(1, 1, 'updated');

    final saved = await BookmarkService.getBookmarks();
    expect(saved, hasLength(1));
    expect(saved.single['text'], 'updated');
  });

  test('rejects invalid Quran references', () async {
    await expectLater(
      BookmarkService.addBookmark(115, 1, 'invalid'),
      throwsArgumentError,
    );
    await expectLater(
      BookmarkService.addBookmark(1, 0, 'invalid'),
      throwsArgumentError,
    );
  });
}
