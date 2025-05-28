class Room {
  final String id;
  final String number;
  final String building;
  final int capacity;
  final String type; // 'classroom', 'lab', 'auditorium'
  final List<String> equipment; // 'projector', 'computer', 'whiteboard', etc.
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Room({
    required this.id,
    required this.number,
    required this.building,
    required this.capacity,
    required this.type,
    this.equipment = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      number: json['number'] as String,
      building: json['building'] as String,
      capacity: json['capacity'] as int,
      type: json['type'] as String,
      equipment: List<String>.from(json['equipment'] ?? []),
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
      'number': number,
      'building': building,
      'capacity': capacity,
      'type': type,
      'equipment': equipment,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get typeDisplayName {
    switch (type) {
      case 'classroom':
        return 'Sala de Aula';
      case 'lab':
        return 'Laboratório';
      case 'auditorium':
        return 'Auditório';
      default:
        return type;
    }
  }

  String get fullName => 'Sala $number - $building';
} 