import 'package:flutter/material.dart';
import '../../models/voluntario.dart';
import '../../database/database_helper.dart';
import 'add_voluntario_screen.dart';
import 'voluntario_detail_screen.dart';

class VoluntarioListScreen extends StatefulWidget {
  const VoluntarioListScreen({Key? key}) : super(key: key);

  @override
  State<VoluntarioListScreen> createState() => _VoluntarioListScreenState();
}

class _VoluntarioListScreenState extends State<VoluntarioListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Voluntario> _voluntarios = [];
  bool _isLoading = true;
  bool _mostrarApenasAtivos = true;

  @override
  void initState() {
    super.initState();
    _loadVoluntarios();
  }

  Future<void> _loadVoluntarios() async {
    setState(() => _isLoading = true);
    
    List<Voluntario> voluntarios = _mostrarApenasAtivos
        ? await _dbHelper.getVoluntariosAtivos()
        : await _dbHelper.getAllVoluntarios();
    
    setState(() {
      _voluntarios = voluntarios;
      _isLoading = false;
    });
  }

  Future<void> _navigateToAddVoluntario() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddVoluntarioScreen()),
    );

    if (result == true) _loadVoluntarios();
  }

  Future<void> _navigateToVoluntarioDetail(Voluntario voluntario) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoluntarioDetailScreen(voluntario: voluntario),
      ),
    );

    if (result == true) _loadVoluntarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voluntários'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Mostrar apenas voluntários ativos'),
            value: _mostrarApenasAtivos,
            onChanged: (value) {
              setState(() => _mostrarApenasAtivos = value);
              _loadVoluntarios();
            },
            activeColor: Colors.green,
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _voluntarios.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, size: 100, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Nenhum voluntário cadastrado',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _voluntarios.length,
                        itemBuilder: (context, index) {
                          final voluntario = _voluntarios[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: voluntario.ativo ? Colors.green : Colors.grey,
                                child: Text(
                                  voluntario.nome.isNotEmpty 
                                      ? voluntario.nome[0].toUpperCase() 
                                      : '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(voluntario.nome,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(voluntario.telefone),
                                  Text(voluntario.email, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: voluntario.ativo
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.cancel, color: Colors.grey),
                              isThreeLine: true,
                              onTap: () => _navigateToVoluntarioDetail(voluntario),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddVoluntario,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
