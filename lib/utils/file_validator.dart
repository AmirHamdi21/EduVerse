class FileValidationResult {
  final bool isValid;
  final String? errorMessage;

  const FileValidationResult._({required this.isValid, this.errorMessage});

  const FileValidationResult.valid() : this._(isValid: true);

  const FileValidationResult.invalid(String message)
    : this._(isValid: false, errorMessage: message);
}

enum FileValidationKind { document, image, video }

class FileValidator {
  const FileValidator._();

  static const int maxDocumentBytes = 50 * 1024 * 1024;
  static const int maxImageBytes = 10 * 1024 * 1024;

  static const Set<String> _documentExtensions = <String>{
    'pdf',
    'docx',
    'pptx',
    'xlsx',
  };

  static const Set<String> _imageExtensions = <String>{
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  };

  static FileValidationResult validate({
    required String fileName,
    required int fileSizeBytes,
    required FileValidationKind kind,
    String? mimeType,
  }) {
    final ext = _extractExtension(fileName);

    switch (kind) {
      case FileValidationKind.document:
        if (fileSizeBytes > maxDocumentBytes) {
          return const FileValidationResult.invalid(
            'Document exceeds 50MB limit.',
          );
        }

        if (!_documentExtensions.contains(ext)) {
          return const FileValidationResult.invalid(
            'Unsupported document type. Allowed: pdf, docx, pptx, xlsx.',
          );
        }

        if (mimeType != null &&
            mimeType.isNotEmpty &&
            !mimeType.toLowerCase().contains('application')) {
          return const FileValidationResult.invalid(
            'Invalid document MIME type.',
          );
        }

        return const FileValidationResult.valid();

      case FileValidationKind.image:
        if (fileSizeBytes > maxImageBytes) {
          return const FileValidationResult.invalid(
            'Image exceeds 10MB limit.',
          );
        }

        if (!_imageExtensions.contains(ext)) {
          return const FileValidationResult.invalid(
            'Unsupported image type. Allowed: jpg, png, gif, webp.',
          );
        }

        if (mimeType != null &&
            mimeType.isNotEmpty &&
            !mimeType.toLowerCase().startsWith('image/')) {
          return const FileValidationResult.invalid('Invalid image MIME type.');
        }

        return const FileValidationResult.valid();

      case FileValidationKind.video:
        // No client-side file-size limit for video by requirement.
        if (mimeType != null &&
            mimeType.isNotEmpty &&
            !mimeType.toLowerCase().startsWith('video/')) {
          return const FileValidationResult.invalid('Invalid video MIME type.');
        }
        return const FileValidationResult.valid();
    }
  }

  static String _extractExtension(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index < 0 || index == fileName.length - 1) {
      return '';
    }
    return fileName.substring(index + 1).toLowerCase();
  }
}
