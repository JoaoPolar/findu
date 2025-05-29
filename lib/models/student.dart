import 'package:uuid/uuid.dart';

class Student {
  final String id;
  final String name;
  final String email;
  final String courseId;
  final int semester;
  final String shift; // "morning", "afternoon", "evening", "full"
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Student({
    String? id,
    required this.name,
    required this.email,
    required this.courseId,
    required this.semester,
    required this.shift,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
  
  // Converter de JSON para Student
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      courseId: json['course_id'] ?? json['courseId'],
      semester: json['semester'],
      shift: json['shift'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
  
  // Converter de Student para JSON
  Map<String, dynamic> toJson({bool forDatabase = false}) {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'course_id': courseId,
      'semester': semester,
      'shift': shift,
      'is_active': isActive,
    };

    // Só incluir o ID se não for para criação no banco
    if (forDatabase && id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
  }
  
  // Criar uma cópia com alguns atributos alterados
  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? courseId,
    int? semester,
    String? shift,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      courseId: courseId ?? this.courseId,
      semester: semester ?? this.semester,
      shift: shift ?? this.shift,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get shiftDisplayName {
    switch (shift) {
      case 'morning': return 'Matutino';
      case 'afternoon': return 'Vespertino';
      case 'evening': return 'Noturno';
      case 'full': return 'Integral';
      default: return shift;
    }
  }
} 