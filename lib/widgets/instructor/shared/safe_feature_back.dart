import 'package:flutter/widgets.dart';
import '../../../utils/navigation/safe_back.dart';

void safeFeatureBack<T>(
  BuildContext context,
  String fallbackRoute, [
  T? result,
]) {
  safeBack(context, fallbackRoute, result);
}

IconData safeFeatureBackIcon(BuildContext context) => iosBackIcon(context);
