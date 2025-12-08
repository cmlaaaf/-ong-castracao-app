/// Modelo de dados para representar um animal castrado
class Animal {
  int? id;
  String nomeAnimal;
  int? responsavelId; // Nullable - permite animal sem dono
  String status; // 'Aguardando', 'Castrado', 'Em Recuperação'
  String? observacoes;
  DateTime dataCadastro;
  DateTime? dataCastracao;

  Animal({
    this.id,
    required this.nomeAnimal,
    this.responsavelId,
    required this.status,
    this.observacoes,
    required this.dataCadastro,
    this.dataCastracao,
  });

  /// Converte o objeto Animal para um Map (usado para inserir no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeAnimal': nomeAnimal,
      'responsavelId': responsavelId,
      'status': status,
      'observacoes': observacoes,
      'dataCadastro': dataCadastro.toIso8601String(),
      'dataCastracao': dataCastracao?.toIso8601String(),
    };
  }

  /// Cria um objeto Animal a partir de um Map (usado ao consultar o banco de dados)
  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'] as int?,
      nomeAnimal: map['nomeAnimal'] as String,
      responsavelId: map['responsavelId'] as int?,
      status: map['status'] as String,
      observacoes: map['observacoes'] as String?,
      dataCadastro: DateTime.parse(map['dataCadastro'] as String),
      dataCastracao: map['dataCastracao'] != null
          ? DateTime.parse(map['dataCastracao'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'Animal{id: $id, nomeAnimal: $nomeAnimal, responsavelId: $responsavelId, status: $status}';
  }
}
