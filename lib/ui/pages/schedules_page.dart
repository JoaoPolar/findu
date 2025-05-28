import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/class_schedule.dart';
import '../../models/room.dart';
import '../../models/course.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({Key? key}) : super(key: key);

  @override
  State<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> with SingleTickerProviderStateMixin {
  final _adminService = AdminService();
  
  List<ClassSchedule> _schedules = [];
  List<Room> _rooms = [];
  List<Course> _courses = [];
  
  bool _isLoading = true;
  late TabController _tabController;
  
  // Horários padrão
  final List<Map<String, dynamic>> _timeSlots = [
    {'start': const TimeOfDay(hour: 7, minute: 0), 'end': const TimeOfDay(hour: 8, minute: 40), 'label': '1º Horário (07:00-08:40)'},
    {'start': const TimeOfDay(hour: 8, minute: 50), 'end': const TimeOfDay(hour: 10, minute: 30), 'label': '2º Horário (08:50-10:30)'},
    {'start': const TimeOfDay(hour: 10, minute: 50), 'end': const TimeOfDay(hour: 12, minute: 30), 'label': '3º Horário (10:50-12:30)'},
    {'start': const TimeOfDay(hour: 13, minute: 30), 'end': const TimeOfDay(hour: 15, minute: 10), 'label': '4º Horário (13:30-15:10)'},
    {'start': const TimeOfDay(hour: 15, minute: 20), 'end': const TimeOfDay(hour: 17, minute: 0), 'label': '5º Horário (15:20-17:00)'},
    {'start': const TimeOfDay(hour: 19, minute: 0), 'end': const TimeOfDay(hour: 20, minute: 40), 'label': '6º Horário (19:00-20:40)'},
    {'start': const TimeOfDay(hour: 20, minute: 50), 'end': const TimeOfDay(hour: 22, minute: 30), 'label': '7º Horário (20:50-22:30)'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final schedules = await _adminService.getSchedules();
      final rooms = await _adminService.getRooms();
      final courses = await _adminService.getCourses();
      
      setState(() {
        _schedules = schedules;
        _rooms = rooms;
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showScheduleDialog({ClassSchedule? schedule}) {
    final isEditing = schedule != null;
    final classNameController = TextEditingController(text: schedule?.className ?? '');
    final teacherController = TextEditingController(text: schedule?.teacherName ?? '');
    
    String? selectedCourseId = schedule?.courseId ?? (_courses.isNotEmpty ? _courses.first.id : null);
    String? selectedRoomId = schedule?.room ?? (_rooms.isNotEmpty ? _rooms.first.number : null);
    Day selectedDay = schedule?.day ?? Day.monday;
    int selectedSemester = schedule?.semester ?? 1;
    int selectedTimeSlot = 0;

    // Encontrar o slot de tempo atual se estiver editando
    if (isEditing) {
      for (int i = 0; i < _timeSlots.length; i++) {
        if (_timeSlots[i]['start'].hour == schedule!.startTime.hour &&
            _timeSlots[i]['start'].minute == schedule.startTime.minute) {
          selectedTimeSlot = i;
          break;
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Horário' : 'Novo Horário'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: classNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Disciplina',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: teacherController,
                    decoration: const InputDecoration(
                      labelText: 'Professor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCourseId,
                    decoration: const InputDecoration(
                      labelText: 'Curso',
                      border: OutlineInputBorder(),
                    ),
                    items: _courses.map((course) => DropdownMenuItem(
                      value: course.id,
                      child: Text(course.name),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCourseId = value;
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
                  DropdownButtonFormField<Day>(
                    value: selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Dia da Semana',
                      border: OutlineInputBorder(),
                    ),
                    items: Day.values.where((day) => day != Day.sunday).map((day) => DropdownMenuItem(
                      value: day,
                      child: Text(day.formatted),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedDay = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedTimeSlot,
                    decoration: const InputDecoration(
                      labelText: 'Horário',
                      border: OutlineInputBorder(),
                    ),
                    items: _timeSlots.asMap().entries.map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value['label']),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedTimeSlot = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRoomId,
                    decoration: const InputDecoration(
                      labelText: 'Sala',
                      border: OutlineInputBorder(),
                    ),
                    items: _rooms.map((room) => DropdownMenuItem(
                      value: room.number,
                      child: Text('Sala ${room.number} - ${room.building} (${room.capacity} pessoas)'),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRoomId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (classNameController.text.isEmpty || 
                    teacherController.text.isEmpty ||
                    selectedCourseId == null ||
                    selectedRoomId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Verificar conflitos
                final hasConflict = _schedules.any((s) => 
                  s.id != schedule?.id &&
                  s.day == selectedDay &&
                  s.room == selectedRoomId &&
                  s.startTime.hour == _timeSlots[selectedTimeSlot]['start'].hour &&
                  s.startTime.minute == _timeSlots[selectedTimeSlot]['start'].minute
                );

                if (hasConflict) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Conflito detectado! Esta sala já está ocupada neste horário.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final selectedRoom = _rooms.firstWhere((r) => r.number == selectedRoomId);
                
                final newSchedule = ClassSchedule(
                  id: schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  className: classNameController.text,
                  teacherName: teacherController.text,
                  room: selectedRoomId!,
                  building: selectedRoom.building,
                  day: selectedDay,
                  startTime: _timeSlots[selectedTimeSlot]['start'],
                  endTime: _timeSlots[selectedTimeSlot]['end'],
                  courseId: selectedCourseId!,
                  semester: selectedSemester,
                );

                try {
                  if (isEditing) {
                    await _adminService.updateSchedule(newSchedule);
                  } else {
                    await _adminService.createSchedule(newSchedule);
                  }
                  
                  Navigator.pop(context);
                  _loadData();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Horário atualizado!' : 'Horário criado!'),
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

  void _deleteSchedule(ClassSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o horário de ${schedule.className}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _adminService.deleteSchedule(schedule.id);
                Navigator.pop(context);
                _loadData();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Horário excluído!'),
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

  Widget _buildWeeklyGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Table(
            border: TableBorder.all(color: Colors.grey[300]!),
            columnWidths: const {
              0: FixedColumnWidth(120),
              1: FixedColumnWidth(200),
              2: FixedColumnWidth(200),
              3: FixedColumnWidth(200),
              4: FixedColumnWidth(200),
              5: FixedColumnWidth(200),
              6: FixedColumnWidth(200),
            },
            children: [
              // Cabeçalho
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Horário', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...Day.values.where((day) => day != Day.sunday).map((day) => 
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(day.formatted, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              // Linhas de horários
              ..._timeSlots.map((timeSlot) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        timeSlot['label'].split(' ')[0] + '\n' + timeSlot['label'].split(' ')[1],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ...Day.values.where((day) => day != Day.sunday).map((day) {
                      final scheduleForSlot = _schedules.where((s) => 
                        s.day == day &&
                        s.startTime.hour == timeSlot['start'].hour &&
                        s.startTime.minute == timeSlot['start'].minute
                      ).toList();

                      return Container(
                        height: 80,
                        padding: const EdgeInsets.all(4),
                        child: scheduleForSlot.isEmpty
                            ? InkWell(
                                onTap: () => _showQuickScheduleDialog(day, timeSlot),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.add, color: Colors.grey),
                                  ),
                                ),
                              )
                            : Column(
                                children: scheduleForSlot.map((schedule) {
                                  final course = _courses.firstWhere(
                                    (c) => c.id == schedule.courseId,
                                    orElse: () => Course(
                                      id: '',
                                      name: 'Curso não encontrado',
                                      code: '',
                                      totalSemesters: 0,
                                      shift: '',
                                      coordinator: '',
                                      createdAt: DateTime.now(),
                                    ),
                                  );
                                  
                                  return Expanded(
                                    child: InkWell(
                                      onTap: () => _showScheduleDialog(schedule: schedule),
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(bottom: 2),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: _getCourseColor(schedule.courseId),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              schedule.className,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Sala ${schedule.room}',
                                              style: const TextStyle(
                                                fontSize: 9,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            Text(
                                              '${course.name} - ${schedule.semester}º',
                                              style: const TextStyle(
                                                fontSize: 8,
                                                color: Colors.white70,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickScheduleDialog(Day day, Map<String, dynamic> timeSlot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agendar para ${day.formatted}'),
        content: Text('Horário: ${timeSlot['label']}\n\nDeseja criar um novo agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showScheduleDialog();
            },
            child: const Text('Criar Agendamento'),
          ),
        ],
      ),
    );
  }

  Color _getCourseColor(String courseId) {
    final colors = [
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.orange[600]!,
      Colors.purple[600]!,
      Colors.red[600]!,
      Colors.teal[600]!,
      Colors.indigo[600]!,
    ];
    
    return colors[courseId.hashCode % colors.length];
  }

  Widget _buildSchedulesList() {
    final groupedSchedules = <String, List<ClassSchedule>>{};
    
    for (final schedule in _schedules) {
      final course = _courses.firstWhere(
        (c) => c.id == schedule.courseId,
        orElse: () => Course(
          id: '',
          name: 'Curso não encontrado',
          code: '',
          totalSemesters: 0,
          shift: '',
          coordinator: '',
          createdAt: DateTime.now(),
        ),
      );
      final key = '${course.name} - ${schedule.semester}º Semestre';
      groupedSchedules.putIfAbsent(key, () => []).add(schedule);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedSchedules.keys.length,
      itemBuilder: (context, index) {
        final courseKey = groupedSchedules.keys.elementAt(index);
        final schedules = groupedSchedules[courseKey]!;
        
        return Card(
          child: ExpansionTile(
            title: Text(courseKey),
            subtitle: Text('${schedules.length} horários'),
            children: schedules.map((schedule) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCourseColor(schedule.courseId),
                  child: Text(
                    schedule.day.shortFormatted,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                title: Text(schedule.className),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Professor: ${schedule.teacherName}'),
                    Text('${schedule.day.formatted} - ${schedule.formattedStartTime} às ${schedule.formattedEndTime}'),
                    Text('Sala ${schedule.room} - ${schedule.building}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showScheduleDialog(schedule: schedule);
                    } else if (value == 'delete') {
                      _deleteSchedule(schedule);
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
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Horários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Grade Semanal', icon: Icon(Icons.grid_view)),
            Tab(text: 'Lista de Horários', icon: Icon(Icons.list)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeeklyGrid(),
          _buildSchedulesList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 