import 'package:edu_verse/bloc/instructor/question_bank/question_bulk_create_cubit.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/question_bank_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('question bulk create cubit starts with one editable row', () {
    final cubit = QuestionBulkCreateCubit(
      questionBankService: QuestionBankService(coreApiClient: CoreApiClient.test()),
      enrollmentService: EnrollmentService(coreApiClient: CoreApiClient.test()),
    );

    expect(cubit.state.rows, hasLength(1));
    expect(cubit.state.rows.single.localId, 1);

    cubit.close();
  });
}
