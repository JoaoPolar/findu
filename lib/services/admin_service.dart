import '../models/student.dart';
import '../models/room.dart';
import '../models/course.dart';
import '../models/class_schedule.dart';
import 'supabase_service.dart';

class AdminService {
  final _supabaseService = SupabaseService();

  // CRUD para Estudantes
  Future<List<Student>> getStudents({
    String? courseFilter,
    int? semesterFilter,
    String? shiftFilter,
  }) async {
    try {
      var query = _supabaseService.client.from('students').select();

      if (courseFilter != null) {
        query = query.eq('course', courseFilter);
      }
      if (semesterFilter != null) {
        query = query.eq('semester', semesterFilter);
      }
      if (shiftFilter != null) {
        query = query.eq('shift', shiftFilter);
      }

      final response = await query;
      return (response as List).map((json) {
        // Converter para o formato esperado pelo modelo
        final convertedJson = {
          'id': json['id'],
          'name': json['name'],
          'email': json['email'],
          'course': json['course'],
          'semester': json['semester'],
          'shift': json['shift'],
          'enrolledClasses': json['enrolled_classes'] ?? [],
        };
        return Student.fromJson(convertedJson);
      }).toList();
    } catch (e) {
      print('Erro ao buscar estudantes: $e');
      return [];
    }
  }

  Future<Student?> createStudent(Student student) async {
    try {
      final data = {
        'name': student.name,
        'email': student.email,
        'course': student.course,
        'semester': student.semester,
        'shift': student.shift,
        'enrolled_classes': student.enrolledClasses,
      };

      final response = await _supabaseService.client
          .from('students')
          .insert(data)
          .select()
          .single();

      final convertedJson = {
        'id': response['id'],
        'name': response['name'],
        'email': response['email'],
        'course': response['course'],
        'semester': response['semester'],
        'shift': response['shift'],
        'enrolledClasses': response['enrolled_classes'] ?? [],
      };

      return Student.fromJson(convertedJson);
    } catch (e) {
      print('Erro ao criar estudante: $e');
      return null;
    }
  }

  Future<Student?> updateStudent(Student student) async {
    try {
      final data = {
        'name': student.name,
        'email': student.email,
        'course': student.course,
        'semester': student.semester,
        'shift': student.shift,
        'enrolled_classes': student.enrolledClasses,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService.client
          .from('students')
          .update(data)
          .eq('id', student.id)
          .select()
          .single();

      final convertedJson = {
        'id': response['id'],
        'name': response['name'],
        'email': response['email'],
        'course': response['course'],
        'semester': response['semester'],
        'shift': response['shift'],
        'enrolledClasses': response['enrolled_classes'] ?? [],
      };

      return Student.fromJson(convertedJson);
    } catch (e) {
      print('Erro ao atualizar estudante: $e');
      return null;
    }
  }

  Future<bool> deleteStudent(String studentId) async {
    try {
      await _supabaseService.client
          .from('students')
          .delete()
          .eq('id', studentId);
      return true;
    } catch (e) {
      print('Erro ao deletar estudante: $e');
      return false;
    }
  }

  // CRUD para Salas
  Future<List<Room>> getRooms({String? buildingFilter, String? typeFilter}) async {
    try {
      var query = _supabaseService.client.from('rooms').select();

      if (buildingFilter != null) {
        query = query.eq('building', buildingFilter);
      }
      if (typeFilter != null) {
        query = query.eq('type', typeFilter);
      }

      final response = await query;
      return (response as List).map((json) => Room.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar salas: $e');
      return [];
    }
  }

  Future<Room?> createRoom(Room room) async {
    try {
      final response = await _supabaseService.client
          .from('rooms')
          .insert(room.toJson())
          .select()
          .single();

      return Room.fromJson(response);
    } catch (e) {
      print('Erro ao criar sala: $e');
      return null;
    }
  }

  Future<Room?> updateRoom(Room room) async {
    try {
      final data = room.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from('rooms')
          .update(data)
          .eq('id', room.id)
          .select()
          .single();

      return Room.fromJson(response);
    } catch (e) {
      print('Erro ao atualizar sala: $e');
      return null;
    }
  }

  Future<bool> deleteRoom(String roomId) async {
    try {
      await _supabaseService.client
          .from('rooms')
          .delete()
          .eq('id', roomId);
      return true;
    } catch (e) {
      print('Erro ao deletar sala: $e');
      return false;
    }
  }

  // CRUD para Cursos
  Future<List<Course>> getCourses() async {
    try {
      final response = await _supabaseService.client
          .from('courses')
          .select()
          .eq('is_active', true);

      return (response as List).map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar cursos: $e');
      return [];
    }
  }

  Future<Course?> createCourse(Course course) async {
    try {
      final response = await _supabaseService.client
          .from('courses')
          .insert(course.toJson())
          .select()
          .single();

      return Course.fromJson(response);
    } catch (e) {
      print('Erro ao criar curso: $e');
      return null;
    }
  }

  Future<Course?> updateCourse(Course course) async {
    try {
      final data = course.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from('courses')
          .update(data)
          .eq('id', course.id)
          .select()
          .single();

      return Course.fromJson(response);
    } catch (e) {
      print('Erro ao atualizar curso: $e');
      return null;
    }
  }

  // CRUD para Horários
  Future<List<ClassSchedule>> getSchedules({
    String? courseFilter,
    int? semesterFilter,
  }) async {
    try {
      var query = _supabaseService.client.from('class_schedules').select();

      if (courseFilter != null) {
        query = query.eq('course_id', courseFilter);
      }
      if (semesterFilter != null) {
        query = query.eq('semester', semesterFilter);
      }

      final response = await query;
      return (response as List).map((json) {
        // Converter do formato do banco para o formato do modelo
        final convertedJson = {
          'id': json['id'],
          'className': json['class_name'],
          'teacherName': json['teacher_name'],
          'room': json['room'],
          'building': json['building'],
          'day': _convertDayFromDb(json['day']),
          'startTime': {
            'hour': json['start_time_hour'],
            'minute': json['start_time_minute'],
          },
          'endTime': {
            'hour': json['end_time_hour'],
            'minute': json['end_time_minute'],
          },
          'courseId': json['course_id'],
          'semester': json['semester'],
        };
        return ClassSchedule.fromJson(convertedJson);
      }).toList();
    } catch (e) {
      print('Erro ao buscar horários: $e');
      return [];
    }
  }

  Future<ClassSchedule?> createSchedule(ClassSchedule schedule) async {
    try {
      final data = {
        'class_name': schedule.className,
        'teacher_name': schedule.teacherName,
        'room': schedule.room,
        'building': schedule.building,
        'day': _convertDayToDb(schedule.day),
        'start_time_hour': schedule.startTime.hour,
        'start_time_minute': schedule.startTime.minute,
        'end_time_hour': schedule.endTime.hour,
        'end_time_minute': schedule.endTime.minute,
        'course_id': schedule.courseId,
        'semester': schedule.semester,
      };

      final response = await _supabaseService.client
          .from('class_schedules')
          .insert(data)
          .select()
          .single();

      final convertedJson = {
        'id': response['id'],
        'className': response['class_name'],
        'teacherName': response['teacher_name'],
        'room': response['room'],
        'building': response['building'],
        'day': _convertDayFromDb(response['day']),
        'startTime': {
          'hour': response['start_time_hour'],
          'minute': response['start_time_minute'],
        },
        'endTime': {
          'hour': response['end_time_hour'],
          'minute': response['end_time_minute'],
        },
        'courseId': response['course_id'],
        'semester': response['semester'],
      };

      return ClassSchedule.fromJson(convertedJson);
    } catch (e) {
      print('Erro ao criar horário: $e');
      return null;
    }
  }

  Future<ClassSchedule?> updateSchedule(ClassSchedule schedule) async {
    try {
      final data = {
        'class_name': schedule.className,
        'teacher_name': schedule.teacherName,
        'room': schedule.room,
        'building': schedule.building,
        'day': _convertDayToDb(schedule.day),
        'start_time_hour': schedule.startTime.hour,
        'start_time_minute': schedule.startTime.minute,
        'end_time_hour': schedule.endTime.hour,
        'end_time_minute': schedule.endTime.minute,
        'course_id': schedule.courseId,
        'semester': schedule.semester,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabaseService.client
          .from('class_schedules')
          .update(data)
          .eq('id', schedule.id)
          .select()
          .single();

      final convertedJson = {
        'id': response['id'],
        'className': response['class_name'],
        'teacherName': response['teacher_name'],
        'room': response['room'],
        'building': response['building'],
        'day': _convertDayFromDb(response['day']),
        'startTime': {
          'hour': response['start_time_hour'],
          'minute': response['start_time_minute'],
        },
        'endTime': {
          'hour': response['end_time_hour'],
          'minute': response['end_time_minute'],
        },
        'courseId': response['course_id'],
        'semester': response['semester'],
      };

      return ClassSchedule.fromJson(convertedJson);
    } catch (e) {
      print('Erro ao atualizar horário: $e');
      return null;
    }
  }

  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _supabaseService.client
          .from('class_schedules')
          .delete()
          .eq('id', scheduleId);
      return true;
    } catch (e) {
      print('Erro ao deletar horário: $e');
      return false;
    }
  }

  // Funções auxiliares para conversão de dias
  String _convertDayToDb(Day day) {
    return day.toString().split('.').last;
  }

  Day _convertDayFromDb(String dayStr) {
    switch (dayStr.toLowerCase()) {
      case 'monday':
        return Day.monday;
      case 'tuesday':
        return Day.tuesday;
      case 'wednesday':
        return Day.wednesday;
      case 'thursday':
        return Day.thursday;
      case 'friday':
        return Day.friday;
      case 'saturday':
        return Day.saturday;
      case 'sunday':
        return Day.sunday;
      default:
        return Day.monday;
    }
  }

  // Relatórios e estatísticas
  Future<Map<String, int>> getStudentStatistics() async {
    try {
      final students = await getStudents();
      final Map<String, int> stats = {};

      // Estatísticas por curso
      for (final student in students) {
        stats[student.course] = (stats[student.course] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Erro ao gerar estatísticas: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getRoomOccupancy() async {
    try {
      final rooms = await getRooms();
      final schedules = await getSchedules();
      
      return rooms.map((room) {
        final roomSchedules = schedules.where((s) => s.room == room.number).length;
        return {
          'room': room,
          'occupancy': roomSchedules,
          'utilization': (roomSchedules / 35 * 100).round(), // 35 = 7 dias * 5 horários por dia
        };
      }).toList();
    } catch (e) {
      print('Erro ao calcular ocupação das salas: $e');
      return [];
    }
  }
} 