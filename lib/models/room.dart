import 'package:uuid/uuid.dart';

class Room {
  final String id;
  final String number;
  final String building;
  final int capacity;
  final String type;
  final List<String> equipment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Room({
    String? id,
    required this.number,
    required this.building,
    required this.capacity,
    this.type = 'classroom',
    this.equipment = const [],
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      number: json['number'],
      building: json['building'],
      capacity: json['capacity'],
      type: json['type'] ?? 'classroom',
      equipment: json['equipment'] != null 
          ? List<String>.from(json['equipment'])
          : [],
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
      'number': number,
      'building': building,
      'capacity': capacity,
      'type': type,
      'equipment': equipment,
      'is_active': isActive,
    };

    // Só incluir o ID se não for para criação no banco
    if (forDatabase && id.isNotEmpty) {
      data['id'] = id;
    }

    return data;
  }

  String get typeDisplayName {
    switch (type) {
      case 'classroom': return 'Sala de Aula';
      case 'lab': return 'Laboratório';
      case 'auditorium': return 'Auditório';
      case 'library': return 'Biblioteca';
      default: return type;
    }
  }

  String get equipmentDisplayText {
    if (equipment.isEmpty) return 'Sem equipamentos';
    
    final equipmentNames = equipment.map((e) {
      switch (e) {
        case 'projector': return 'Projetor';
        case 'whiteboard': return 'Quadro Branco';
        case 'air_conditioning': return 'Ar Condicionado';
        case 'computer': return 'Computador';
        case 'sound_system': return 'Som';
        case 'microphone': return 'Microfone';
        default: return e;
      }
    }).toList();
    
    return equipmentNames.join(', ');
  }

  Room copyWith({
    String? id,
    String? number,
    String? building,
    int? capacity,
    String? type,
    List<String>? equipment,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      number: number ?? this.number,
      building: building ?? this.building,
      capacity: capacity ?? this.capacity,
      type: type ?? this.type,
      equipment: equipment ?? this.equipment,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}