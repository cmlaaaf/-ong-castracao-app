import 'package:flutter/material.dart';
import '../../models/animal.dart';
import '../../database/database_helper.dart';
import '../../widgets/custom_text_field.dart';

/// Tela para cadastrar um novo animal sem responsável (sem dono)
class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({Key? key}) : super(key: key);

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeAnimalController = TextEditingController();
  final _observacoesController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  String _status = 'Aguardando';
  bool _isSaving = false;

  @override
  void dispose() {
    _nomeAnimalController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  /// Valida e salva o animal no banco de dados
  Future<void> _saveAnimal() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final animal = Animal(
        nomeAnimal: _nomeAnimalController.text.trim(),
        responsavelId: null, // Animal sem dono
        status: _status,
        observacoes: null,
        dataCadastro: DateTime.now(),
        dataCastracao: _status == 'Castrado' ? DateTime.now() : null,
      );

      try {
        await _dbHelper.insertAnimal(animal);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Animal sem dono cadastrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar animal: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Animal sem Dono'),
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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Info card
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Este formulário é para cadastrar animais sem responsável definido.',
                        style: TextStyle(color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            CustomTextField(
              controller: _nomeAnimalController,
              labelText: 'Nome do Animal *',
              prefixIcon: Icons.pets,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, informe o nome do animal';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              items: const [
                DropdownMenuItem(value: 'Aguardando', child: Text('Aguardando')),
                DropdownMenuItem(value: 'Castrado', child: Text('Castrado')),
                DropdownMenuItem(value: 'Em Recuperação', child: Text('Em Recuperação')),
              ],
              onChanged: (value) {
                setState(() => _status = value!);
              },
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveAnimal,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Cadastrando...' : 'Cadastrar Animal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF78909C),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
