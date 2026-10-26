import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:path/path.dart' as p;

void main() {
  const cache = '/data/user/0/app/cache';
  const id = '0b9d3c4e-5f60-4a71-8b92-a3b4c5d6e7f8';

  group('share copies', () {
    test('a file directly in the cache folder is a plugin copy', () {
      expect(isPluginCopy(cache, '$cache/harbour.png'), isTrue);
    });

    test('nothing else counts as a plugin copy', () {
      for (final path in [
        '/data/user/0/app/files/server-chat.sqlite',
        '$cache/../files/server-chat.sqlite',
        '$cache/images/server/files/a.png',
        '$cache/$id/harbour.png',
        cache,
        '/storage/emulated/0/Download/harbour.png',
        'harbour.png',
      ]) {
        expect(isPluginCopy(cache, path), isFalse, reason: path);
      }
    });

    test('deleting shares never touches other files', () async {
      final root = await Directory.systemTemp.createTemp('copies');
      addTearDown(() => root.delete(recursive: true));
      final cacheDir = p.join(root.path, 'cache');
      final copy = File(p.join(cacheDir, 'harbour.png'))
        ..createSync(recursive: true);
      final database = File(p.join(root.path, 'files', 'server.sqlite'))
        ..createSync(recursive: true);
      final link = Link(p.join(cacheDir, 'innocent.png'))
        ..createSync(database.path);
      final avatar = File(p.join(cacheDir, 'images', 's', 'a.png'))
        ..createSync(recursive: true);

      await LocalCopies.deleteShared(cacheDir, [
        database.path,
        p.join(cacheDir, '..', 'files', 'server.sqlite'),
        link.path,
        avatar.path,
        copy.path,
      ]);

      expect(database.existsSync(), isTrue);
      expect(avatar.existsSync(), isTrue);
      expect(copy.existsSync(), isFalse);
    });
  });

  group('picker copies', () {
    test('each picker copy is deleted with its own folder', () {
      expect(
        pickerCopyOf(cache, '$cache/file_picker/1761400000000/plan.pdf'),
        '$cache/file_picker/1761400000000',
      );
      expect(pickerCopyOf(cache, '$cache/$id/IMG_0042.jpg'), '$cache/$id');
      expect(
        pickerCopyOf(cache, '$cache/${id}4417302921.jpg'),
        '$cache/${id}4417302921.jpg',
      );
    });

    test('files elsewhere are not picker copies', () {
      for (final path in [
        '$cache/images/server/files/a.png',
        '/storage/emulated/0/DCIM/IMG_0042.jpg',
      ]) {
        expect(pickerCopyOf(cache, path), isNull, reason: path);
      }
    });

    test('a cache folder is never deleted as a picker copy', () async {
      final root = await Directory.systemTemp.createTemp('copies');
      addTearDown(() => root.delete(recursive: true));
      final avatar = File(p.join(root.path, 'images', 's', 'a.png'))
        ..createSync(recursive: true);
      await LocalCopies.deletePicked(root.path, p.join(root.path, 'images'));
      expect(avatar.existsSync(), isTrue);
    });
  });

  group('start-up sweep', () {
    final now = DateTime(2026, 10, 26, 9);
    final old = now.subtract(const Duration(days: 1, minutes: 1));
    final fresh = now.subtract(const Duration(hours: 23));

    test('temporary copies older than a day go', () {
      for (final (path, isFile) in [
        ('$cache/harbour.png', true),
        ('$cache/$id', false),
        ('$cache/file_picker/1761400000000', false),
        ('$cache/handoff/file1', false),
        ('$cache/images/server-chat/handoff/file1', false),
      ]) {
        expect(
          isStaleCopy(cache, path, old, now, isFile: isFile),
          isTrue,
          reason: path,
        );
        expect(
          isStaleCopy(cache, path, fresh, now, isFile: isFile),
          isFalse,
          reason: path,
        );
      }
    });

    test('caches and other files stay however old they are', () {
      for (final path in [
        '$cache/images',
        '$cache/images/server-chat',
        '$cache/images/server-chat/files',
        '$cache/libCachedImageData',
        '/data/user/0/app/files/server-chat.sqlite',
      ]) {
        expect(
          isStaleCopy(cache, path, old, now, isFile: false),
          isFalse,
          reason: path,
        );
      }
      expect(
        isStaleCopy(
          cache,
          '/data/user/0/app/files/server-chat.sqlite',
          old,
          now,
          isFile: true,
        ),
        isFalse,
      );
    });
  });
}
