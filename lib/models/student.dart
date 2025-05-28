class Student {
  final String id;
  final String name;
  final String email;
  final String course;
  final int semester;
  final String shift; // "Manhã", "Tarde", "Noite", "Integral"
  final List<String> enrolledClasses; // IDs das disciplinas matriculadas
  
  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.course,
    required this.semester,
    required this.shift,
    required this.enrolledClasses,
  });
  
  // Converter de JSON para Student
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      course: json['course'],
      semester: json['semester'],
      shift: json['shift'],
      enrolledClasses: List<String>.from(json['enrolledClasses']),
    );
  }
  
  // Converter de Student para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'course': course,
      'semester': semester,
      'shift': shift,
      'enrolledClasses': enrolledClasses,
    };
  }
  
  // Criar uma cópia com alguns atributos alterados
  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? course,
    int? semester,
    String? shift,
    List<String>? enrolledClasses,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      course: course ?? this.course,
      semester: semester ?? this.semester,
      shift: shift ?? this.shift,
      enrolledClasses: enrolledClasses ?? this.enrolledClasses,
    );
  }
} 