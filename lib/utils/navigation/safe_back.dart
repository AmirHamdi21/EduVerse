import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void safeBack<T>(BuildContext context, String fallbackRoute, [T? result]) {
  if (context.canPop()) {
    context.pop<T>(result);
    return;
  }
  context.go(fallbackRoute);
}

IconData iosBackIcon(BuildContext context) {
  return Directionality.of(context) == TextDirection.rtl
      ? Icons.arrow_forward_ios_rounded
      : Icons.arrow_back_ios_new_rounded;
}
