import 'package:flutter_test/flutter_test.dart';
import 'package:omnom/utils/formatters.dart';

void main() {
  group('avgRating', () {
    test('both ratings present → mean to 1 decimal', () {
      expect(avgRating(9, 8), '8.5');
      expect(avgRating(10, 10), '10.0');
      expect(avgRating(7, 7), '7.0');
    });

    test('only r1 → returns r1', () {
      expect(avgRating(8, null), '8');
    });

    test('only r2 → returns r2', () {
      expect(avgRating(null, 6), '6');
    });

    test('both null → null', () {
      expect(avgRating(null, null), isNull);
    });
  });

  group('avgRatingValue', () {
    test('returns mean when both present', () {
      expect(avgRatingValue(9, 8), 8.5);
    });

    test('returns single value when one present', () {
      expect(avgRatingValue(8, null), 8);
      expect(avgRatingValue(null, 7), 7);
    });

    test('returns -1 when neither present', () {
      expect(avgRatingValue(null, null), -1);
    });
  });

  group('fmtPrice', () {
    test('whole number → no decimals', () {
      expect(fmtPrice(8), '8kr');
    });

    test('fractional → 2 decimals', () {
      expect(fmtPrice(12.50), '12.50kr');
      expect(fmtPrice(4.5), '4.50kr');
    });

    test('null → null', () {
      expect(fmtPrice(null), isNull);
    });
  });

  group('fmtTime', () {
    test('null+null → null', () {
      expect(fmtTime(null, null), isNull);
      expect(fmtTime(0, 0), isNull);
    });

    test('< 60 → minutes', () {
      expect(fmtTime(40, null), '40m');
      expect(fmtTime(20, 10), '30m');
    });

    test('exact hours → "Xh"', () {
      expect(fmtTime(60, null), '1h');
      expect(fmtTime(120, null), '2h');
    });

    test('hours + minutes → "Xh Ym"', () {
      expect(fmtTime(35, 15), '50m');
      expect(fmtTime(60, 20), '1h 20m');
      expect(fmtTime(25, 480), '8h 25m');
    });
  });
}
