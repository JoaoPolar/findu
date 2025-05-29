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
  
  // Filtros
  String? _selectedBuilding;
  String? _selectedCourse;
  int? _selectedSemester;

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

  List<String> get _buildings {
    return _rooms.map((room) => room.building).toSet().toList()..sort();
  }

  List<Room> get _filteredRooms {
    if (_selectedBuilding == null) return _rooms;
    return _rooms.where((room) => room.building == _selectedBuilding).toList();
  }

  List<Course> get _filteredCourses {
    return _courses;
  }

  String _getCourseName(String courseId) {
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(name: 'Curso não encontrado', code: '', totalSemesters: 8, shift: 'morning', coordinator: ''),
    );
    return course.name;
  }

  String _getRoomName(String roomId) {
    final room = _rooms.firstWhere(
      (r) => r.id == roomId,
      orElse: () => Room(number: '?', building: '?', capacity: 0),
    );
    return 'Sala ${room.number} - ${room.building}';
  }

  List<ClassSchedule> _getSchedulesForRoom(String roomId) {
    return _schedules.where((s) => s.roomId == roomId).toList();
  }

  List<ClassSchedule> _getSchedulesForCourse(String courseId, int semester) {
    return _schedules.where((s) => s.courseId == courseId && s.semester == semester).toList();
  }

  Widget _buildRoomView() {
    final filteredRooms = _filteredRooms;
    
    if (filteredRooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma sala encontrada'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRooms.length,
      itemBuilder: (context, index) {
        final room = filteredRooms[index];
        final roomSchedules = _getSchedulesForRoom(room.id);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2E7D32), // Verde da UniCV
              child: Text(room.number, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            title: Text('Sala ${room.number} - ${room.building}'),
            subtitle: Text('${room.capacity} pessoas • ${roomSchedules.length} aulas agendadas'),
            children: [
              if (roomSchedules.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Nenhuma aula agendada para esta sala'),
                )
              else
                _buildWeeklyGrid(roomSchedules, isRoomView: true),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton.icon(
                  onPressed: () => _showScheduleDialog(preSelectedRoomId: room.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Agendar Aula'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseView() {
    final filteredCourses = _filteredCourses;
    
    if (filteredCourses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum curso encontrado'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF4CAF50), // Verde médio da UniCV
              child: Text(course.code.substring(0, 2), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            title: Text(course.name),
            subtitle: Text('${course.totalSemesters} semestres • Turno: ${course.shift}'),
            children: [
              ...List.generate(course.totalSemesters, (semesterIndex) {
                final semester = semesterIndex + 1;
                final semesterSchedules = _getSchedulesForCourse(course.id, semester);
                
                return ExpansionTile(
                  title: Text('${semester}º Semestre'),
                  subtitle: Text('${semesterSchedules.length} aulas agendadas'),
                  children: [
                    if (semesterSchedules.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Nenhuma aula agendada para este semestre'),
                      )
                    else
                      _buildWeeklyGrid(semesterSchedules, isRoomView: false),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton.icon(
                        onPressed: () => _showScheduleDialog(
                          preSelectedCourseId: course.id,
                          preSelectedSemester: semester,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Agendar Aula'),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyGrid(List<ClassSchedule> schedules, {required bool isRoomView}) {
    final days = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
    final timeSlots = [
      'Manhã 1º\n07:00-08:40',
      'Manhã 2º\n08:50-10:30',
      'Tarde 1º\n13:00-14:40',
      'Tarde 2º\n14:50-16:30',
      'Noite 1º\n19:00-20:40',
      'Noite 2º\n20:50-22:30',
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Cabeçalho com dias da semana
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  padding: const EdgeInsets.all(8),
                  child: const Text('Horário', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...days.map((day) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                )),
              ],
            ),
          ),
          // Grade de horários
          ...timeSlots.asMap().entries.map((entry) {
            final timeSlotIndex = entry.key + 1;
            final timeSlotName = entry.value;
            
            return Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(right: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Text(
                      timeSlotName,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...List.generate(6, (dayIndex) {
                    final dayValue = dayIndex + 1;
                    final schedule = schedules.firstWhere(
                      (s) => s.day.value == dayValue && s.timeSlot.value == timeSlotIndex,
                      orElse: () => ClassSchedule(
                        courseId: '',
                        semester: 0,
                        roomId: '',
                        day: Day.values[dayIndex],
                        timeSlot: TimeSlot.values[timeSlotIndex - 1],
                      ),
                    );
                    
                    final hasSchedule = schedule.courseId.isNotEmpty;
                    
                    return Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.grey.shade300)),
                          color: hasSchedule ? const Color(0xFF81C784).withOpacity(0.3) : Colors.white,
                        ),
                        child: hasSchedule
                            ? InkWell(
                                onTap: () => _showScheduleDetails(schedule),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isRoomView 
                                            ? _getCourseName(schedule.courseId)
                                            : _getRoomName(schedule.roomId),
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (isRoomView)
                                        Text(
                                          '${schedule.semester}º sem',
                                          style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showScheduleDetails(ClassSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes da Aula'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Curso:', _getCourseName(schedule.courseId)),
            _buildDetailRow('Semestre:', '${schedule.semester}º'),
            _buildDetailRow('Sala:', _getRoomName(schedule.roomId)),
            _buildDetailRow('Dia:', schedule.day.displayName),
            _buildDetailRow('Horário:', '${schedule.timeSlot.displayName} (${schedule.timeSlot.timeRange})'),
            if (schedule.isRecurring)
              _buildDetailRow('Período:', 
                '${schedule.startDate?.day}/${schedule.startDate?.month}/${schedule.startDate?.year} - '
                '${schedule.endDate?.day}/${schedule.endDate?.month}/${schedule.endDate?.year}'),
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
              _showScheduleDialog(schedule: schedule);
            },
            child: const Text('Editar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteSchedule(schedule);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
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
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _deleteSchedule(ClassSchedule schedule) async {
    try {
      await _adminService.deleteSchedule(schedule.id);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aula removida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover aula: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showScheduleDialog({
    ClassSchedule? schedule,
    String? preSelectedRoomId,
    String? preSelectedCourseId,
    int? preSelectedSemester,
  }) {
    final isEditing = schedule != null;
    
    String? selectedCourseId = schedule?.courseId ?? preSelectedCourseId ?? (_courses.isNotEmpty ? _courses.first.id : null);
    String? selectedRoomId = schedule?.roomId ?? preSelectedRoomId ?? (_rooms.isNotEmpty ? _rooms.first.id : null);
    Day selectedDay = schedule?.day ?? Day.monday;
    TimeSlot selectedTimeSlot = schedule?.timeSlot ?? TimeSlot.morning1;
    int selectedSemester = schedule?.semester ?? preSelectedSemester ?? 1;
    bool isRecurring = schedule?.isRecurring ?? true;
    DateTime? startDate = schedule?.startDate ?? DateTime.now();
    DateTime? endDate = schedule?.endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Ensalamento' : 'Novo Ensalamento'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCourseId,
                    decoration: const InputDecoration(
                      labelText: 'Curso',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
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
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    items: List.generate(12, (index) => index + 1)
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
                    value: selectedRoomId,
                    decoration: const InputDecoration(
                      labelText: 'Sala',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.meeting_room),
                    ),
                    items: _rooms.map((room) => DropdownMenuItem(
                      value: room.id,
                      child: Text('Sala ${room.number} - ${room.building} (${room.capacity} pessoas)'),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRoomId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Day>(
                    value: selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Dia da Semana',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    items: Day.values.map((day) => DropdownMenuItem(
                      value: day,
                      child: Text(day.displayName),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedDay = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TimeSlot>(
                    value: selectedTimeSlot,
                    decoration: const InputDecoration(
                      labelText: 'Horário',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    items: TimeSlot.values.map((slot) => DropdownMenuItem(
                      value: slot,
                      child: Text('${slot.displayName} (${slot.timeRange})'),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedTimeSlot = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Aula recorrente (semanal)'),
                    subtitle: Text(isRecurring ? 'Se repete toda semana' : 'Aula única'),
                    value: isRecurring,
                    onChanged: (value) {
                      setDialogState(() {
                        isRecurring = value;
                      });
                    },
                  ),
                  if (isRecurring) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  startDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Data de Início',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              child: Text(
                                startDate != null 
                                    ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                    : 'Selecionar data',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now().add(const Duration(days: 120)),
                                firstDate: startDate ?? DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setDialogState(() {
                                  endDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Data de Fim',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.date_range),
                              ),
                              child: Text(
                                endDate != null 
                                    ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                    : 'Selecionar data',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                if (selectedCourseId == null || selectedRoomId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecione o curso e a sala'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final newSchedule = ClassSchedule(
                  id: schedule?.id,
                  courseId: selectedCourseId!,
                  semester: selectedSemester,
                  roomId: selectedRoomId!,
                  day: selectedDay,
                  timeSlot: selectedTimeSlot,
                  isRecurring: isRecurring,
                  startDate: startDate,
                  endDate: endDate,
                );

                try {
                  if (isEditing) {
                    await _adminService.updateSchedule(newSchedule);
                  } else {
                    await _adminService.createSchedule(newSchedule);
                  }
                  
                  Navigator.pop(context);
                  await _loadData();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? 'Ensalamento atualizado!' : 'Ensalamento criado!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao salvar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Atualizar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ensalamento'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.meeting_room), text: 'Por Sala'),
            Tab(icon: Icon(Icons.school), text: 'Por Curso'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showScheduleDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtros
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      if (_tabController.index == 0) ...[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedBuilding,
                            decoration: const InputDecoration(
                              labelText: 'Filtrar por prédio',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todos os prédios')),
                              ..._buildings.map((building) => DropdownMenuItem(
                                value: building,
                                child: Text(building),
                              )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedBuilding = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Conteúdo das abas
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRoomView(),
                      _buildCourseView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 