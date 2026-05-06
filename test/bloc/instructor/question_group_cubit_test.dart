import 'package:edu_verse/bloc/instructor/question_bank/question_group_cubit.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/question_bank_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('question group cubit starts with no loaded group', () {
    final cubit = QuestionGroupCubit(
      questionBankService: QuestionBankService(coreApiClient: CoreApiClient.test()),
    );

    expect(cubit.state.group, isNull);
    expect(cubit.state.questions, isEmpty);

    cubit.close();
  });
}
