import 'package:flutter_test/flutter_test.dart';

import 'package:edu_verse/utils/file_validator.dart';

void main() {
  group('FileValidator.validate', () {
    test('accepts valid document under size limit', () {
      final result = FileValidator.validate(
        fileName: 'lecture.pdf',
        fileSizeBytes: 1024 * 1024,
        kind: FileValidationKind.document,
        mimeType: 'application/pdf',
      );

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('rejects oversized document', () {
      final result = FileValidator.validate(
        fileName: 'book.pdf',
        fileSizeBytes: FileValidator.maxDocumentBytes + 1,
        kind: FileValidationKind.document,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('50MB'));
    });

    test('rejects unsupported document extension', () {
      final result = FileValidator.validate(
        fileName: 'archive.zip',
        fileSizeBytes: 2048,
        kind: FileValidationKind.document,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Unsupported document type'));
    });

    test('accepts valid image and rejects wrong image mime', () {
      final valid = FileValidator.validate(
        fileName: 'diagram.png',
        fileSizeBytes: 1024,
        kind: FileValidationKind.image,
        mimeType: 'image/png',
      );
      final invalidMime = FileValidator.validate(
        fileName: 'diagram.png',
        fileSizeBytes: 1024,
        kind: FileValidationKind.image,
        mimeType: 'application/octet-stream',
      );

      expect(valid.isValid, isTrue);
      expect(invalidMime.isValid, isFalse);
      expect(invalidMime.errorMessage, contains('Invalid image MIME type'));
    });

    test('video has no client-side size cap but validates mime prefix', () {
      final hugeVideo = FileValidator.validate(
        fileName: 'long-lecture.mp4',
        fileSizeBytes: 5 * 1024 * 1024 * 1024,
        kind: FileValidationKind.video,
        mimeType: 'video/mp4',
      );
      final wrongMime = FileValidator.validate(
        fileName: 'long-lecture.mp4',
        fileSizeBytes: 100,
        kind: FileValidationKind.video,
        mimeType: 'application/mp4',
      );

      expect(hugeVideo.isValid, isTrue);
      expect(wrongMime.isValid, isFalse);
      expect(wrongMime.errorMessage, contains('Invalid video MIME type'));
    });
  });
}
