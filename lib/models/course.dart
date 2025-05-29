import 'package:uuid/uuid.dart';

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
    String? id,
    required this.name,
    required this.code,
    required this.totalSemesters,
    required this.shift,
    required this.coordinator,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      totalSemesters: json['total_semesters'] ?? json['totalSemesters'] ?? 8,
      shift: json['shift'],
      coordinator: json['coordinator'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson({bool forDatabase = false}) {
    final data = <String, dynamic>{
      'name': name,
      'code': code,
      'total_semesters': totalSemesters,
      'shift': shift,
      'coordinator': coordinator,
      'is_active': isActive,
    };

    // Só incluir o ID se não for para criação no banco
    if (forDatabase && id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
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

  Course copyWith({
    String? id,
    String? name,
    String? code,
    int? totalSemesters,
    String? shift,
    String? coordinator,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      totalSemesters: totalSemesters ?? this.totalSemesters,
      shift: shift ?? this.shift,
      coordinator: coordinator ?? this.coordinator,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 