import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/contribuicao.dart';
import '../../models/voluntario.dart';
import '../../database/database_helper.dart';

class AddContribuicaoScreen extends StatefulWidget {
  const AddContribuicaoScreen({Key? key}) : super(key: key);

  @override
  State<AddContribuicaoScreen> createState() => _AddContribuicaoScreenState();
}

class _AddContribuicaoScreenState extends State<AddContribuicaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Voluntario> _voluntarios = [];
  Voluntario? _voluntarioSelecionado;
  DateTime _dataSelecionada = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVoluntarios();
  }

  @override
  void dispose() {
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _loadVoluntarios() async {
    final voluntarios = await _dbHelper.getVoluntariosAtivos();
    setState(() {
      _voluntarios = voluntarios;
      _isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _dataSelecionada = picked);
    }
  }

  Future<void> _saveContribuicao() async {
    if (_formKey.currentState!.validate()) {
      if (_voluntarioSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um voluntário'), backgroundColor: Colors.orange),
        );
        return;
      }

      setState(() => _isSaving = true);

      final valorStr = _valorController.text.trim().replaceAll(',', '.');
      final valor = double.tryParse(valorStr) ?? 0.0;

      final contribuicao = Contribuicao(
        voluntarioId: _voluntarioSelecionado!.id!,
        nomeVoluntario: _voluntarioSelecionado!.nome,
        valor: valor,
        dataDoacao: _dataSelecionada,
        observacoes: _observacoesController.text.trim().isEmpty 
            ? null 
            : _observacoesController.text.trim(),
      );

      try {
        await _dbHelper.insertContribuicao(contribuicao);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contribuição registrada!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Contribuição'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.monetization_on, size: 80, color: Colors.green),
                    const SizedBox(height: 24),

                    DropdownButtonFormField<Voluntario>(
                      value: _voluntarioSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Voluntário',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      items: _voluntarios.map((v) {
                        return DropdownMenuItem(value: v, child: Text(v.nome));
                      }).toList(),
                      onChanged: (value) => setState(() => _voluntarioSelecionado = value),
                      validator: (value) => value == null ? 'Selecione um voluntário' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor (R\$)',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Informe o valor';
                        final valor = double.tryParse(value.replaceAll(',', '.'));
                        if (valor == null || valor <= 0) return 'Valor inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    ListTile(
                      title: const Text('Data da Doação'),
                      subtitle: Text('${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}'),
                      leading: const Icon(Icons.calendar_today),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _observacoesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações (Opcional)',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveContribuicao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Registrar Contribuição'),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
