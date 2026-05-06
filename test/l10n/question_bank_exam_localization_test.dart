import 'package:edu_verse/generated_l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('question bank and exam generator labels exist in English and Arabic', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));

    expect(en.questionBank, isNotEmpty);
    expect(en.examGenerator, isNotEmpty);
    expect(en.qbManageChapters, isNotEmpty);
    expect(en.examGenerateDraft, isNotEmpty);
    expect(ar.questionBank, isNotEmpty);
    expect(ar.examGenerator, isNotEmpty);
    expect(ar.qbManageChapters, isNotEmpty);
    expect(ar.examGenerateDraft, isNotEmpty);
  });
}
