/// Modelo de dados para representar um voluntário
class Voluntario {
  int? id;
  String nome;
  String telefone;
  String email;
  bool ativo;
  DateTime dataCadastro;
  String? observacoes;

  Voluntario({
    this.id,
    required this.nome,
    required this.telefone,
    required this.email,
    this.ativo = true,
    required this.dataCadastro,
    this.observacoes,
  });

  /// Converte o objeto Voluntario para um Map (usado para inserir no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'ativo': ativo ? 1 : 0,
      'dataCadastro': dataCadastro.toIso8601String(),
      'observacoes': observacoes,
    };
  }

  /// Cria um objeto Voluntario a partir de um Map (usado ao consultar o banco de dados)
  factory Voluntario.fromMap(Map<String, dynamic> map) {
    return Voluntario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      email: map['email'] as String,
      ativo: (map['ativo'] as int) == 1,
      dataCadastro: DateTime.parse(map['dataCadastro'] as String),
      observacoes: map['observacoes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Voluntario{id: $id, nome: $nome, telefone: $telefone, ativo: $ativo}';
  }
}
