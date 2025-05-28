import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findu/models/student.dart';
import 'package:findu/models/class_schedule.dart';

class ScheduleService {
  // Singleton pattern
  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();
  
  // Dados do aluno atual
  Student? _currentStudent;
  
  // Lista de todas as aulas disponíveis
  final List<ClassSchedule> _allSchedules = [];
  
  // Inicialização do serviço com dados fictícios
  Future<void> initialize() async {
    // Simular atraso de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Carregar dados fictícios
    _loadMockData();
    
    // Verificar se já existe um perfil salvo
    final prefs = await SharedPreferences.getInstance();
    final studentJson = prefs.getString('student_profile');
    
    if (studentJson != null) {
      try {
        _currentStudent = Student.fromJson(json.decode(studentJson));
      } catch (e) {
        _currentStudent = null;
      }
    }
  }
  
  // Salvar perfil do aluno
  Future<void> saveStudentProfile(Student student) async {
    _currentStudent = student;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_profile', json.encode(student.toJson()));
  }
  
  // Verificar se o aluno já tem perfil
  bool get hasProfile => _currentStudent != null;
  
  // Obter o aluno atual
  Student? get currentStudent => _currentStudent;
  
  // Obter todas as aulas para o aluno atual
  List<ClassSchedule> getStudentSchedules() {
    if (_currentStudent == null) return [];
    
    return _allSchedules.where((schedule) {
      return schedule.courseId == _currentStudent!.course &&
             schedule.semester == _currentStudent!.semester &&
             _currentStudent!.enrolledClasses.contains(schedule.id);
    }).toList();
  }
  
  // Obter apenas as aulas do dia atual para o aluno
  List<ClassSchedule> getTodaySchedules() {
    final studentSchedules = getStudentSchedules();
    return studentSchedules.where((schedule) => schedule.isToday()).toList()
      ..sort((a, b) {
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }
  
  // Obter próxima aula do dia
  ClassSchedule? getNextClass() {
    final todaySchedules = getTodaySchedules();
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    for (final schedule in todaySchedules) {
      final startMinutes = schedule.startTime.hour * 60 + schedule.startTime.minute;
      if (startMinutes > currentMinutes) {
        return schedule;
      }
    }
    
    return null;
  }
  
  // Obter aula atual
  ClassSchedule? getCurrentClass() {
    final todaySchedules = getTodaySchedules();
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    for (final schedule in todaySchedules) {
      final startMinutes = schedule.startTime.hour * 60 + schedule.startTime.minute;
      final endMinutes = schedule.endTime.hour * 60 + schedule.endTime.minute;
      
      if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        return schedule;
      }
    }
    
    return null;
  }
  
  // Obter todos os cursos disponíveis
  List<String> getAvailableCourses() {
    final courses = <String>[];
    
    for (final schedule in _allSchedules) {
      if (!courses.contains(schedule.courseId)) {
        courses.add(schedule.courseId);
      }
    }
    
    return courses;
  }
  
  // Obter semestres disponíveis para um curso
  List<int> getSemestersForCourse(String courseId) {
    final semesters = <int>[];
    
    for (final schedule in _allSchedules) {
      if (schedule.courseId == courseId && !semesters.contains(schedule.semester)) {
        semesters.add(schedule.semester);
      }
    }
    
    return semesters..sort();
  }
  
  // Obter disciplinas disponíveis para um curso e semestre
  List<ClassSchedule> getClassesForCourseSemester(String courseId, int semester) {
    final classes = <ClassSchedule>[];
    final classIds = <String>[];
    
    for (final schedule in _allSchedules) {
      if (schedule.courseId == courseId && 
          schedule.semester == semester &&
          !classIds.contains(schedule.id)) {
        classes.add(schedule);
        classIds.add(schedule.id);
      }
    }
    
    return classes;
  }
  
  // Carregar dados fictícios
  void _loadMockData() {
    // Cursos de Exatas
    _addEngenhariaCivilClasses();
    _addEngenhariaComputacaoClasses();
    _addSistemasInformacaoClasses();
    
    // Cursos de Humanas
    _addDireitoClasses();
    _addPsicologiaClasses();
    
    // Cursos de Saúde
    _addMedicinaClasses();
    _addEnfermagemClasses();
  }
  
  // Adicionar aulas de Engenharia Civil
  void _addEngenhariaCivilClasses() {
    final courseId = 'ENG_CIVIL';
    
    // Primeiro semestre
    _allSchedules.addAll([
      ClassSchedule(
        id: 'ENG_CIVIL_CALC1',
        className: 'Cálculo I',
        teacherName: 'Dr. Roberto Almeida',
        room: '101',
        building: 'Bloco A',
        day: Day.monday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
      ClassSchedule(
        id: 'ENG_CIVIL_FISICA1',
        className: 'Física I',
        teacherName: 'Dra. Maria Santos',
        room: '102',
        building: 'Bloco A',
        day: Day.monday,
        startTime: const TimeOfDay(hour: 10, minute: 15),
        endTime: const TimeOfDay(hour: 12, minute: 15),
        courseId: courseId,
        semester: 1,
      ),
      ClassSchedule(
        id: 'ENG_CIVIL_INTRO',
        className: 'Introdução à Engenharia',
        teacherName: 'Dr. Carlos Oliveira',
        room: '103',
        building: 'Bloco A',
        day: Day.tuesday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
    ]);
    
    // Segundo semestre
    _allSchedules.addAll([
      ClassSchedule(
        id: 'ENG_CIVIL_CALC2',
        className: 'Cálculo II',
        teacherName: 'Dr. Roberto Almeida',
        room: '201',
        building: 'Bloco A',
        day: Day.monday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        courseId: courseId,
        semester: 2,
      ),
      ClassSchedule(
        id: 'ENG_CIVIL_RESIST',
        className: 'Resistência dos Materiais',
        teacherName: 'Dr. Fernando Silva',
        room: '202',
        building: 'Bloco A',
        day: Day.wednesday,
        startTime: const TimeOfDay(hour: 10, minute: 15),
        endTime: const TimeOfDay(hour: 12, minute: 15),
        courseId: courseId,
        semester: 2,
      ),
    ]);
  }
  
  // Adicionar aulas de Engenharia da Computação
  void _addEngenhariaComputacaoClasses() {
    final courseId = 'ENG_COMP';
    
    // Primeiro semestre
    _allSchedules.addAll([
      ClassSchedule(
        id: 'ENG_COMP_CALC1',
        className: 'Cálculo I',
        teacherName: 'Dr. Roberto Almeida',
        room: '101',
        building: 'Bloco A',
        day: Day.monday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
      ClassSchedule(
        id: 'ENG_COMP_PROG1',
        className: 'Programação I',
        teacherName: 'Dr. Lucas Ferreira',
        room: '105',
        building: 'Bloco A',
        day: Day.tuesday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
      ClassSchedule(
        id: 'ENG_COMP_CIRC',
        className: 'Circuitos Digitais',
        teacherName: 'Dra. Ana Costa',
        room: '106',
        building: 'Bloco A',
        day: Day.wednesday,
        startTime: const TimeOfDay(hour: 10, minute: 15),
        endTime: const TimeOfDay(hour: 12, minute: 15),
        courseId: courseId,
        semester: 1,
      ),
    ]);
  }
  
  // Adicionar aulas de Sistemas de Informação
  void _addSistemasInformacaoClasses() {
    final courseId = 'SIS_INFO';
    
    // Primeiro semestre
    _allSchedules.addAll([
      ClassSchedule(
        id: 'SIS_INFO_PROG',
        className: 'Introdução à Programação',
        teacherName: 'Dr. Lucas Ferreira',
        room: '105',
        building: 'Bloco B',
        day: Day.thursday,
        startTime: const TimeOfDay(hour: 19, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
      ClassSchedule(
        id: 'SIS_INFO_CALC',
        className: 'Cálculo para Computação',
        teacherName: 'Dra. Sofia Martins',
        room: '106',
        building: 'Bloco B',
        day: Day.friday,
        startTime: const TimeOfDay(hour: 19, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
    ]);
  }
  
  // Adicionar aulas de Direito
  void _addDireitoClasses() {
    final courseId = 'DIREITO';
    
    // Primeiro semestre
    _allSchedules.addAll([
      ClassSchedule(
        id: 'DIR_INTRO',
        className: 'Introdução ao Direito',
        teacherName: 'Dr. Paulo Rodrigues',
        room: '201',
        building: 'Bloco C',
        day: Day.monday,
        startTime: const TimeOfDay(hour: 19, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
      ClassSchedule(
        id: 'DIR_CONST',
        className: 'Direito Constitucional I',
        teacherName: 'Dra. Carla Mendes',
        room: '202',
        building: 'Bloco C',
        day: Day.wednesday,
        startTime: const TimeOfDay(hour: 19, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
    ]);
  }
  
  // Adicionar aulas de Psicologia
  void _addPsicologiaClasses() {
    final courseId = 'PSICO';
    
    // Primeiro semestre
    _allSchedules.addAll([
      ClassSchedule(
        id: 'PSI_INTRO',
        className: 'Introdução à Psicologia',
        teacherName: 'Dra. Mariana Costa',
        room: '301',
        building: 'Bloco D',
        day: Day.tuesday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
      ClassSchedule(
        id: 'PSI_DESENV',
        className: 'Psicologia do Desenvolvimento',
        teacherName: 'Dr. André Lima',
        room: '302',
        building: 'Bloco D',
        day: Day.thursday,
        startTime: const TimeOfDay(hour: 10, minute: 15),
        endTime: const TimeOfDay(hour: 12, minute: 15),
        courseId: courseId,
        semester: 1,
      ),
    ]);
  }
  
  // Adicionar aulas de Medicina
  void _addMedicinaClasses() {
    final courseId = 'MED';
    
    // Primeiro semestre
    _allSchedules.addAll([
      ClassSchedule(
        id: 'MED_ANAT',
        className: 'Anatomia Humana',
        teacherName: 'Dr. Ricardo Ferreira',
        room: '101',
        building: 'Bloco E',
        day: Day.monday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
      ClassSchedule(
        id: 'MED_BIOC',
        className: 'Bioquímica',
        teacherName: 'Dra. Luciana Santos',
        room: '102',
        building: 'Bloco E',
        day: Day.wednesday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
    ]);
  }
  
  // Adicionar aulas de Enfermagem
  void _addEnfermagemClasses() {
    final courseId = 'ENF';
    
    // Primeiro semestre
    _allSchedules.addAll([
      ClassSchedule(
        id: 'ENF_FUND',
        className: 'Fundamentos de Enfermagem',
        teacherName: 'Dra. Camila Alves',
        room: '201',
        building: 'Bloco E',
        day: Day.tuesday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
      ClassSchedule(
        id: 'ENF_ANAT',
        className: 'Anatomia Humana',
        teacherName: 'Dr. Ricardo Ferreira',
        room: '101',
        building: 'Bloco E',
        day: Day.thursday,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        courseId: courseId,
        semester: 1,
      ),
    ]);
  }
} 