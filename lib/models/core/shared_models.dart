import 'package:equatable/equatable.dart';

class CourseInfo extends Equatable {
  final int id;
  final String name;
  final String code;

  const CourseInfo({required this.id, required this.name, required this.code});

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      code: _parseString(json['code']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name, 'code': code};
  }

  @override
  List<Object?> get props => <Object?>[id, name, code];
}

class UserInfo extends Equatable {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;

  const UserInfo({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: _parseInt(json['userId'] ?? json['user_id']),
      firstName: _parseString(json['firstName'] ?? json['first_name']),
      lastName: _parseString(json['lastName'] ?? json['last_name']),
      email: _parseString(json['email']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  @override
  List<Object?> get props => <Object?>[userId, firstName, lastName, email];
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _parseString(dynamic value) {
  return value?.toString() ?? '';
}
