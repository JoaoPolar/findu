import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/course.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({Key? key}) : super(key: key);

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final _adminService = AdminService();
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = true;
  
  String _searchQuery = '';
  String? _selectedShift;

  final List<String> _shifts = [
    'morning',
    'afternoon',
    'evening',
    'full'
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final courses = await _adminService.getCourses();
      setState(() {
        _courses = courses;
        _filteredCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar cursos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCourses() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        final matchesSearch = course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            course.code.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesShift = _selectedShift == null || course.shift == _selectedShift;
        
        return matchesSearch && matchesShift;
      }).toList();
    });
  }

  void _showCourseDialog({Course? course}) {
    final isEditing = course != null;
    final nameController = TextEditingController(text: course?.name ?? '');
    final codeController = TextEditingController(text: course?.code ?? '');
    final coordinatorController = TextEditingController(text: course?.coordinator ?? '');
    int totalSemesters = course?.totalSemesters ?? 8;
    String selectedShift = course?.shift ?? _shifts.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Curso' : 'Novo Curso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Curso',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código do Curso',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: ENG_CIVIL, SIS_INFO',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: coordinatorController,
                  decoration: const InputDecoration(
                    labelText: 'Coordenador',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: totalSemesters,
                  decoration: const InputDecoration(
                    labelText: 'Total de Semestres',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(12, (index) => index + 1)
                      .map((semester) => DropdownMenuItem(
                        value: semester,
                        child: Text('$semester semestres'),
                      )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      totalSemesters = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedShift,
                  decoration: const InputDecoration(
                    labelText: 'Turno Principal',
                    border: OutlineInputBorder(),
                  ),
                  items: _shifts.map((shift) => DropdownMenuItem(
                    value: shift,
                    child: Text(_getShiftDisplayName(shift)),
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
                if (nameController.text.isEmpty || 
                    codeController.text.isEmpty ||
                    coordinatorController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos obrigatórios'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final newCourse = Course(
                  id: course?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  code: codeController.text.toUpperCase(),
                  totalSemesters: totalSemesters,
                  shift: selectedShift,
                  coordinator: coordinatorController.text,
                  createdAt: course?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  if (isEditing) {
                    await _adminService.updateCourse(newCourse);
                  } else {
                    await _adminService.createCourse(newCourse);
                  }
                  
                  Navigator.pop(context);
                  _loadCourses();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Curso atualizado!' : 'Curso criado!'),
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

  void _showCourseDetails(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Código:', course.code),
            _buildDetailRow('Coordenador:', course.coordinator),
            _buildDetailRow('Total de Semestres:', '${course.totalSemesters}'),
            _buildDetailRow('Turno Principal:', course.shiftDisplayName),
            _buildDetailRow('Criado em:', _formatDate(course.createdAt)),
            if (course.updatedAt != null)
              _buildDetailRow('Atualizado em:', _formatDate(course.updatedAt!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCourseDialog(course: course);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getShiftDisplayName(String shift) {
    switch (shift) {
      case 'morning': return 'Matutino';
      case 'afternoon': return 'Vespertino';
      case 'evening': return 'Noturno';
      case 'full': return 'Integral';
      default: return shift;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Cursos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourses,
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
                    labelText: 'Buscar por nome ou código',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterCourses();
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedShift,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por turno',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos os turnos')),
                    ..._shifts.map((shift) => DropdownMenuItem(
                      value: shift,
                      child: Text(_getShiftDisplayName(shift)),
                    )),
                  ],
                  onChanged: (value) {
                    _selectedShift = value;
                    _filterCourses();
                  },
                ),
              ],
            ),
          ),
          
          // Lista de cursos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCourses.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhum curso encontrado'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = _filteredCourses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF009688),
                                child: Text(
                                  course.code.substring(0, 2).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              title: Text(course.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Código: ${course.code}'),
                                  Text('Coordenador: ${course.coordinator}'),
                                  Text('${course.totalSemesters} semestres - ${course.shiftDisplayName}'),
                                ],
                              ),
                              onTap: () => _showCourseDetails(course),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showCourseDialog(course: course);
                                  } else if (value == 'details') {
                                    _showCourseDetails(course);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'details',
                                    child: Row(
                                      children: [
                                        Icon(Icons.info),
                                        SizedBox(width: 8),
                                        Text('Detalhes'),
                                      ],
                                    ),
                                  ),
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
        onPressed: () => _showCourseDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 