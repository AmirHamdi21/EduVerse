import 'package:edu_verse/features/walkthrough/walkthrough_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughCompletionService {
  static const String version = 'v1';

  const WalkthroughCompletionService();

  Future<bool> isCompleted(WalkthroughRole role, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey(role, userId)) ?? false;
  }

  Future<void> markCompleted(WalkthroughRole role, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey(role, userId), true);
  }

  String _completedKey(WalkthroughRole role, int userId) {
    return 'walkthrough.${role.name}.$version.user_$userId.completed';
  }
}
