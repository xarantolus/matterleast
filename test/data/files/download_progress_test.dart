import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/files/file_downloads.dart';

void main() {
  test('the response length gives the fraction', () {
    final progress = DownloadProgress(999);
    expect(progress.report(25, 100), 0.25);
    expect(progress.report(100, 100), 1);
  });

  test('without a response length the file size is used', () {
    final progress = DownloadProgress(200);
    expect(progress.report(50, -1), 0.25);
  });

  test('no size anywhere is indeterminate', () {
    final progress = DownloadProgress(0);
    expect(progress.report(50, -1), isNull);
  });

  test('more bytes than claimed turns indeterminate and stays so', () {
    final progress = DownloadProgress(100);
    expect(progress.report(90, -1), 0.9);
    expect(progress.report(101, -1), isNull);
    expect(progress.report(102, -1), isNull);
  });
}
