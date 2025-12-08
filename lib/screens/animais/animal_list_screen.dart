import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../models/responsavel.dart';
import '../../database/database_helper.dart';
import 'add_animal_screen.dart';
import 'edit_animal_screen.dart';

/// Tela que exibe a lista de todos os animais cadastrados
class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({Key? key}) : super(key: key);

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Animal> _animais = [];
  Map<int, Responsavel> _responsaveis = {}; // Cache de responsáveis
  bool _isLoading = true;
  String _filtroStatus = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadAnimais();
  }

  /// Carrega todos os animais e seus responsáveis
  Future<void> _loadAnimais() async {
    setState(() => _isLoading = true);
    
    List<Animal> animais;
    if (_filtroStatus == 'Todos') {
      animais = await _dbHelper.getAllAnimais();
    } else {
      animais = await _dbHelper.getAnimaisByStatus(_filtroStatus);
    }

    // Carregar responsáveis
    final todosResponsaveis = await _dbHelper.getAllResponsaveis();
    final responsaveisMap = {for (var r in todosResponsaveis) r.id!: r};
    
    setState(() {
      _animais = animais;
      _responsaveis = responsaveisMap;
      _isLoading = false;
    });
  }

  /// Navega para a tela de adicionar animal (sem dono)
  Future<void> _navigateToAddAnimal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAnimalScreen()),
    );

    if (result == true) {
      _loadAnimais();
    }
  }

  /// Navega para a tela de edição do animal
  Future<void> _navigateToEditAnimal(Animal animal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAnimalScreen(animal: animal),
      ),
    );

    if (result == true) {
      _loadAnimais();
    }
  }

  /// Exclui um animal
  Future<void> _deleteAnimal(Animal animal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o animal "${animal.nomeAnimal}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteAnimal(animal.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Animal excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadAnimais();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aguardando':
        return Colors.orange;
      case 'Castrado':
        return Colors.green;
      case 'Em Recuperação':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getResponsavelNome(int? responsavelId) {
    if (responsavelId == null) return 'Sem dono';
    return _responsaveis[responsavelId]?.nome ?? 'Responsável não encontrado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animais'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Cadastrar Animal sem Dono',
            onPressed: _navigateToAddAnimal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabeçalho
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF66BB6A).withOpacity(0.1),
                  Color(0xFF43A047).withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF66BB6A).withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF66BB6A).withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.pets, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  'Gestão de Animais',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF43A047),
                  ),
                ),
              ],
            ),
          ),
          // Filtro por status
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Aguardando'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Castrado'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Em Recuperação'),
                ],
              ),
            ),
          ),

          // Lista de animais
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _animais.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum animal cadastrado',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _animais.length,
                        itemBuilder: (context, index) {
                          final animal = _animais[index];
                          return _buildAnimalCard(animal);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddAnimal,
        backgroundColor: Color(0xFF78909C),
        icon: const Icon(Icons.add),
        label: const Text('Animal sem Dono'),
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    final isSelected = _filtroStatus == status;
    return FilterChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtroStatus = status;
          _loadAnimais();
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Color(0xFFCFD8DC),
      checkmarkColor: Color(0xFF455A64),
      labelStyle: TextStyle(
        color: isSelected ? Color(0xFF37474F) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildAnimalCard(Animal animal) {
    final statusColor = _getStatusColor(animal.status);
    final responsavelNome = _getResponsavelNome(animal.responsavelId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.pets, color: statusColor),
        ),
        title: Text(
          animal.nomeAnimal,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  responsavelNome,
                  style: TextStyle(
                    color: animal.responsavelId == null 
                        ? Colors.orange[700] 
                        : Colors.grey[700],
                    fontStyle: animal.responsavelId == null 
                        ? FontStyle.italic 
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Text(
                animal.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navigateToEditAnimal(animal),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAnimal(animal),
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }
}
