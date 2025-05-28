class Course {
  final String id;
  final String name;
  final String code;
  final int totalSemesters;
  final String shift; // 'morning', 'afternoon', 'evening', 'full'
  final String coordinator;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.totalSemesters,
    required this.shift,
    required this.coordinator,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      totalSemesters: json['total_semesters'] as int,
      shift: json['shift'] as String,
      coordinator: json['coordinator'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'total_semesters': totalSemesters,
      'shift': shift,
      'coordinator': coordinator,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get shiftDisplayName {
    switch (shift) {
      case 'morning':
        return 'Matutino';
      case 'afternoon':
        return 'Vespertino';
      case 'evening':
        return 'Noturno';
      case 'full':
        return 'Integral';
      default:
        return shift;
    }
  }
} 