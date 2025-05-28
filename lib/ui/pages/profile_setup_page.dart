import 'package:flutter/material.dart';
import 'package:findu/models/student.dart';
import 'package:findu/models/class_schedule.dart';
import 'package:findu/services/schedule_service.dart';
import 'package:findu/services/supabase_service.dart';
import 'package:findu/ui/pages/schedule_page.dart';
import 'package:findu/ui/utils/page_transition.dart';
import 'package:findu/ui/components/default_input.dart';
import 'package:uuid/uuid.dart';

class ProfileSetupPage extends StatefulWidget {
  final String userEmail;
  final String userName;
  
  const ProfileSetupPage({
    Key? key, 
    required this.userEmail,
    required this.userName,
  }) : super(key: key);

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _scheduleService = ScheduleService();
  
  String? _selectedCourse;
  int? _selectedSemester;
  final List<String> _selectedClasses = [];
  
  bool _isLoading = true;
  List<String> _availableCourses = [];
  List<int> _availableSemesters = [];
  List<ClassSchedule> _availableClasses = [];
  
  String _courseDisplayName(String courseId) {
    switch (courseId) {
      case 'ENG_CIVIL': return 'Engenharia Civil';
      case 'ENG_COMP': return 'Engenharia da Computação';
      case 'SIS_INFO': return 'Sistemas de Informação';
      case 'DIREITO': return 'Direito';
      case 'PSICO': return 'Psicologia';
      case 'MED': return 'Medicina';
      case 'ENF': return 'Enfermagem';
      default: return courseId;
    }
  }
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    await _scheduleService.initialize();
    
    setState(() {
      _availableCourses = _scheduleService.getAvailableCourses();
      _isLoading = false;
    });
  }
  
  void _onCourseChanged(String? course) {
    setState(() {
      _selectedCourse = course;
      _selectedSemester = null;
      _selectedClasses.clear();
      
      if (course != null) {
        _availableSemesters = _scheduleService.getSemestersForCourse(course);
      } else {
        _availableSemesters = [];
      }
      
      _availableClasses = [];
    });
  }
  
  void _onSemesterChanged(int? semester) {
    setState(() {
      _selectedSemester = semester;
      _selectedClasses.clear();
      
      if (_selectedCourse != null && semester != null) {
        _availableClasses = _scheduleService.getClassesForCourseSemester(
          _selectedCourse!,
          semester,
        );
      } else {
        _availableClasses = [];
      }
    });
  }
  
  void _toggleClassSelection(String classId) {
    setState(() {
      if (_selectedClasses.contains(classId)) {
        _selectedClasses.remove(classId);
      } else {
        _selectedClasses.add(classId);
      }
    });
  }
  
  Future<void> _saveProfile() async {
    if (_selectedCourse == null || _selectedSemester == null || _selectedClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos e selecione pelo menos uma disciplina'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Criar perfil do aluno
    final student = Student(
      id: const Uuid().v4(),
      name: widget.userName,
      email: widget.userEmail,
      course: _selectedCourse!,
      semester: _selectedSemester!,
      shift: _getShiftFromClasses(),
      enrolledClasses: _selectedClasses,
    );
    
    // Salvar o perfil
    await _scheduleService.saveStudentProfile(student);
    
    // Iniciar logout
    await SupabaseService().logout();
    
    setState(() {
      _isLoading = false;
    });
    
    // Navegar para a página de horários
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        CustomPageTransition(
          page: const SchedulePage(),
          transitionType: TransitionType.scale,
        ),
        (route) => false,
      );
    }
  }
  
  // Determinar o turno com base nas aulas selecionadas
  String _getShiftFromClasses() {
    bool hasMorning = false;
    bool hasAfternoon = false;
    bool hasEvening = false;
    
    for (final classId in _selectedClasses) {
      final classSchedule = _availableClasses.firstWhere(
        (c) => c.id == classId,
        orElse: () => _allClassSchedules().firstWhere((c) => c.id == classId),
      );
      
      final startHour = classSchedule.startTime.hour;
      
      if (startHour < 12) {
        hasMorning = true;
      } else if (startHour < 18) {
        hasAfternoon = true;
      } else {
        hasEvening = true;
      }
    }
    
    if (hasMorning && !hasAfternoon && !hasEvening) {
      return "Manhã";
    } else if (!hasMorning && hasAfternoon && !hasEvening) {
      return "Tarde";
    } else if (!hasMorning && !hasAfternoon && hasEvening) {
      return "Noite";
    } else {
      return "Integral";
    }
  }
  
  // Obter todas as aulas disponíveis
  List<ClassSchedule> _allClassSchedules() {
    final List<ClassSchedule> allClasses = [];
    
    for (final course in _availableCourses) {
      for (final semester in _scheduleService.getSemestersForCourse(course)) {
        allClasses.addAll(_scheduleService.getClassesForCourseSemester(course, semester));
      }
    }
    
    return allClasses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure seu Perfil'),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF009688),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bem-vindo!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Olá, ${widget.userName}! Para começar, precisamos de algumas informações sobre o seu curso.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Seleção de Curso
                  const Text(
                    'Selecione seu curso:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCourse,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    hint: const Text('Selecione seu curso'),
                    items: _availableCourses.map((course) {
                      return DropdownMenuItem<String>(
                        value: course,
                        child: Text(_courseDisplayName(course)),
                      );
                    }).toList(),
                    onChanged: _onCourseChanged,
                  ),
                  const SizedBox(height: 16),
                  
                  // Seleção de Semestre
                  const Text(
                    'Selecione seu semestre:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedSemester,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    hint: const Text('Selecione seu semestre'),
                    items: _availableSemesters.map((semester) {
                      return DropdownMenuItem<int>(
                        value: semester,
                        child: Text('$semester° Semestre'),
                      );
                    }).toList(),
                    onChanged: _selectedCourse != null ? _onSemesterChanged : null,
                  ),
                  const SizedBox(height: 24),
                  
                  // Seleção de Disciplinas
                  if (_availableClasses.isNotEmpty) ...[
                    const Text(
                      'Selecione suas disciplinas:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _availableClasses.length,
                      itemBuilder: (context, index) {
                        final classSchedule = _availableClasses[index];
                        final bool isSelected = _selectedClasses.contains(classSchedule.id);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF009688) : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _toggleClassSelection(classSchedule.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          classSchedule.className,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Prof: ${classSchedule.teacherName}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${classSchedule.day.formatted}, ${classSchedule.formattedStartTime} - ${classSchedule.formattedEndTime}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Sala ${classSchedule.room}, ${classSchedule.building}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: const Color(0xFF009688),
                                    onChanged: (bool? value) {
                                      _toggleClassSelection(classSchedule.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // Botão Salvar
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 44,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _selectedCourse != null && 
                                  _selectedSemester != null && 
                                  _selectedClasses.isNotEmpty 
                                  ? _saveProfile 
                                  : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF009688),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'SALVAR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
} 