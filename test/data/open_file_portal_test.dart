import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/files/open_file_portal.dart';

void main() {
  test('the portal answers 0 for opened, 1 for a closed chooser', () {
    expect(portalOutcome(0), PortalOutcome.opened);
    expect(portalOutcome(1), PortalOutcome.dismissed);
  });

  test('any other answer is a failure the person is told about', () {
    expect(portalOutcome(2), PortalOutcome.failed);
    expect(portalOutcome(7), PortalOutcome.failed);
  });

  test('the request path follows the portal convention for the sender', () {
    expect(
      portalRequestPath(':1.42', 'tok'),
      '/org/freedesktop/portal/desktop/request/1_42/tok',
    );
  });
}
