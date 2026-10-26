import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/data/images/server_image_caches.dart';

void main() {
  final now = DateTime.utc(2026, 10, 25, 12);
  const mb = 1024 * 1024;

  group('eviction', () {
    CachedImage image(int id, {required int daysAgo, int bytes = mb}) =>
        (id: id, bytes: bytes, lastUsed: now.subtract(Duration(days: daysAgo)));

    test('identity images stay however many there are until unused for 60 '
        'days', () {
      final images = [
        for (var i = 0; i < 5000; i++) image(i, daysAgo: i % 60),
        image(9000, daysAgo: 61),
      ];
      expect(
        imagesToEvict(
          images,
          now: now,
          maxIdle: ServerImageCaches.identityMaxIdle,
        ),
        {9000},
      );
    });

    test('media over the budget loses the least recently shown first', () {
      final images = [
        image(1, daysAgo: 5),
        image(2, daysAgo: 0),
        image(3, daysAgo: 9),
        image(4, daysAgo: 1),
      ];
      expect(
        imagesToEvict(
          images,
          now: now,
          maxIdle: ServerImageCaches.mediaMaxIdle,
          budgetBytes: 2 * mb,
        ),
        {1, 3},
      );
    });

    test('media unused for 30 days goes even within the budget', () {
      expect(
        imagesToEvict(
          [image(1, daysAgo: 31, bytes: 10), image(2, daysAgo: 29, bytes: 10)],
          now: now,
          maxIdle: ServerImageCaches.mediaMaxIdle,
          budgetBytes: 250 * mb,
        ),
        {1},
      );
    });

    test('the repository answers the cleanup from that decision', () async {
      final inner = _MemoryRepository([
        _object(1, touched: now.subtract(const Duration(days: 2)), mb: 2),
        _object(2, touched: now, mb: 2),
        _object(3, touched: now.subtract(const Duration(days: 40)), mb: 1),
      ]);
      final repo = LastUseRepository(
        inner,
        maxIdle: ServerImageCaches.mediaMaxIdle,
        budget: () async => 3 * mb,
        clock: () => now,
      );
      final evicted = await repo.getObjectsOverCapacity(200);
      expect([for (final o in evicted) o.id], unorderedEquals([1, 3]));
    });
  });

  group('freshness', () {
    final server = Uri.parse('https://chat.example.test/team');

    test('file, emoji and versioned avatar images never go stale', () {
      for (final path in [
        'api/v4/files/f1/preview',
        'api/v4/files/f1',
        'api/v4/emoji/e1/image',
        'api/v4/users/u1/image?_=1700000000000',
        'api/v4/teams/t1/image?_=1700000000000',
      ]) {
        final url = Uri.parse('https://chat.example.test/team/$path');
        expect(
          imageValidUntil(url, server, now: now, cacheControl: 'max-age=60'),
          now.add(const Duration(days: 365)),
          reason: path,
        );
      }
    });

    test('other images follow the server\'s max-age', () {
      final unversioned = Uri.parse(
        'https://chat.example.test/team/api/v4/users/u1/image',
      );
      expect(
        imageValidUntil(
          unversioned,
          server,
          now: now,
          cacheControl: 'private, max-age=60',
        ),
        now.add(const Duration(seconds: 60)),
      );
      final elsewhere = Uri.parse(
        'https://images.example.test/api/v4/files/f1',
      );
      expect(
        imageValidUntil(elsewhere, server, now: now),
        now.add(const Duration(days: 7)),
      );
    });
  });

  group('where images come from', () {
    final server = Uri.parse('https://chat.example.test/team');

    test('relative paths resolve under the server\'s sub-path', () {
      expect(
        imageRequestUri('/static/bot.png', server, proxy: true).toString(),
        'https://chat.example.test/team/static/bot.png',
      );
    });

    test('other hosts go through the image proxy only when it is on', () {
      const external = 'https://pics.example.test/cat.png?s=1';
      expect(
        imageRequestUri(external, server, proxy: false),
        Uri.parse(external),
      );
      final proxied = imageRequestUri(external, server, proxy: true)!;
      expect(proxied.path, '/team/api/v4/image');
      expect(proxied.queryParameters['url'], external);
      const own = 'https://chat.example.test/team/api/v4/files/f1';
      expect(imageRequestUri(own, server, proxy: true), Uri.parse(own));
    });

    test('addresses no image can come from are refused, not thrown', () {
      for (final odd in [
        'file:///x',
        'data:image/png;base64,AAAA',
        'javascript:alert(1)',
        'http:///nohost.png',
        'http://[broken',
      ]) {
        expect(imageRequestUri(odd, server, proxy: true), isNull, reason: odd);
        expect(imageRequestUri(odd, server, proxy: false), isNull, reason: odd);
      }
    });
  });

  group('images on mobile data', () {
    test('with the setting off, mobile data waits for a tap', () {
      expect(
        loadsImagesAutomatically(
          onMobileData: false,
          connection: [ConnectivityResult.mobile],
        ),
        isFalse,
      );
      expect(
        loadsImagesAutomatically(
          onMobileData: false,
          connection: [ConnectivityResult.vpn, ConnectivityResult.mobile],
        ),
        isFalse,
      );
    });

    test('Wi-Fi, Ethernet or the setting on load at once', () {
      expect(
        loadsImagesAutomatically(
          onMobileData: false,
          connection: [ConnectivityResult.wifi, ConnectivityResult.mobile],
        ),
        isTrue,
      );
      expect(
        loadsImagesAutomatically(
          onMobileData: false,
          connection: [ConnectivityResult.ethernet],
        ),
        isTrue,
      );
      expect(
        loadsImagesAutomatically(
          onMobileData: true,
          connection: [ConnectivityResult.mobile],
        ),
        isTrue,
      );
    });
  });

  group('downloads', () {
    late HttpServer own;
    late HttpServer other;
    late ServerApi api;
    final seen = <String, String?>{};

    setUp(() async {
      Future<HttpServer> serve(String name) async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        server.listen((request) async {
          seen['$name ${request.uri.path}'] = request.headers.value(
            'authorization',
          );
          final size = request.uri.path.contains('big') ? 4096 : 16;
          request.response.headers
            ..contentType = ContentType('image', 'png')
            ..set('cache-control', 'max-age=60');
          if (request.uri.path.contains('unsized')) {
            request.response.headers.chunkedTransferEncoding = true;
          }
          request.response.add(List.filled(size, 7));
          await request.response.close();
        });
        return server;
      }

      own = await serve('own');
      other = await serve('other');
      api = ServerApi(
        baseUrl: Uri.parse('http://127.0.0.1:${own.port}'),
        token: () => 't0ken',
      );
    });

    tearDown(() async {
      api.close();
      await own.close(force: true);
      await other.close(force: true);
      seen.clear();
    });

    Future<int> download(FileService service, String url) async {
      final response = await service.get(url);
      var bytes = 0;
      await for (final chunk in response.content) {
        bytes += chunk.length;
      }
      return bytes;
    }

    test('the token goes to our server only', () async {
      final service = ServerFileService(api, maxBytes: 1024);
      await download(
        service,
        'http://127.0.0.1:${own.port}/api/v4/emoji/e1/image',
      );
      await download(service, 'http://127.0.0.1:${other.port}/cat.png');
      expect(seen['own /api/v4/emoji/e1/image'], 'Bearer t0ken');
      expect(seen.containsKey('other /cat.png'), isTrue);
      expect(seen['other /cat.png'], isNull);
    });

    test('an emoji image stays fresh past the server\'s max-age', () async {
      final service = ServerFileService(api, maxBytes: 1024, clock: () => now);
      final response = await service.get(
        'http://127.0.0.1:${own.port}/api/v4/emoji/e1/image',
      );
      expect(response.validTill, now.add(const Duration(days: 365)));
      expect(response.fileExtension, '.png');
      await response.content.drain<void>();
    });

    test('images over the size limit are refused', () async {
      final service = ServerFileService(api, maxBytes: 1024);
      await expectLater(
        download(service, 'http://127.0.0.1:${own.port}/big.png'),
        throwsA(isA<ImageTooLargeException>()),
      );
      await expectLater(
        download(service, 'http://127.0.0.1:${own.port}/big-unsized.png'),
        throwsA(isA<ImageTooLargeException>()),
      );
      expect(
        await download(service, 'http://127.0.0.1:${own.port}/small.png'),
        16,
      );
    });
  });
}

CacheObject _object(int id, {required DateTime touched, required int mb}) =>
    CacheObject(
      'https://chat.example.test/$id',
      relativePath: '$id.png',
      validTill: touched,
      id: id,
      length: mb * 1024 * 1024,
      touched: touched,
    );

class _MemoryRepository extends Fake implements CacheInfoRepository {
  _MemoryRepository(this.objects);

  final List<CacheObject> objects;

  @override
  Future<List<CacheObject>> getAllObjects() async => objects;
}
