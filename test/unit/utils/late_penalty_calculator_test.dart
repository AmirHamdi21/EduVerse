import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/utils/late_penalty_calculator.dart';

void main() {
  group('calculateFinalScore', () {
    test('returns original score when daysLate is zero', () {
      final result = calculateFinalScore(
        originalScore: 90,
        latePenaltyPercent: 10,
        daysLate: 0,
      );

      expect(result, 90);
    });

    test('applies one-day late penalty correctly', () {
      final result = calculateFinalScore(
        originalScore: 80,
        latePenaltyPercent: 10,
        daysLate: 1,
      );

      expect(result, 72);
    });

    test('applies multi-day penalty and clamps to zero minimum', () {
      final result = calculateFinalScore(
        originalScore: 75,
        latePenaltyPercent: 30,
        daysLate: 4,
      );

      expect(result, 0);
    });

    test('supports zero penalty and preserves original score', () {
      final result = calculateFinalScore(
        originalScore: 64,
        latePenaltyPercent: 0,
        daysLate: 6,
      );

      expect(result, 64);
    });

    test('100 percent one-day penalty returns zero', () {
      final result = calculateFinalScore(
        originalScore: 55,
        latePenaltyPercent: 100,
        daysLate: 1,
      );

      expect(result, 0);
    });
  });
}
