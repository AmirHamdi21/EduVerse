import 'dart:math' as math;

class LatePenaltyResult {
  const LatePenaltyResult({
    required this.daysLate,
    required this.latePenaltyPercent,
    required this.penaltyAmount,
    required this.finalScore,
  });

  final int daysLate;
  final double latePenaltyPercent;
  final double penaltyAmount;
  final double finalScore;
}

LatePenaltyResult calculateLabLatePenalty({
  required DateTime submittedAt,
  required DateTime dueDate,
  required double maxScore,
  double penaltyRatePerDay = 10.0,
}) {
  if (!submittedAt.isAfter(dueDate)) {
    return LatePenaltyResult(
      daysLate: 0,
      latePenaltyPercent: 0,
      penaltyAmount: 0,
      finalScore: maxScore.clamp(0, double.infinity),
    );
  }

  final difference = submittedAt.difference(dueDate);
  final rawDaysLate = (difference.inMinutes / Duration.minutesPerDay).ceil();
  final daysLate = rawDaysLate < 0 ? 0 : rawDaysLate;
  final latePenaltyPercent = (daysLate * penaltyRatePerDay)
      .clamp(0, 100)
      .toDouble();
  final penaltyAmount = (maxScore * (latePenaltyPercent / 100)).toDouble();
  final finalScore = math.max(0, maxScore - penaltyAmount).toDouble();

  return LatePenaltyResult(
    daysLate: daysLate,
    latePenaltyPercent: latePenaltyPercent,
    penaltyAmount: penaltyAmount,
    finalScore: finalScore,
  );
}

double calculateFinalScore({
  required double originalScore,
  required double latePenaltyPercent,
  required int daysLate,
}) {
  final penaltyFactor = 1 - ((latePenaltyPercent * daysLate) / 100);
  final finalScore = originalScore * penaltyFactor;

  if (finalScore < 0) {
    return 0;
  }

  if (finalScore > originalScore) {
    return originalScore;
  }

  return finalScore;
}
