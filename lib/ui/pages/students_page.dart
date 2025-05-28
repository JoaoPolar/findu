import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/student.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({Key? key}) : super(key: key);

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final _adminService = AdminService();
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  
  String _searchQuery = '';
  String? _selectedCourse;
  int? _selectedSemester;
  String? _selectedShift;

  final List<String> _courses = [
    'ENG_CIVIL',
    'ENG_COMP', 
    'SIS_INFO',
    'DIREITO',
    'PSICO',
    'MED',
    'ENF'
  ];

  final List<String> _shifts = [
    'Manhã',
    'Tarde', 
    'Noite',
    'Integral'
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final students = await _adminService.getStudents();
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar estudantes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterStudents() {
    setState(() {
      _filteredStudents = _students.where((student) {
        final matchesSearch = student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            student.email.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCourse = _selectedCourse == null || student.course == _selectedCourse;
        final matchesSemester = _selectedSemester == null || student.semester == _selectedSemester;
        final matchesShift = _selectedShift == null || student.shift == _selectedShift;
        
        return matchesSearch && matchesCourse && matchesSemester && matchesShift;
      }).toList();
    });
  }

  void _showStudentDialog({Student? student}) {
    final isEditing = student != null;
    final nameController = TextEditingController(text: student?.name ?? '');
    final emailController = TextEditingController(text: student?.email ?? '');
    String selectedCourse = student?.course ?? _courses.first;
    int selectedSemester = student?.semester ?? 1;
    String selectedShift = student?.shift ?? _shifts.first;
    List<String> enrolledClasses = List.from(student?.enrolledClasses ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Estudante' : 'Novo Estudante'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCourse,
                  decoration: const InputDecoration(
                    labelText: 'Curso',
                    border: OutlineInputBorder(),
                  ),
                  items: _courses.map((course) => DropdownMenuItem(
                    value: course,
                    child: Text(_getCourseDisplayName(course)),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCourse = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedSemester,
                  decoration: const InputDecoration(
                    labelText: 'Semestre',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(10, (index) => index + 1)
                      .map((semester) => DropdownMenuItem(
                        value: semester,
                        child: Text('${semester}º Semestre'),
                      )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedSemester = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShift,
                  decoration: const InputDecoration(
                    labelText: 'Turno',
                    border: OutlineInputBorder(),
                  ),
                  items: _shifts.map((shift) => DropdownMenuItem(
                    value: shift,
                    child: Text(shift),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedShift = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos obrigatórios'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final newStudent = Student(
                  id: student?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  email: emailController.text,
                  course: selectedCourse,
                  semester: selectedSemester,
                  shift: selectedShift,
                  enrolledClasses: enrolledClasses,
                );

                try {
                  if (isEditing) {
                    await _adminService.updateStudent(newStudent);
                  } else {
                    await _adminService.createStudent(newStudent);
                  }
                  
                  Navigator.pop(context);
                  _loadStudents();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Estudante atualizado!' : 'Estudante criado!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao salvar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Atualizar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o estudante ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _adminService.deleteStudent(student.id);
                Navigator.pop(context);
                _loadStudents();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Estudante excluído!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao excluir: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _getCourseDisplayName(String courseId) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Estudantes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nome ou email',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterStudents();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCourse,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por curso',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos os cursos')),
                          ..._courses.map((course) => DropdownMenuItem(
                            value: course,
                            child: Text(_getCourseDisplayName(course)),
                          )),
                        ],
                        onChanged: (value) {
                          _selectedCourse = value;
                          _filterStudents();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedSemester,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por semestre',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos os semestres')),
                          ...List.generate(10, (index) => index + 1)
                              .map((semester) => DropdownMenuItem(
                                value: semester,
                                child: Text('${semester}º Semestre'),
                              )),
                        ],
                        onChanged: (value) {
                          _selectedSemester = value;
                          _filterStudents();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de estudantes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhum estudante encontrado'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(student.name.substring(0, 1).toUpperCase()),
                              ),
                              title: Text(student.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.email),
                                  Text('${_getCourseDisplayName(student.course)} - ${student.semester}º Semestre'),
                                  Text('Turno: ${student.shift}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showStudentDialog(student: student);
                                  } else if (value == 'delete') {
                                    _deleteStudent(student);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Excluir', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 