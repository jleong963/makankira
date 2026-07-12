import 'package:flutter_test/flutter_test.dart';
import 'package:makankira/shared/countries.dart';

void main() {
  test('parsePhone splits a stored number by the longest matching dial code', () {
    var p = parsePhone('60123456789');
    expect(p.country.iso, 'MY');
    expect(p.national, '123456789');

    p = parsePhone('6591234567');
    expect(p.country.iso, 'SG');
    expect(p.national, '91234567');

    // '+' and separators are ignored.
    p = parsePhone('+60 12-345 6789');
    expect(p.country.iso, 'MY');
    expect(p.national, '123456789');
  });

  test('parsePhone resolves shared dial codes to the designated primary', () {
    // +1 is US and CA; the primary is US so a round-trip stays stable.
    final p = parsePhone('12025550123');
    expect(p.country.iso, 'US');
    expect(p.national, '2025550123');
  });

  test('parsePhone falls back to Malaysia for blank / null', () {
    expect(parsePhone('').country.iso, 'MY');
    expect(parsePhone(null).country.iso, 'MY');
    expect(parsePhone('').national, '');
  });
}
