import 'package:equatable/equatable.dart';

import 'drive_file_model.dart';

class LabInstructionModel extends Equatable {
  final int id;
  final int labId;
  final String? instructionText;
  final int? fileId;
  final DriveFileModel? file;
  final int orderIndex;
  final DateTime? createdAt;

  const LabInstructionModel({
    required this.id,
    required this.labId,
    this.instructionText,
    this.fileId,
    this.file,
    required this.orderIndex,
    this.createdAt,
  });

  factory LabInstructionModel.fromJson(Map<String, dynamic> json) {
    final rawFile = json['file'];

    return LabInstructionModel(
      id: _parseInt(json['id']),
      labId: _parseInt(json['labId']),
      instructionText: json['instructionText']?.toString(),
      fileId: _parseNullableInt(json['fileId']),
      file: rawFile is Map<String, dynamic>
          ? DriveFileModel.fromJson(rawFile)
          : null,
      orderIndex: _parseInt(json['orderIndex']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'labId': labId,
      'instructionText': instructionText,
      'fileId': fileId,
      'file': file?.toJson(),
      'orderIndex': orderIndex,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    labId,
    instructionText,
    fileId,
    file,
    orderIndex,
    createdAt,
  ];
}
