import 'package:flutter/material.dart';
import '../../models/voluntario.dart';
import '../../database/database_helper.dart';

class VoluntarioDetailScreen extends StatefulWidget {
  final Voluntario voluntario;
  const VoluntarioDetailScreen({Key? key, required this.voluntario}) : super(key: key);

  @override
  State<VoluntarioDetailScreen> createState() => _VoluntarioDetailScreenState();
}

class _VoluntarioDetailScreenState extends State<VoluntarioDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  late TextEditingController _observacoesController;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  late bool _ativo;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.voluntario.nome);
    _telefoneController = TextEditingController(text: widget.voluntario.telefone);
    _emailController = TextEditingController(text: widget.voluntario.email);
    _observacoesController = TextEditingController(text: widget.voluntario.observacoes ?? '');
    _ativo = widget.voluntario.ativo;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        _nomeController.text = widget.voluntario.nome;
        _telefoneController.text = widget.voluntario.telefone;
        _emailController.text = widget.voluntario.email;
        _observacoesController.text = widget.voluntario.observacoes ?? '';
        _ativo = widget.voluntario.ativo;
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final updatedVoluntario = Voluntario(
        id: widget.voluntario.id,
        nome: _nomeController.text.trim(),
        telefone: _telefoneController.text.trim(),
        email: _emailController.text.trim(),
        ativo: _ativo,
        dataCadastro: widget.voluntario.dataCadastro,
        observacoes: _observacoesController.text.trim().isEmpty ? null : _observacoesController.text.trim(),
      );

      try {
        await _dbHelper.updateVoluntario(updatedVoluntario);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voluntário atualizado!'), backgroundColor: Colors.green),
          );
          setState(() {
            _isEditing = false;
            widget.voluntario.nome = updatedVoluntario.nome;
            widget.voluntario.telefone = updatedVoluntario.telefone;
            widget.voluntario.email = updatedVoluntario.email;
            widget.voluntario.ativo = updatedVoluntario.ativo;
            widget.voluntario.observacoes = updatedVoluntario.observacoes;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteVoluntario() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir "${widget.voluntario.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
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
        await _dbHelper.deleteVoluntario(widget.voluntario.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voluntário excluído!'), backgroundColor: Colors.orange),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Voluntário' : 'Detalhes'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing) IconButton(icon: const Icon(Icons.edit), onPressed: _toggleEditMode),
          if (!_isEditing) IconButton(icon: const Icon(Icons.delete), onPressed: _deleteVoluntario),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: _ativo ? Colors.green : Colors.grey,
                child: Text(
                  widget.voluntario.nome.isNotEmpty ? widget.voluntario.nome[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                enabled: _isEditing,
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                enabled: _isEditing,
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                enabled: _isEditing,
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o e-mail' : null,
              ),
              const SizedBox(height: 16),

              if (_isEditing)
                SwitchListTile(
                  title: const Text('Voluntário Ativo'),
                  value: _ativo,
                  onChanged: (value) => setState(() => _ativo = value),
                  activeColor: Colors.green,
                ),

              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(labelText: 'Observações', prefixIcon: Icon(Icons.notes), border: OutlineInputBorder()),
                enabled: _isEditing,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              if (_isEditing) ...[
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 0)),
                  child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Salvar'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isSaving ? null : _toggleEditMode,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 0)),
                  child: const Text('Cancelar'),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: _deleteVoluntario,
                  icon: const Icon(Icons.delete),
                  label: const Text('Excluir'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), minimumSize: const Size(double.infinity, 0)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
