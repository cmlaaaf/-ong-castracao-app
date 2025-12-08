import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/animal.dart';
import '../../database/database_helper.dart';

/// Tela para visualizar, editar e excluir um animal
class AnimalDetailScreen extends StatefulWidget {
  final Animal animal;

  const AnimalDetailScreen({Key? key, required this.animal}) : super(key: key);

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeAnimalController;
  late TextEditingController _nomeResponsavelController;
  late TextEditingController _telefoneController;
  late TextEditingController _enderecoController;
  late TextEditingController _observacoesController;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  late String _status;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomeAnimalController = TextEditingController(text: widget.animal.nomeAnimal);
    _nomeResponsavelController = TextEditingController(text: widget.animal.nomeResponsavel);
    _telefoneController = TextEditingController(text: widget.animal.telefoneResponsavel);
    _enderecoController = TextEditingController(text: widget.animal.enderecoResponsavel);
    _observacoesController = TextEditingController(text: widget.animal.observacoes ?? '');
    _status = widget.animal.status;
  }

  @override
  void dispose() {
    _nomeAnimalController.dispose();
    _nomeResponsavelController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _nomeAnimalController.text = widget.animal.nomeAnimal;
        _nomeResponsavelController.text = widget.animal.nomeResponsavel;
        _telefoneController.text = widget.animal.telefoneResponsavel;
        _enderecoController.text = widget.animal.enderecoResponsavel;
        _observacoesController.text = widget.animal.observacoes ?? '';
        _status = widget.animal.status;
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final updatedAnimal = Animal(
        id: widget.animal.id,
        nomeAnimal: _nomeAnimalController.text.trim(),
        nomeResponsavel: _nomeResponsavelController.text.trim(),
        telefoneResponsavel: _telefoneController.text.trim(),
        enderecoResponsavel: _enderecoController.text.trim(),
        status: _status,
        observacoes: _observacoesController.text.trim().isEmpty 
            ? null 
            : _observacoesController.text.trim(),
        dataCadastro: widget.animal.dataCadastro,
        dataCastracao: _status == 'Castrado' && widget.animal.dataCastracao == null
            ? DateTime.now()
            : widget.animal.dataCastracao,
      );

      try {
        await _dbHelper.updateAnimal(updatedAnimal);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Animal atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditing = false;
            widget.animal.nomeAnimal = updatedAnimal.nomeAnimal;
            widget.animal.nomeResponsavel = updatedAnimal.nomeResponsavel;
            widget.animal.telefoneResponsavel = updatedAnimal.telefoneResponsavel;
            widget.animal.enderecoResponsavel = updatedAnimal.enderecoResponsavel;
            widget.animal.status = updatedAnimal.status;
            widget.animal.observacoes = updatedAnimal.observacoes;
            widget.animal.dataCastracao = updatedAnimal.dataCastracao;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar animal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  Future<void> _deleteAnimal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o registro de "${widget.animal.nomeAnimal}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _dbHelper.deleteAnimal(widget.animal.id!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Animal excluído com sucesso!'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir animal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Animal' : 'Detalhes do Animal'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteAnimal,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.pets, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Cadastrado em ${DateFormat('dd/MM/yyyy').format(widget.animal.dataCadastro)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nomeAnimalController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Animal',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty 
                    ? 'Informe o nome do animal' 
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nomeResponsavelController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Responsável',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty 
                    ? 'Informe o nome do responsável' 
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.trim().isEmpty 
                    ? 'Informe o telefone' 
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                maxLines: 2,
                validator: (value) => value == null || value.trim().isEmpty 
                    ? 'Informe o endereço' 
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.info),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Aguardando', child: Text('Aguardando Castração')),
                  DropdownMenuItem(value: 'Castrado', child: Text('Castrado')),
                  DropdownMenuItem(value: 'Recuperacao', child: Text('Em Recuperação')),
                ],
                onChanged: _isEditing ? (value) => setState(() => _status = value!) : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              if (_isEditing) ...[
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Salvar Alterações'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isSaving ? null : _toggleEditMode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancelar'),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _deleteAnimal,
                  icon: const Icon(Icons.delete),
                  label: const Text('Excluir Registro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
