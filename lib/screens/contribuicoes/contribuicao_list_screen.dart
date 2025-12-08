import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/contribuicao.dart';
import '../../database/database_helper.dart';
import 'add_contribuicao_screen.dart';

class ContribuicaoListScreen extends StatefulWidget {
  const ContribuicaoListScreen({Key? key}) : super(key: key);

  @override
  State<ContribuicaoListScreen> createState() => _ContribuicaoListScreenState();
}

class _ContribuicaoListScreenState extends State<ContribuicaoListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Contribuicao> _contribuicoes = [];
  bool _isLoading = true;
  double _totalContribuicoes = 0.0;

  @override
  void initState() {
    super.initState();
    _loadContribuicoes();
  }

  Future<void> _loadContribuicoes() async {
    setState(() => _isLoading = true);
    
    final contribuicoes = await _dbHelper.getAllContribuicoes();
    final total = await _dbHelper.getTotalContribuicoes();
    
    setState(() {
      _contribuicoes = contribuicoes;
      _totalContribuicoes = total;
      _isLoading = false;
    });
  }

  Future<void> _navigateToAddContribuicao() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContribuicaoScreen()),
    );

    if (result == true) _loadContribuicoes();
  }

  Future<void> _deleteContribuicao(Contribuicao contribuicao) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja excluir esta contribuição de R\$ ${contribuicao.valor.toStringAsFixed(2)}?'),
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
        await _dbHelper.deleteContribuicao(contribuicao.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contribuição excluída!'), backgroundColor: Colors.orange),
        );
        _loadContribuicoes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contribuições'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green[100],
            child: Column(
              children: [
                const Text('Total Arrecadado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(_totalContribuicoes),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contribuicoes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on, size: 100, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Nenhuma contribuição registrada',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _contribuicoes.length,
                        itemBuilder: (context, index) {
                          final contrib = _contribuicoes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: const Icon(Icons.attach_money, color: Colors.white),
                              ),
                              title: Text(contrib.nomeVoluntario,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Data: ${DateFormat('dd/MM/yyyy').format(contrib.dataDoacao)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currencyFormat.format(contrib.valor),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteContribuicao(contrib),
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
        onPressed: _navigateToAddContribuicao,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
