import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/animal.dart';
import '../models/responsavel.dart';
import '../models/voluntario.dart';
import '../models/contribuicao.dart';

/// Classe responsável por gerenciar o banco de dados SQLite
/// Implementa o padrão Singleton para garantir uma única instância
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Retorna a instância do banco de dados
  Future<Database> get database async {
    if (_database != null) return _database!;
    print('Inicializando banco de dados...');
    _database = await _initDatabase();
    print('Banco de dados inicializado!');
    return _database!;
  }

  /// Inicializa o banco de dados
  Future<Database> _initDatabase() async {
    print('Abrindo banco de dados...');
    
    // Para web, usar nome simples. Para mobile/desktop, usar path completo
    String dbPath;
    if (kIsWeb) {
      dbPath = 'ong_castracao.db';
    } else {
      dbPath = 'ong_castracao.db';
    }
    
    final db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    print('Banco de dados aberto!');
    return db;
  }

  /// Atualiza o banco de dados quando a versão muda
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop tabelas antigas e recria
      await db.execute('DROP TABLE IF EXISTS animais');
      await db.execute('DROP TABLE IF EXISTS voluntarios');
      await db.execute('DROP TABLE IF EXISTS contribuicoes');
      await _onCreate(db, newVersion);
    }
  }

  /// Cria as tabelas do banco de dados
  Future<void> _onCreate(Database db, int version) async {
    // Tabela de responsáveis
    await db.execute('''
      CREATE TABLE responsaveis(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        telefone TEXT NOT NULL,
        endereco TEXT NOT NULL,
        dataCadastro TEXT NOT NULL
      )
    ''');

    // Tabela de animais (agora com responsavelId nullable)
    await db.execute('''
      CREATE TABLE animais(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeAnimal TEXT NOT NULL,
        responsavelId INTEGER,
        status TEXT NOT NULL,
        observacoes TEXT,
        dataCadastro TEXT NOT NULL,
        dataCastracao TEXT,
        FOREIGN KEY (responsavelId) REFERENCES responsaveis (id) ON DELETE SET NULL
      )
    ''');

    // Tabela de voluntários
    await db.execute('''
      CREATE TABLE voluntarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        telefone TEXT NOT NULL,
        email TEXT NOT NULL,
        ativo INTEGER NOT NULL DEFAULT 1,
        dataCadastro TEXT NOT NULL,
        observacoes TEXT
      )
    ''');

    // Tabela de contribuições
    await db.execute('''
      CREATE TABLE contribuicoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voluntarioId INTEGER NOT NULL,
        nomeVoluntario TEXT NOT NULL,
        valor REAL NOT NULL,
        dataDoacao TEXT NOT NULL,
        observacoes TEXT,
        FOREIGN KEY (voluntarioId) REFERENCES voluntarios (id)
      )
    ''');
  }

  // ==================== OPERAÇÕES CRUD - RESPONSÁVEIS ====================

  /// CREATE: Insere um novo responsável no banco de dados
  Future<int> insertResponsavel(Responsavel responsavel) async {
    Database db = await database;
    return await db.insert('responsaveis', responsavel.toMap());
  }

  /// READ: Retorna todos os responsáveis do banco de dados
  Future<List<Responsavel>> getAllResponsaveis() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('responsaveis', orderBy: 'nome ASC');
    return List.generate(maps.length, (i) => Responsavel.fromMap(maps[i]));
  }

  /// READ: Retorna um responsável específico pelo ID
  Future<Responsavel?> getResponsavel(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'responsaveis',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Responsavel.fromMap(maps.first);
  }

  /// UPDATE: Atualiza um responsável existente
  Future<int> updateResponsavel(Responsavel responsavel) async {
    Database db = await database;
    return await db.update(
      'responsaveis',
      responsavel.toMap(),
      where: 'id = ?',
      whereArgs: [responsavel.id],
    );
  }

  /// DELETE: Remove um responsável do banco de dados
  Future<int> deleteResponsavel(int id) async {
    Database db = await database;
    // Os animais associados terão responsavelId = NULL automaticamente (ON DELETE SET NULL)
    return await db.delete(
      'responsaveis',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== OPERAÇÕES CRUD - ANIMAIS ====================

  /// CREATE: Insere um novo animal no banco de dados
  Future<int> insertAnimal(Animal animal) async {
    Database db = await database;
    return await db.insert('animais', animal.toMap());
  }

  /// READ: Retorna todos os animais do banco de dados
  Future<List<Animal>> getAllAnimais() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('animais', orderBy: 'dataCadastro DESC');
    return List.generate(maps.length, (i) => Animal.fromMap(maps[i]));
  }

  /// READ: Retorna um animal específico pelo ID
  Future<Animal?> getAnimal(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'animais',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Animal.fromMap(maps.first);
  }

  /// READ: Retorna animais por status
  Future<List<Animal>> getAnimaisByStatus(String status) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'animais',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'dataCadastro DESC',
    );
    return List.generate(maps.length, (i) => Animal.fromMap(maps[i]));
  }

  /// UPDATE: Atualiza um animal existente
  Future<int> updateAnimal(Animal animal) async {
    Database db = await database;
    return await db.update(
      'animais',
      animal.toMap(),
      where: 'id = ?',
      whereArgs: [animal.id],
    );
  }

  /// DELETE: Remove um animal do banco de dados
  Future<int> deleteAnimal(int id) async {
    Database db = await database;
    return await db.delete('animais', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== OPERAÇÕES CRUD - VOLUNTÁRIOS ====================

  /// CREATE: Insere um novo voluntário no banco de dados
  Future<int> insertVoluntario(Voluntario voluntario) async {
    Database db = await database;
    return await db.insert('voluntarios', voluntario.toMap());
  }

  /// READ: Retorna todos os voluntários do banco de dados
  Future<List<Voluntario>> getAllVoluntarios() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('voluntarios', orderBy: 'nome ASC');
    return List.generate(maps.length, (i) => Voluntario.fromMap(maps[i]));
  }

  /// READ: Retorna apenas voluntários ativos
  Future<List<Voluntario>> getVoluntariosAtivos() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'voluntarios',
      where: 'ativo = ?',
      whereArgs: [1],
      orderBy: 'nome ASC',
    );
    return List.generate(maps.length, (i) => Voluntario.fromMap(maps[i]));
  }

  /// READ: Retorna um voluntário específico pelo ID
  Future<Voluntario?> getVoluntario(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'voluntarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Voluntario.fromMap(maps.first);
  }

  /// UPDATE: Atualiza um voluntário existente
  Future<int> updateVoluntario(Voluntario voluntario) async {
    Database db = await database;
    return await db.update(
      'voluntarios',
      voluntario.toMap(),
      where: 'id = ?',
      whereArgs: [voluntario.id],
    );
  }

  /// DELETE: Remove um voluntário do banco de dados
  Future<int> deleteVoluntario(int id) async {
    Database db = await database;
    return await db.delete('voluntarios', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== OPERAÇÕES CRUD - CONTRIBUIÇÕES ====================

  /// CREATE: Insere uma nova contribuição no banco de dados
  Future<int> insertContribuicao(Contribuicao contribuicao) async {
    Database db = await database;
    return await db.insert('contribuicoes', contribuicao.toMap());
  }

  /// READ: Retorna todas as contribuições do banco de dados
  Future<List<Contribuicao>> getAllContribuicoes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contribuicoes', orderBy: 'dataDoacao DESC');
    return List.generate(maps.length, (i) => Contribuicao.fromMap(maps[i]));
  }

  /// READ: Retorna contribuições de um voluntário específico
  Future<List<Contribuicao>> getContribuicoesByVoluntario(int voluntarioId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contribuicoes',
      where: 'voluntarioId = ?',
      whereArgs: [voluntarioId],
      orderBy: 'dataDoacao DESC',
    );
    return List.generate(maps.length, (i) => Contribuicao.fromMap(maps[i]));
  }

  /// READ: Retorna uma contribuição específica pelo ID
  Future<Contribuicao?> getContribuicao(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contribuicoes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Contribuicao.fromMap(maps.first);
  }

  /// UPDATE: Atualiza uma contribuição existente
  Future<int> updateContribuicao(Contribuicao contribuicao) async {
    Database db = await database;
    return await db.update(
      'contribuicoes',
      contribuicao.toMap(),
      where: 'id = ?',
      whereArgs: [contribuicao.id],
    );
  }

  /// DELETE: Remove uma contribuição do banco de dados
  Future<int> deleteContribuicao(int id) async {
    Database db = await database;
    return await db.delete('contribuicoes', where: 'id = ?', whereArgs: [id]);
  }

  /// Retorna o total de contribuições
  Future<double> getTotalContribuicoes() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT SUM(valor) as total FROM contribuicoes');
    return (result.first['total'] as double?) ?? 0.0;
  }

  // ==================== ESTATÍSTICAS ====================

  /// Retorna a quantidade de animais por status
  Future<Map<String, int>> getAnimaisCountByStatus() async {
    Database db = await database;
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count 
      FROM animais 
      GROUP BY status
    ''');
    
    Map<String, int> counts = {};
    for (var row in result) {
      counts[row['status'] as String] = row['count'] as int;
    }
    return counts;
  }

  /// Retorna a quantidade total de animais
  Future<int> getTotalAnimais() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM animais');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Retorna a quantidade de voluntários ativos
  Future<int> getTotalVoluntariosAtivos() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM voluntarios WHERE ativo = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Fecha o banco de dados
  Future<void> close() async {
    Database db = await database;
    db.close();
  }
}
