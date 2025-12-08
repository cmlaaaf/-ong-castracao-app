import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/animal.dart';
import '../../widgets/custom_text_field.dart';

/// Tela para editar um animal existente
class EditAnimalScreen extends StatefulWidget {
  final Animal animal;

  const EditAnimalScreen({Key? key, required this.animal}) : super(key: key);

  @override
  State<EditAnimalScreen> createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  final _nomeAnimalController = TextEditingController();
  final _observacoesController = TextEditingController();

  String _statusSelecionado = 'Aguardando';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeAnimalController.text = widget.animal.nomeAnimal;
    _observacoesController.text = widget.animal.observacoes ?? '';
    _statusSelecionado = widget.animal.status;
  }

  @override
  void dispose() {
    _nomeAnimalController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final animalAtualizado = Animal(
        id: widget.animal.id,
        nomeAnimal: _nomeAnimalController.text.trim(),
        responsavelId: widget.animal.responsavelId, // Mantém o responsável atual
        status: _statusSelecionado,
        observacoes: null,
        dataCadastro: widget.animal.dataCadastro,
        dataCastracao: _statusSelecionado == 'Castrado' && widget.animal.dataCastracao == null
            ? DateTime.now()
            : widget.animal.dataCastracao,
      );

      await _dbHelper.updateAnimal(animalAtualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Animal atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Animal'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                value: _statusSelecionado,
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
                  setState(() => _statusSelecionado = value!);
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _salvarAlteracoes,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Salvando...' : 'Salvar Alterações'),
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
      ),
    );
  }
}
