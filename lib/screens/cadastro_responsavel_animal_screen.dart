import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/responsavel.dart';
import '../models/animal.dart';
import '../widgets/custom_text_field.dart';

/// Tela para cadastrar um responsável e um animal juntos
class CadastroResponsavelAnimalScreen extends StatefulWidget {
  const CadastroResponsavelAnimalScreen({Key? key}) : super(key: key);

  @override
  State<CadastroResponsavelAnimalScreen> createState() => _CadastroResponsavelAnimalScreenState();
}

class _CadastroResponsavelAnimalScreenState extends State<CadastroResponsavelAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();

  // Controllers para o responsável
  final _nomeResponsavelController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();

  // Controllers para o animal
  final _nomeAnimalController = TextEditingController();
  final _observacoesController = TextEditingController();

  String _statusSelecionado = 'Aguardando';
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeResponsavelController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _nomeAnimalController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvarCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      
      print('Iniciando cadastro...');

      // 1. Cadastrar o responsável primeiro
      final responsavel = Responsavel(
        nome: _nomeResponsavelController.text.trim(),
        telefone: _telefoneController.text.trim(),
        endereco: _enderecoController.text.trim(),
        dataCadastro: now.toIso8601String(),
      );

      print('Inserindo responsável...');
      final responsavelId = await _dbHelper.insertResponsavel(responsavel);
      print('Responsável inserido com ID: $responsavelId');

      // 2. Cadastrar o animal vinculado ao responsável
      final animal = Animal(
        nomeAnimal: _nomeAnimalController.text.trim(),
        responsavelId: responsavelId,
        status: _statusSelecionado,
        observacoes: null,
        dataCadastro: now,
        dataCastracao: _statusSelecionado == 'Castrado' ? now : null,
      );

      print('Inserindo animal...');
      await _dbHelper.insertAnimal(animal);
      print('Animal inserido com sucesso!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Responsável e animal cadastrados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
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
        title: const Text('Cadastrar Responsável + Animal'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
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
        child: Column(
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
                    Color(0xFF42A5F5).withOpacity(0.1),
                    Color(0xFF1E88E5).withOpacity(0.05),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF42A5F5).withOpacity(0.3),
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
                        colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF42A5F5).withOpacity(0.4),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.add_circle, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Novo Cadastro',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ),
            ),
            // Conteúdo scrollável
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Seção: Dados do Responsável
              _buildSectionTitle('Dados do Responsável', Icons.person),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nomeResponsavelController,
                labelText: 'Nome do Responsável *',
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o nome do responsável';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _telefoneController,
                labelText: 'Telefone *',
                hintText: '(00) 00000-0000',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o telefone';
                  }
                  if (value.length < 10) {
                    return 'Telefone deve ter pelo menos 10 dígitos';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _enderecoController,
                labelText: 'Endereço *',
                prefixIcon: Icons.location_on,
                textCapitalization: TextCapitalization.words,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, informe o endereço';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Seção: Dados do Animal
              _buildSectionTitle('Dados do Animal', Icons.pets),
              const SizedBox(height: 16),

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

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _salvarCadastro,
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
                  label: Text(_isLoading ? 'Salvando...' : 'Salvar Cadastro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF607D8B),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF546E7A), size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF37474F),
          ),
        ),
      ],
    );
  }
}
