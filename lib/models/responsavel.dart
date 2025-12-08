class Responsavel {
  int? id;
  String nome;
  String telefone;
  String endereco;
  String dataCadastro;

  Responsavel({
    this.id,
    required this.nome,
    required this.telefone,
    required this.endereco,
    required this.dataCadastro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'endereco': endereco,
      'dataCadastro': dataCadastro,
    };
  }

  factory Responsavel.fromMap(Map<String, dynamic> map) {
    return Responsavel(
      id: map['id'],
      nome: map['nome'],
      telefone: map['telefone'],
      endereco: map['endereco'],
      dataCadastro: map['dataCadastro'],
    );
  }
}
