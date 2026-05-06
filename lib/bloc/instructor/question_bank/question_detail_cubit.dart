import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/question_bank/question_bank_enums.dart';
import '../../../services/api/question_bank_service.dart';
import 'question_detail_state.dart';

class QuestionDetailCubit extends Cubit<QuestionDetailState> {
  QuestionDetailCubit({required QuestionBankService questionBankService})
      : _questionBankService = questionBankService,
        super(const QuestionDetailState());

  final QuestionBankService _questionBankService;

  Future<void> load(int questionId) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearAction: true));
    final result = await _questionBankService.getQuestion(questionId);
    if (!result.isSuccess || result.data == null) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: result.error?.message ?? 'questionLoadFailed',
      ));
      return;
    }
    emit(state.copyWith(isLoading: false, question: result.data, clearError: true));
  }

  Future<void> statusAction(String action) async {
    final question = state.question;
    if (question == null) return;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.statusAction(
      questionId: question.id,
      action: action,
    );
    if (!result.isSuccess || result.data == null) {
      emit(state.copyWith(
        isMutating: false,
        errorMessage: result.error?.message ?? 'questionStatusFailed',
      ));
      return;
    }
    emit(state.copyWith(
      isMutating: false,
      question: result.data,
      actionMessage: 'questionUpdated',
    ));
  }

  Future<bool> deleteQuestion() async {
    final question = state.question;
    if (question == null) return false;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.deleteQuestion(question.id);
    if (!result.isSuccess) {
      emit(state.copyWith(
        isMutating: false,
        errorMessage: result.error?.message ?? 'questionDeleteFailed',
      ));
      return false;
    }
    emit(state.copyWith(isMutating: false, actionMessage: 'questionDeleted'));
    return true;
  }

  Future<void> addAttachmentByFileId({
    required int fileId,
    QuestionAttachmentType attachmentType = QuestionAttachmentType.image,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  }) async {
    final question = state.question;
    if (question == null) return;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.addAttachment(
      questionId: question.id,
      fileId: fileId,
      attachmentType: attachmentType,
      caption: caption,
      altText: altText,
      displayOrder: displayOrder,
      isPrimary: isPrimary,
    );
    if (!result.isSuccess) {
      emit(state.copyWith(
        isMutating: false,
        errorMessage: result.error?.message ?? 'attachmentAddFailed',
      ));
      return;
    }
    await load(question.id);
    emit(state.copyWith(isMutating: false, actionMessage: 'attachmentUpdated'));
  }

  Future<void> uploadAttachmentImage(String path) async {
    final question = state.question;
    if (question == null) return;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.uploadAttachmentImage(
      questionId: question.id,
      path: path,
    );
    if (!result.isSuccess) {
      emit(state.copyWith(
        isMutating: false,
        errorMessage: result.error?.message ?? 'attachmentUploadFailed',
      ));
      return;
    }
    await load(question.id);
    emit(state.copyWith(isMutating: false, actionMessage: 'attachmentUpdated'));
  }

  Future<void> updateAttachment({
    required int attachmentId,
    String? caption,
    String? altText,
    int? displayOrder,
    bool? isPrimary,
  }) async {
    final question = state.question;
    if (question == null) return;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.updateAttachment(
      questionId: question.id,
      attachmentId: attachmentId,
      caption: caption,
      altText: altText,
      displayOrder: displayOrder,
      isPrimary: isPrimary,
    );
    if (!result.isSuccess) {
      emit(state.copyWith(
        isMutating: false,
        errorMessage: result.error?.message ?? 'attachmentUpdateFailed',
      ));
      return;
    }
    await load(question.id);
    emit(state.copyWith(isMutating: false, actionMessage: 'attachmentUpdated'));
  }

  Future<void> reorderAttachments(List<int> orderedAttachmentIds) async {
    final question = state.question;
    if (question == null) return;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.reorderAttachments(
      questionId: question.id,
      items: [
        for (var i = 0; i < orderedAttachmentIds.length; i++)
          {'attachmentId': orderedAttachmentIds[i], 'displayOrder': i},
      ],
    );
    if (!result.isSuccess) {
      emit(state.copyWith(
        isMutating: false,
        errorMessage: result.error?.message ?? 'attachmentReorderFailed',
      ));
      return;
    }
    await load(question.id);
    emit(state.copyWith(isMutating: false, actionMessage: 'attachmentUpdated'));
  }

  Future<void> removeAttachment(int attachmentId) async {
    final question = state.question;
    if (question == null) return;
    emit(state.copyWith(isMutating: true, clearError: true, clearAction: true));
    final result = await _questionBankService.removeAttachment(
      questionId: question.id,
      attachmentId: attachmentId,
    );
    if (!result.isSuccess) {
      emit(state.copyWith(
        isMutating: false,
        errorMessage: result.error?.message ?? 'attachmentRemoveFailed',
      ));
      return;
    }
    await load(question.id);
    emit(state.copyWith(isMutating: false, actionMessage: 'attachmentRemoved'));
  }
}
