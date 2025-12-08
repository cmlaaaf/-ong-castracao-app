/// Modelo de dados para representar um contato
class Contact {
  int? id;
  String nome;
  String telefone;
  String email;

  Contact({
    this.id,
    required this.nome,
    required this.telefone,
    required this.email,
  });

  /// Converte o objeto Contact para um Map (usado para inserir no banco de dados)
  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'telefone': telefone, 'email': email};
  }

  /// Cria um objeto Contact a partir de um Map (usado ao consultar o banco de dados)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String,
    );
  }

  @override
  String toString() {
    return 'Contact{id: $id, nome: $nome, telefone: $telefone, email: $email}';
  }
}
