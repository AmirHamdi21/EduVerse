import 'package:equatable/equatable.dart';

class RegistrationAvailableSectionModel extends Equatable {
  final int id;
  final String sectionNumber;
  final int maxCapacity;
  final int currentEnrollment;
  final int availableSeats;
  final String? location;
  final int semesterId;
  final String semesterName;

  const RegistrationAvailableSectionModel({
    required this.id,
    required this.sectionNumber,
    required this.maxCapacity,
    required this.currentEnrollment,
    required this.availableSeats,
    required this.location,
    required this.semesterId,
    required this.semesterName,
  });

  factory RegistrationAvailableSectionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final int parsedMaxCapacity = _parseInt(json['maxCapacity']);
    final int parsedCurrentEnrollment = _parseInt(json['currentEnrollment']);
    final int parsedAvailableSeats = json['availableSeats'] == null
        ? (parsedMaxCapacity - parsedCurrentEnrollment)
        : _parseInt(json['availableSeats']);

    return RegistrationAvailableSectionModel(
      id: _parseInt(json['id']),
      sectionNumber: json['sectionNumber']?.toString() ?? '',
      maxCapacity: parsedMaxCapacity,
      currentEnrollment: parsedCurrentEnrollment,
      availableSeats: parsedAvailableSeats,
      location: json['location']?.toString(),
      semesterId: _parseInt(json['semesterId']),
      semesterName: json['semesterName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sectionNumber': sectionNumber,
      'maxCapacity': maxCapacity,
      'currentEnrollment': currentEnrollment,
      'availableSeats': availableSeats,
      'location': location,
      'semesterId': semesterId,
      'semesterName': semesterName,
    };
  }

  bool get isFull => availableSeats <= 0;

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    sectionNumber,
    maxCapacity,
    currentEnrollment,
    availableSeats,
    location,
    semesterId,
    semesterName,
  ];
}
