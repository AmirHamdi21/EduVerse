import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCompletionService {
  const OnboardingCompletionService();

  static const String onboardingV6CompletedKey = 'onboarding_v6_completed';

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingV6CompletedKey) ?? false;
  }

  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingV6CompletedKey, true);
  }
}
