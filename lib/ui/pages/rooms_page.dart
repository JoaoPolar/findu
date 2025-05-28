import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/room.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({Key? key}) : super(key: key);

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final _adminService = AdminService();
  List<Room> _rooms = [];
  List<Room> _filteredRooms = [];
  bool _isLoading = true;
  
  String _searchQuery = '';
  String? _selectedBuilding;
  String? _selectedType;

  final List<String> _buildings = [
    'Bloco A',
    'Bloco B',
    'Bloco C',
    'Bloco D',
    'Laboratórios',
    'Biblioteca'
  ];

  final List<String> _roomTypes = [
    'classroom',
    'lab',
    'auditorium'
  ];

  final List<String> _availableEquipment = [
    'projector',
    'computer',
    'whiteboard',
    'air_conditioning',
    'sound_system',
    'microphone'
  ];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rooms = await _adminService.getRooms();
      setState(() {
        _rooms = rooms;
        _filteredRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar salas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterRooms() {
    setState(() {
      _filteredRooms = _rooms.where((room) {
        final matchesSearch = room.number.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            room.building.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesBuilding = _selectedBuilding == null || room.building == _selectedBuilding;
        final matchesType = _selectedType == null || room.type == _selectedType;
        
        return matchesSearch && matchesBuilding && matchesType;
      }).toList();
    });
  }

  void _showRoomDialog({Room? room}) {
    final isEditing = room != null;
    final numberController = TextEditingController(text: room?.number ?? '');
    final capacityController = TextEditingController(text: room?.capacity.toString() ?? '');
    String selectedBuilding = room?.building ?? _buildings.first;
    String selectedType = room?.type ?? _roomTypes.first;
    List<String> selectedEquipment = List.from(room?.equipment ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Sala' : 'Nova Sala'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(
                    labelText: 'Número da Sala',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedBuilding,
                  decoration: const InputDecoration(
                    labelText: 'Prédio',
                    border: OutlineInputBorder(),
                  ),
                  items: _buildings.map((building) => DropdownMenuItem(
                    value: building,
                    child: Text(building),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedBuilding = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Capacidade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Sala',
                    border: OutlineInputBorder(),
                  ),
                  items: _roomTypes.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(_getRoomTypeDisplayName(type)),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Equipamentos:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _availableEquipment.map((equipment) {
                    final isSelected = selectedEquipment.contains(equipment);
                    return FilterChip(
                      label: Text(_getEquipmentDisplayName(equipment)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            selectedEquipment.add(equipment);
                          } else {
                            selectedEquipment.remove(equipment);
                          }
                        });
                      },
                    );
                  }).toList(),
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
                if (numberController.text.isEmpty || capacityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preencha todos os campos obrigatórios'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final capacity = int.tryParse(capacityController.text);
                if (capacity == null || capacity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Capacidade deve ser um número válido'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final newRoom = Room(
                  id: room?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  number: numberController.text,
                  building: selectedBuilding,
                  capacity: capacity,
                  type: selectedType,
                  equipment: selectedEquipment,
                  createdAt: room?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  if (isEditing) {
                    await _adminService.updateRoom(newRoom);
                  } else {
                    await _adminService.createRoom(newRoom);
                  }
                  
                  Navigator.pop(context);
                  _loadRooms();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Sala atualizada!' : 'Sala criada!'),
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

  void _deleteRoom(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a sala ${room.number}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _adminService.deleteRoom(room.id);
                Navigator.pop(context);
                _loadRooms();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sala excluída!'),
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

  String _getRoomTypeDisplayName(String type) {
    switch (type) {
      case 'classroom': return 'Sala de Aula';
      case 'lab': return 'Laboratório';
      case 'auditorium': return 'Auditório';
      default: return type;
    }
  }

  String _getEquipmentDisplayName(String equipment) {
    switch (equipment) {
      case 'projector': return 'Projetor';
      case 'computer': return 'Computador';
      case 'whiteboard': return 'Quadro Branco';
      case 'air_conditioning': return 'Ar Condicionado';
      case 'sound_system': return 'Sistema de Som';
      case 'microphone': return 'Microfone';
      default: return equipment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Salas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRooms,
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
                    labelText: 'Buscar por número ou prédio',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterRooms();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBuilding,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por prédio',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos os prédios')),
                          ..._buildings.map((building) => DropdownMenuItem(
                            value: building,
                            child: Text(building),
                          )),
                        ],
                        onChanged: (value) {
                          _selectedBuilding = value;
                          _filterRooms();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por tipo',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Todos os tipos')),
                          ..._roomTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(_getRoomTypeDisplayName(type)),
                          )),
                        ],
                        onChanged: (value) {
                          _selectedType = value;
                          _filterRooms();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de salas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRooms.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Nenhuma sala encontrada'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredRooms.length,
                        itemBuilder: (context, index) {
                          final room = _filteredRooms[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(room.number),
                              ),
                              title: Text('Sala ${room.number}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${room.building} - ${_getRoomTypeDisplayName(room.type)}'),
                                  Text('Capacidade: ${room.capacity} pessoas'),
                                  if (room.equipment.isNotEmpty)
                                    Text('Equipamentos: ${room.equipment.map(_getEquipmentDisplayName).join(', ')}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showRoomDialog(room: room);
                                  } else if (value == 'delete') {
                                    _deleteRoom(room);
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
        onPressed: () => _showRoomDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 