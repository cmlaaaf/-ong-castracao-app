import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';
import '../../models/voluntario.dart';
import '../../models/contribuicao.dart';
import '../../widgets/custom_text_field.dart';

/// Tela combinada para gerenciar voluntários e suas contribuições
class VoluntarioContribuicaoScreen extends StatefulWidget {
  const VoluntarioContribuicaoScreen({Key? key}) : super(key: key);

  @override
  State<VoluntarioContribuicaoScreen> createState() => _VoluntarioContribuicaoScreenState();
}

class _VoluntarioContribuicaoScreenState extends State<VoluntarioContribuicaoScreen> {
  final _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para cadastro de voluntário
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  List<Voluntario> _voluntarios = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVoluntarios();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadVoluntarios() async {
    setState(() => _isLoading = true);
    final voluntarios = await _dbHelper.getAllVoluntarios();
    setState(() {
      _voluntarios = voluntarios;
      _isLoading = false;
    });
  }

  Future<void> _cadastrarVoluntario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final voluntario = Voluntario(
        nome: _nomeController.text.trim(),
        telefone: _telefoneController.text.trim(),
        email: _emailController.text.trim(),
        ativo: true,
        dataCadastro: DateTime.now(),
      );

      await _dbHelper.insertVoluntario(voluntario);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voluntário cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _nomeController.clear();
        _telefoneController.clear();
        _emailController.clear();
        _loadVoluntarios();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: $e'),
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

  Future<void> _toggleAtivo(Voluntario voluntario) async {
    final voluntarioAtualizado = Voluntario(
      id: voluntario.id,
      nome: voluntario.nome,
      telefone: voluntario.telefone,
      email: voluntario.email,
      ativo: !voluntario.ativo,
      dataCadastro: voluntario.dataCadastro,
      observacoes: voluntario.observacoes,
    );

    await _dbHelper.updateVoluntario(voluntarioAtualizado);
    _loadVoluntarios();
  }

  Future<void> _excluirVoluntario(Voluntario voluntario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o voluntário "${voluntario.nome}"?\n\nIsso também excluirá todas as contribuições associadas.'),
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
      await _dbHelper.deleteVoluntario(voluntario.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voluntário excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadVoluntarios();
    }
  }

  Future<void> _abrirContribuicoes(Voluntario voluntario) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContribuicoesScreen(voluntario: voluntario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voluntários e Contribuições'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF7043), Color(0xFFE64A19)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
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
                  Color(0xFFFF7043).withOpacity(0.1),
                  Color(0xFFE64A19).withOpacity(0.05),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFFF7043).withOpacity(0.3),
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
                      colors: [Color(0xFFFF7043), Color(0xFFE64A19)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF7043).withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.volunteer_activism, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  'Gestão de Voluntários',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE64A19),
                  ),
                ),
              ],
            ),
          ),
          // Formulário de cadastro
          Container(
            padding: const EdgeInsets.all(16),
            color: Color(0xFFECEFF1),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cadastrar Novo Voluntário',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _nomeController,
                    labelText: 'Nome *',
                    prefixIcon: Icons.person,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, informe o nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _telefoneController,
                          labelText: 'Telefone *',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o telefone';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _emailController,
                          labelText: 'Email *',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o email';
                            }
                            if (!value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _cadastrarVoluntario,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(_isSaving ? 'Cadastrando...' : 'Cadastrar Voluntário'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF90A4AE),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de voluntários
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _voluntarios.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volunteer_activism, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum voluntário cadastrado',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _voluntarios.length,
                        itemBuilder: (context, index) {
                          final voluntario = _voluntarios[index];
                          return _buildVoluntarioCard(voluntario);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoluntarioCard(Voluntario voluntario) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: voluntario.ativo ? Colors.green[100] : Colors.grey[300],
          child: Icon(
            voluntario.ativo ? Icons.check_circle : Icons.block,
            color: voluntario.ativo ? Colors.green[700] : Colors.grey[600],
          ),
        ),
        title: Text(
          voluntario.nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('📞 ${voluntario.telefone}'),
            Text('✉️ ${voluntario.email}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: voluntario.ativo ? Colors.green[50] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                voluntario.ativo ? 'Ativo' : 'Inativo',
                style: TextStyle(
                  color: voluntario.ativo ? Colors.green[700] : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, size: 20),
                  const SizedBox(width: 8),
                  const Text('Contribuições'),
                ],
              ),
              onTap: () => Future.delayed(Duration.zero, () => _abrirContribuicoes(voluntario)),
            ),
            PopupMenuItem(
              child: Row(
                children: [
                  Icon(voluntario.ativo ? Icons.block : Icons.check_circle, size: 20),
                  const SizedBox(width: 8),
                  Text(voluntario.ativo ? 'Desativar' : 'Ativar'),
                ],
              ),
              onTap: () => _toggleAtivo(voluntario),
            ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () => Future.delayed(Duration.zero, () => _excluirVoluntario(voluntario)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela para gerenciar contribuições de um voluntário específico
class ContribuicoesScreen extends StatefulWidget {
  final Voluntario voluntario;

  const ContribuicoesScreen({Key? key, required this.voluntario}) : super(key: key);

  @override
  State<ContribuicoesScreen> createState() => _ContribuicoesScreenState();
}

class _ContribuicoesScreenState extends State<ContribuicoesScreen> {
  final _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  List<Contribuicao> _contribuicoes = [];
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime _dataSelecionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadContribuicoes();
  }

  @override
  void dispose() {
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _loadContribuicoes() async {
    setState(() => _isLoading = true);
    final contribuicoes = await _dbHelper.getContribuicoesByVoluntario(widget.voluntario.id!);
    setState(() {
      _contribuicoes = contribuicoes;
      _isLoading = false;
    });
  }

  Future<void> _cadastrarContribuicao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final valor = double.parse(_valorController.text.replaceAll(',', '.'));
      
      final contribuicao = Contribuicao(
        voluntarioId: widget.voluntario.id!,
        nomeVoluntario: widget.voluntario.nome,
        valor: valor,
        dataDoacao: _dataSelecionada,
        observacoes: null,
      );

      await _dbHelper.insertContribuicao(contribuicao);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contribuição registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _valorController.clear();
        _dataSelecionada = DateTime.now();
        _loadContribuicoes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar: $e'),
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

  Future<void> _excluirContribuicao(Contribuicao contribuicao) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir esta contribuição de ${_currencyFormat.format(contribuicao.valor)}?'),
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
      await _dbHelper.deleteContribuicao(contribuicao.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contribuição excluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadContribuicoes();
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      setState(() => _dataSelecionada = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalContribuicoes = _contribuicoes.fold<double>(
      0,
      (sum, c) => sum + c.valor,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Contribuições - ${widget.voluntario.nome}'),
        backgroundColor: Color(0xFF78909C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Formulário de cadastro
          Container(
            padding: const EdgeInsets.all(16),
            color: Color(0xFFECEFF1),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registrar Nova Contribuição',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _valorController,
                          decoration: const InputDecoration(
                            labelText: 'Valor (R\$) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe o valor';
                            }
                            final valor = double.tryParse(value.replaceAll(',', '.'));
                            if (valor == null || valor <= 0) {
                              return 'Valor inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _selecionarData,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Data *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            child: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _cadastrarContribuicao,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(_isSaving ? 'Salvando...' : 'Registrar Contribuição'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF78909C),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Total de contribuições
          Container(
            padding: const EdgeInsets.all(16),
            color: Color(0xFFCFD8DC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Contribuído:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF37474F),
                  ),
                ),
                Text(
                  _currencyFormat.format(totalContribuicoes),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ),

          // Lista de contribuições
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contribuicoes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on_outlined, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma contribuição registrada',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _contribuicoes.length,
                        itemBuilder: (context, index) {
                          final contribuicao = _contribuicoes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Icon(Icons.attach_money, color: Colors.green[700]),
                              ),
                              title: Text(
                                _currencyFormat.format(contribuicao.valor),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('dd/MM/yyyy').format(contribuicao.dataDoacao)),
                                  if (contribuicao.observacoes != null)
                                    Text(
                                      contribuicao.observacoes!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _excluirContribuicao(contribuicao),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
