import 'package:flutter_test/flutter_test.dart';
import 'package:master_service/features/map/application/map_marker_utils.dart';

void main() {
  test('clientInitialFromName uses first name initial', () {
    expect(clientInitialFromName('Merdan Ataýew'), 'M');
    expect(clientInitialFromName('  anna '), 'A');
  });

  test('clientInitialFromName falls back when name is empty', () {
    expect(clientInitialFromName(''), '?');
    expect(clientInitialFromName('   '), '?');
  });
}
