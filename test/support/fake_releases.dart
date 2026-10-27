import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Stands in for GitHub's releases API: answers every request with
/// [status] and [json], and records what was asked.
class FakeReleases implements HttpClientAdapter {
  FakeReleases({this.tag = 'v0.12.0', this.status = 200});

  String tag;
  int status;
  final requests = <Uri>[];

  Map<String, Object?> get json => {
    'tag_name': tag,
    'html_url': 'https://github.com/owner/app/releases/tag/$tag',
    'name': tag,
    'draft': false,
    'assets': [
      {'name': 'app.apk', 'size': 1234},
    ],
  };

  Dio get dio => Dio()..httpClientAdapter = this;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.uri);
    return ResponseBody.fromString(
      jsonEncode(status == 200 ? json : {'message': 'Not Found'}),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
