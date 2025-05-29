import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import 'dashboard_page.dart';
import 'students_page.dart';
import 'courses_page.dart';
import 'rooms_page.dart';
import 'schedules_page.dart';
import 'login_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final _supabaseService = SupabaseService();
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      page: const DashboardPage(),
    ),
    NavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Estudantes',
      page: const StudentsPage(),
    ),
    NavigationItem(
      icon: Icons.school_outlined,
      selectedIcon: Icons.school,
      label: 'Cursos',
      page: const CoursesPage(),
    ),
    NavigationItem(
      icon: Icons.meeting_room_outlined,
      selectedIcon: Icons.meeting_room,
      label: 'Salas',
      page: const RoomsPage(),
    ),
    NavigationItem(
      icon: Icons.schedule_outlined,
      selectedIcon: Icons.schedule,
      label: 'Horários',
      page: const SchedulesPage(),
    ),
  ];

  Future<void> _logout() async {
    try {
      await _supabaseService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 1200;
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar para telas grandes
          if (isWideScreen)
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: _buildSidebar(),
            ),
          
          // Conteúdo principal
          Expanded(
            child: Column(
              children: [
                // AppBar customizada
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (!isWideScreen)
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            setState(() {
                              _isDrawerOpen = true;
                            });
                          },
                        ),
                      const SizedBox(width: 16),
                      Text(
                        _navigationItems[_selectedIndex].label,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const Spacer(),
                      // Informações do usuário
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFF3F51B5),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Secretária',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onSelected: (value) {
                                if (value == 'logout') {
                                  _logout();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Sair'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
                
                // Conteúdo da página
                Expanded(
                  child: Container(
                    color: const Color(0xFFF7FAFC),
                    child: _navigationItems[_selectedIndex].page,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Drawer para telas pequenas
      drawer: !isWideScreen ? _buildDrawer() : null,
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        // Header da sidebar
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const Row(
            children: [
              Icon(
                Icons.school,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                'FindU Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const Divider(color: Colors.white24, height: 1),
        
        // Itens de navegação
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: _navigationItems.length,
            itemBuilder: (context, index) {
              final item = _navigationItems[index];
              final isSelected = index == _selectedIndex;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ListTile(
                  leading: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              );
            },
          ),
        ),
        
        // Footer da sidebar
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                'Sistema de Gestão Acadêmica',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'v1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: _buildSidebar(),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
  });
} 