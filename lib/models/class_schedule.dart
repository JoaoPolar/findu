import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum TimeSlot {
  morning1(1, 'Manhã 1º', '07:00 - 08:40'),
  morning2(2, 'Manhã 2º', '08:50 - 10:30'),
  afternoon1(3, 'Tarde 1º', '13:00 - 14:40'),
  afternoon2(4, 'Tarde 2º', '14:50 - 16:30'),
  evening1(5, 'Noite 1º', '19:00 - 20:40'),
  evening2(6, 'Noite 2º', '20:50 - 22:30');

  const TimeSlot(this.value, this.displayName, this.timeRange);
  
  final int value;
  final String displayName;
  final String timeRange;

  static TimeSlot fromValue(int value) {
    return TimeSlot.values.firstWhere(
      (slot) => slot.value == value,
      orElse: () => TimeSlot.morning1,
    );
  }

  String get shift {
    switch (this) {
      case TimeSlot.morning1:
      case TimeSlot.morning2:
        return 'morning';
      case TimeSlot.afternoon1:
      case TimeSlot.afternoon2:
        return 'afternoon';
      case TimeSlot.evening1:
      case TimeSlot.evening2:
        return 'evening';
    }
  }

  String get shiftDisplayName {
    switch (shift) {
      case 'morning': return 'Matutino';
      case 'afternoon': return 'Vespertino';
      case 'evening': return 'Noturno';
      default: return shift;
    }
  }
}

enum Day {
  monday(1, 'Segunda-feira', 'Seg'),
  tuesday(2, 'Terça-feira', 'Ter'),
  wednesday(3, 'Quarta-feira', 'Qua'),
  thursday(4, 'Quinta-feira', 'Qui'),
  friday(5, 'Sexta-feira', 'Sex'),
  saturday(6, 'Sábado', 'Sáb');

  const Day(this.value, this.displayName, this.shortName);
  
  final int value;
  final String displayName;
  final String shortName;

  static Day fromValue(int value) {
    return Day.values.firstWhere(
      (day) => day.value == value,
      orElse: () => Day.monday,
    );
  }
}

class ClassSchedule {
  final String id;
  final String courseId;
  final int semester;
  final String roomId;
  final Day day;
  final TimeSlot timeSlot;
  final bool isRecurring;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClassSchedule({
    String? id,
    required this.courseId,
    required this.semester,
    required this.roomId,
    required this.day,
    required this.timeSlot,
    this.isRecurring = true,
    this.startDate,
    this.endDate,
    DateTime? createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      id: json['id'],
      courseId: json['course_id'],
      semester: json['semester'],
      roomId: json['room_id'],
      day: Day.fromValue(json['day_of_week']),
      timeSlot: TimeSlot.fromValue(json['time_slot']),
      isRecurring: json['is_recurring'] ?? true,
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'course_id': courseId,
      'semester': semester,
      'room_id': roomId,
      'day_of_week': day.value,
      'time_slot': timeSlot.value,
      'is_recurring': isRecurring,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  String get timeDisplayText => '${timeSlot.displayName} (${timeSlot.timeRange})';
  
  String get dayTimeDisplay => '${day.shortName} - ${timeSlot.displayName}';

  // Para compatibilidade com código existente
  String get room => roomId;
  String get time => timeSlot.displayName;

  ClassSchedule copyWith({
    String? id,
    String? courseId,
    int? semester,
    String? roomId,
    Day? day,
    TimeSlot? timeSlot,
    bool? isRecurring,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassSchedule(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      semester: semester ?? this.semester,
      roomId: roomId ?? this.roomId,
      day: day ?? this.day,
      timeSlot: timeSlot ?? this.timeSlot,
      isRecurring: isRecurring ?? this.isRecurring,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 