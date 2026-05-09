import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

void safeFeatureBack(BuildContext context, String fallbackRoute) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(fallbackRoute);
}
