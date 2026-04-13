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
