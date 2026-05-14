import 'package:flutter/widgets.dart';
import '../../../utils/navigation/safe_back.dart';

void safeFeatureBack<T>(
  BuildContext context,
  String fallbackRoute, [
  T? result,
]) {
  final resolvedFallback = fallbackRoute.startsWith('/instructor/')
      ? '/instructor/dashboard'
      : fallbackRoute;
  safeBack(context, resolvedFallback, result);
}

IconData safeFeatureBackIcon(BuildContext context) => iosBackIcon(context);
