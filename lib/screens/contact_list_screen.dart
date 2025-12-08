import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../database/database_helper.dart';
import 'add_contact_screen.dart';
import 'contact_detail_screen.dart';

/// Tela principal que exibe a lista de todos os contatos
class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  /// Carrega todos os contatos do banco de dados
  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await _dbHelper.getAllContacts();
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  /// Navega para a tela de adicionar contato
  Future<void> _navigateToAddContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContactScreen()),
    );

    // Se um contato foi adicionado, recarrega a lista
    if (result == true) {
      _loadContacts();
    }
  }

  /// Navega para a tela de detalhes do contato
  Future<void> _navigateToContactDetail(Contact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailScreen(contact: contact),
      ),
    );

    // Se houve alteração (edição ou exclusão), recarrega a lista
    if (result == true) {
      _loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Contatos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? _buildEmptyState()
          : _buildContactList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddContact,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Exibe uma mensagem quando não há contatos
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum contato cadastrado',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Exibe a lista de contatos
  Widget _buildContactList() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                contact.nome.isNotEmpty ? contact.nome[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              contact.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(contact.telefone),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToContactDetail(contact),
          ),
        );
      },
    );
  }
}
