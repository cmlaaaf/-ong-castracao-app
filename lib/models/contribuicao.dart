/// Modelo de dados para representar uma contribuição mensal
class Contribuicao {
  int? id;
  int voluntarioId;
  String nomeVoluntario;
  double valor;
  DateTime dataDoacao;
  String? observacoes;

  Contribuicao({
    this.id,
    required this.voluntarioId,
    required this.nomeVoluntario,
    required this.valor,
    required this.dataDoacao,
    this.observacoes,
  });

  /// Converte o objeto Contribuicao para um Map (usado para inserir no banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voluntarioId': voluntarioId,
      'nomeVoluntario': nomeVoluntario,
      'valor': valor,
      'dataDoacao': dataDoacao.toIso8601String(),
      'observacoes': observacoes,
    };
  }

  /// Cria um objeto Contribuicao a partir de um Map (usado ao consultar o banco de dados)
  factory Contribuicao.fromMap(Map<String, dynamic> map) {
    return Contribuicao(
      id: map['id'] as int?,
      voluntarioId: map['voluntarioId'] as int,
      nomeVoluntario: map['nomeVoluntario'] as String,
      valor: map['valor'] as double,
      dataDoacao: DateTime.parse(map['dataDoacao'] as String),
      observacoes: map['observacoes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Contribuicao{id: $id, nomeVoluntario: $nomeVoluntario, valor: $valor, data: $dataDoacao}';
  }
}
