import 'package:edu_verse/bloc/instructor/question_bank/question_detail_cubit.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/question_bank_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('question detail cubit starts idle', () {
    final cubit = QuestionDetailCubit(
      questionBankService: QuestionBankService(coreApiClient: CoreApiClient.test()),
    );

    expect(cubit.state.isLoading, isFalse);
    expect(cubit.state.question, isNull);

    cubit.close();
  });
}
