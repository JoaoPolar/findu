import '../models/student.dart';
import '../models/room.dart';
import '../models/course.dart';
import '../models/class_schedule.dart';
import 'supabase_service.dart';

class AdminService {
  final _supabaseService = SupabaseService();

  // CRUD para Estudantes
  Future<List<Student>> getStudents() async {
    try {
      final response = await _supabaseService.client
          .from('students')
          .select()
          .order('name');

      return response.map<Student>((json) => Student.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar estudantes: $e');
      return [];
    }
  }

  Future<Student?> createStudent(Student student) async {
    try {
      final response = await _supabaseService.client
          .from('students')
          .insert(student.toJson(forDatabase: false))
          .select()
          .single();

      return Student.fromJson(response);
    } catch (e) {
      print('Erro ao criar estudante: $e');
      return null;
    }
  }

  Future<Student?> updateStudent(Student student) async {
    try {
      final response = await _supabaseService.client
          .from('students')
          .update(student.toJson())
          .eq('id', student.id)
          .select()
          .single();

      return Student.fromJson(response);
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

  Future<Room> createRoom(Room room) async {
    try {
      final response = await _supabaseService.client
          .from('rooms')
          .insert(room.toJson(forDatabase: false))
          .select()
          .single();

      return Room.fromJson(response);
    } catch (e) {
      print('Erro ao criar sala: $e');
      throw Exception('Erro ao criar sala: $e');
    }
  }

  Future<Room> updateRoom(Room room) async {
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
      throw Exception('Erro ao atualizar sala: $e');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _supabaseService.client
          .from('rooms')
          .delete()
          .eq('id', roomId);
    } catch (e) {
      print('Erro ao deletar sala: $e');
      throw Exception('Erro ao deletar sala: $e');
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
          .insert(course.toJson(forDatabase: false))
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
      return (response as List).map((json) => ClassSchedule.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar horários: $e');
      return [];
    }
  }

  Future<ClassSchedule?> createSchedule(ClassSchedule schedule) async {
    try {
      final data = schedule.toDatabaseJson();

      final response = await _supabaseService.client
          .from('class_schedules')
          .insert(data)
          .select()
          .single();

      return ClassSchedule.fromJson(response);
    } catch (e) {
      print('Erro ao criar horário: $e');
      return null;
    }
  }

  Future<ClassSchedule?> updateSchedule(ClassSchedule schedule) async {
    try {
      final data = schedule.toDatabaseJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from('class_schedules')
          .update(data)
          .eq('id', schedule.id)
          .select()
          .single();

      return ClassSchedule.fromJson(response);
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

  // Relatórios e estatísticas
  Future<Map<String, int>> getStudentStatsByCourse() async {
    try {
      final students = await getStudents();
      final Map<String, int> stats = {};
      
      for (final student in students) {
        stats[student.courseId] = (stats[student.courseId] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      print('Erro ao buscar estatísticas de estudantes: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getRoomOccupancy() async {
    try {
      final rooms = await getRooms();
      final schedules = await getSchedules();
      
      return rooms.map((room) {
        final roomSchedules = schedules.where((s) => s.roomId == room.id).length;
        return {
          'room': room,
          'occupancy': roomSchedules,
          'utilization': (roomSchedules / 36 * 100).round(), // 36 = 6 dias * 6 horários por dia
        };
      }).toList();
    } catch (e) {
      print('Erro ao calcular ocupação das salas: $e');
      return [];
    }
  }
} 