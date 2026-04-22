class AdminManagedCourse {
  final int id;
  final int departmentId;
  final String code;
  final String name;
  final String description;
  final String? syllabusUrl;
  final String department;
  final String semester;
  final int credits;
  final int enrolled;
  final int capacity;
  final String status;
  final String level;
  final int instructorId;
  final String instructorName;
  final List<int> taIds;
  final List<String> taNames;
  final List<String> prerequisites;
  final int? sectionId;
  final String sectionNumber;
  final String location;
  final int semesterId;
  final String scheduleDay;
  final String startTime;
  final String endTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminManagedCourse({
    required this.id,
    required this.departmentId,
    required this.code,
    required this.name,
    required this.description,
    required this.syllabusUrl,
    required this.department,
    required this.semester,
    required this.credits,
    required this.enrolled,
    required this.capacity,
    required this.status,
    required this.level,
    required this.instructorId,
    required this.instructorName,
    required this.taIds,
    required this.taNames,
    required this.prerequisites,
    required this.sectionId,
    required this.sectionNumber,
    required this.location,
    required this.semesterId,
    required this.scheduleDay,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  AdminManagedCourse copyWith({
    int? id,
    int? departmentId,
    String? code,
    String? name,
    String? description,
    String? syllabusUrl,
    bool clearSyllabusUrl = false,
    String? department,
    String? semester,
    int? credits,
    int? enrolled,
    int? capacity,
    String? status,
    String? level,
    int? instructorId,
    String? instructorName,
    List<int>? taIds,
    List<String>? taNames,
    List<String>? prerequisites,
    int? sectionId,
    bool clearSectionId = false,
    String? sectionNumber,
    String? location,
    int? semesterId,
    String? scheduleDay,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminManagedCourse(
      id: id ?? this.id,
      departmentId: departmentId ?? this.departmentId,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      syllabusUrl: clearSyllabusUrl ? null : (syllabusUrl ?? this.syllabusUrl),
      department: department ?? this.department,
      semester: semester ?? this.semester,
      credits: credits ?? this.credits,
      enrolled: enrolled ?? this.enrolled,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      level: level ?? this.level,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      taIds: taIds ?? this.taIds,
      taNames: taNames ?? this.taNames,
      prerequisites: prerequisites ?? this.prerequisites,
      sectionId: clearSectionId ? null : (sectionId ?? this.sectionId),
      sectionNumber: sectionNumber ?? this.sectionNumber,
      location: location ?? this.location,
      semesterId: semesterId ?? this.semesterId,
      scheduleDay: scheduleDay ?? this.scheduleDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get enrollmentPercent {
    if (capacity <= 0) {
      return 0;
    }
    final percent = (enrolled / capacity) * 100;
    if (percent < 0) {
      return 0;
    }
    if (percent > 100) {
      return 100;
    }
    return percent;
  }
}

class AdminStaffOption {
  final int id;
  final String name;
  final String role;
  final String department;

  const AdminStaffOption({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
  });
}

class AdminSemesterOption {
  final int id;
  final String name;

  const AdminSemesterOption({required this.id, required this.name});
}

class AdminDepartmentOption {
  final int id;
  final String name;
  final String code;

  const AdminDepartmentOption({
    required this.id,
    required this.name,
    required this.code,
  });
}
