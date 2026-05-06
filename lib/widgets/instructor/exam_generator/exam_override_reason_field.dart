import 'package:flutter/material.dart';

import '../../../generated_l10n/app_localizations.dart';

class ExamOverrideReasonField extends StatelessWidget {
  const ExamOverrideReasonField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: 4,
      decoration: InputDecoration(labelText: l10n.examOverrideReason),
    );
  }
}
