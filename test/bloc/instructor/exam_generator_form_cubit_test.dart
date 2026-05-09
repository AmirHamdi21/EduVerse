import 'package:edu_verse/bloc/instructor/exam_generator/exam_generator_form_cubit.dart';
import 'package:edu_verse/models/exams/exam_generation_form_model.dart';
import 'package:edu_verse/services/api/core_api_client.dart';
import 'package:edu_verse/services/api/enrollment_service.dart';
import 'package:edu_verse/services/api/exam_generator_service.dart';
import 'package:edu_verse/services/api/question_bank_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exam generator form cubit starts in flat mode', () {
    final cubit = ExamGeneratorFormCubit(
      examGeneratorService: ExamGeneratorService(coreApiClient: CoreApiClient.test()),
      questionBankService: QuestionBankService(coreApiClient: CoreApiClient.test()),
      enrollmentService: EnrollmentService(coreApiClient: CoreApiClient.test()),
    );

    expect(cubit.state.mode, ExamGenerationMode.flat);
    expect(cubit.state.rules, isEmpty);

    cubit.close();
  });
}
