import 'package:flutter/material.dart';
import 'package:findu/models/class_schedule.dart';
import 'package:findu/models/student.dart';
import 'package:findu/services/schedule_service.dart';
import 'package:findu/services/supabase_service.dart';
import 'package:findu/ui/components/drawer_login.dart';
import 'package:findu/ui/utils/page_transition.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with SingleTickerProviderStateMixin {
  final _scheduleService = ScheduleService();
  
  Student? _student;
  List<ClassSchedule> _todaySchedules = [];
  List<ClassSchedule> _allSchedules = [];
  ClassSchedule? _currentClass;
  ClassSchedule? _nextClass;
  
  late TabController _tabController;
  bool _isLoading = true;
  
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
    
    await _scheduleService.initialize();
    
    setState(() {
      _student = _scheduleService.currentStudent;
      
      if (_student != null) {
        _todaySchedules = _scheduleService.getTodaySchedules();
        _allSchedules = _scheduleService.getStudentSchedules();
        _currentClass = _scheduleService.getCurrentClass();
        _nextClass = _scheduleService.getNextClass();
      }
      
      _isLoading = false;
    });
  }
  
  Future<void> _logout() async {
    await SupabaseService().logout();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Scaffold(
          body: Center(child: DrawerLogin()),
        )),
        (route) => false,
      );
    }
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
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
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    
    if (_student == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('FindU - Ensalamento'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum perfil encontrado',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Faça login para configurar seu perfil',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Ir para Login'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('FindU - Ensalamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Semana'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(),
          _buildWeekView(),
        ],
      ),
    );
  }
  
  Widget _buildTodayView() {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'pt_BR').format(now);
    final dayCapitalized = dayName[0].toUpperCase() + dayName.substring(1);
    final formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(now);
    
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Theme.of(context).primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com saudação e informações do usuário
            Text(
              '${_getGreeting()}, ${_student!.name.split(' ')[0]}!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_getCourseDisplayName(_student!.course)} - ${_student!.semester}º Semestre',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Turno: ${_student!.shift}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data atual
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF009688).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Color(0xFF009688),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$dayCapitalized, $formattedDate',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF009688),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Aula atual
            if (_currentClass != null) ...[
              const Text(
                'Aula Atual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildClassCard(
                _currentClass!,
                isHighlighted: true,
                status: 'Acontecendo agora',
                statusColor: Colors.green,
              ),
              const SizedBox(height: 24),
            ],
            
            // Próxima aula
            if (_nextClass != null) ...[
              const Text(
                'Próxima Aula',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildClassCard(
                _nextClass!,
                isHighlighted: false,
                status: 'Em breve',
                statusColor: Colors.orange,
              ),
              const SizedBox(height: 24),
            ],
            
            // Todas as aulas do dia
            Text(
              _todaySchedules.isEmpty 
                  ? 'Nenhuma aula hoje'
                  : 'Todas as aulas de hoje (${_todaySchedules.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            if (_todaySchedules.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_busy,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Você não tem aulas hoje',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _todaySchedules.length,
                itemBuilder: (context, index) {
                  final schedule = _todaySchedules[index];
                  
                  String status = '';
                  Color statusColor = Colors.grey;
                  
                  if (schedule.isHappeningNow) {
                    status = 'Agora';
                    statusColor = Colors.green;
                  } else if (schedule.hasPassed) {
                    status = 'Concluída';
                    statusColor = Colors.grey;
                  } else if (schedule.isUpcoming) {
                    status = 'Em breve';
                    statusColor = Colors.orange;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildClassCard(
                      schedule,
                      isHighlighted: schedule.isHappeningNow,
                      status: status,
                      statusColor: statusColor,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeekView() {
    // Agrupar aulas por dia da semana
    final Map<Day, List<ClassSchedule>> schedulesByDay = {};
    
    for (final day in Day.values) {
      schedulesByDay[day] = _allSchedules
          .where((schedule) => schedule.day == day)
          .toList()
        ..sort((a, b) {
          final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
          final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
          return aMinutes.compareTo(bMinutes);
        });
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      color: Theme.of(context).primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cronograma Semanal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            for (final day in Day.values) ...[
              if (day != Day.sunday) ... [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF009688).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Color(0xFF009688),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        day.formatted,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF009688),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                if (schedulesByDay[day]!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Nenhuma aula neste dia',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: schedulesByDay[day]!.length,
                    itemBuilder: (context, index) {
                      final schedule = schedulesByDay[day]![index];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildClassCard(
                          schedule,
                          showDay: false,
                          isHighlighted: false,
                        ),
                      );
                    },
                  ),
                  
                const SizedBox(height: 16),
              ],
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildClassCard(
    ClassSchedule schedule, {
    bool showDay = false,
    bool isHighlighted = false,
    String status = '',
    Color statusColor = Colors.grey,
  }) {
    return Card(
      elevation: isHighlighted ? 4 : 1,
      shadowColor: isHighlighted ? const Color(0xFF009688).withOpacity(0.3) : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isHighlighted ? const Color(0xFF009688) : Colors.transparent,
          width: isHighlighted ? 1.5 : 0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isHighlighted ? const Color(0xFF009688) : Colors.grey.shade300,
                width: isHighlighted ? 4 : 3,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        schedule.className,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${schedule.formattedStartTime} - ${schedule.formattedEndTime}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    if (showDay) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.day.shortFormatted,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        schedule.teacherName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sala ${schedule.room}, ${schedule.building}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 