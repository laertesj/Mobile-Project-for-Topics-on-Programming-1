import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Esta classe é responsável por criar os moldes das minhas contas que serão inseridas no banco de dados

// aqui definimos as colunas da nossa base tabela no banco
final String contaTable = "contaTable";
final String idColumn = "idColumn";
final String descricaoColumn = "descricaoColumn";
final String estabelecimentoColumn = "estabelecimentoColumn";
final String valorColumn = "valorColumn";
final String contaParceladaColumn = "contaParceladaColumn";
final String qntdParcelasColumn = "qntdParcelasColumn";
final String situacaoColumn = "situacaoColumn";

class ContaHelper {
  // criando um padrão singleton para nossa classe ContactHelper
  static final ContaHelper _instance = ContaHelper.internal();

  factory ContaHelper() => _instance;

  ContaHelper.internal();

  Database _db;

  Future<Database> get db async {
    if(_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    // pega o local do banco de dados
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contasNew.db");

    // cria a tabela do banco
    return openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contaTable($idColumn INTEGER PRIMARY KEY,  $descricaoColumn TEXT, $estabelecimentoColumn TEXT,"
              "$valorColumn TEXT, $contaParceladaColumn TEXT, $qntdParcelasColumn TEXT, $situacaoColumn TEXT)"
      );
    });
  }

  Future<Conta> saveConta(Conta conta) async { // salva uma conta passando a conta desejada
    Database dbConta = await db; // obtendo o banco de dados
    // inserindo a conta na tabela do banco (necessário converter para Map)
    conta.id = await dbConta.insert(contaTable, conta.toMap()); // ele atribui um id a conta independente se ela ja tem um id ou não
    return conta;
  }

  // obter dados de uma conta
  Future<Conta> getConta(int id) async {
    Database dbConta = await db; // obtendo o banco de dados
    List<Map> maps = await dbConta.query(contaTable,
        columns: [idColumn, descricaoColumn, estabelecimentoColumn, valorColumn, contaParceladaColumn,
          qntdParcelasColumn, situacaoColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if(maps.length > 0) {
      return Conta.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // removendo uma conta do banco de dados
  // é do tipo Future<int> pq a deleção retorna um numero inteiro informando se deu certo ou não
  Future<int> deleteConta(int id) async {
    Database dbConta = await db; // obtendo o banco de dados
    return await dbConta.delete(contaTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  // atualiza uma conta no banco de dados
  Future<int> updateConta(Conta conta) async {
    Database dbConta = await db; // obtendo o banco de dados
    return await dbConta.update(contaTable,
        conta.toMap(),
        where: "$idColumn = ?",
        whereArgs: [conta.id]);
  }

  // obter toda a lista de contas
  Future<List> getAllContas() async {
    Database dbConta = await db; // obtendo o banco de dados
    // cria-se uma lista de mapas para armazenar as contas
    List listMap = await dbConta.rawQuery("SELECT * FROM $contaTable");
    List<Conta> listConta = List();
    // porém, um mapa não é uma conta, nós queremos uma lista, logo convertemos toda a lista de mapas somente em Lista
    for(Map m in listMap) {
      listConta.add(Conta.fromMap(m));
    }
    return listConta;
  }

  // obter o numero de contas da lista
  Future<int> getNumber() async {
    Database dbConta = await db; // obtendo o banco de dados
    return Sqflite.firstIntValue(await dbConta.rawQuery("SELECT COUNT(*) FROM $contaTable"));
  }

  // obter os valores totais de uma coluna
  Future<String> getTotalValue() async {
    Database dbContact = await db;
    var total = await dbContact.rawQuery("SELECT SUM($valorColumn) FROM $contaTable");
    double value = total[0]["SUM($valorColumn"];
    return value.toString();
  }

  Future close() async {
    Database dbConta = await db; // obtendo o banco de dados
    dbConta.close();
  }

}

// classe Contas para instanciar um novo contato
class Conta {
  int id;
  String descricao;
  String estabelecimento;
  String valor;
  String contaParcelada;
  String qntdParcelas;
  String situacao;

  Conta();

  // obtem os dados da conta através de um mapa
  // pega os dados de um mapa e atribui aos dados de conta
  Conta.fromMap(Map map) {
    id = map[idColumn];
    descricao = map[descricaoColumn];
    estabelecimento = map[estabelecimentoColumn];
    valor = map[valorColumn];
    contaParcelada = map[contaParceladaColumn];
    qntdParcelas = map[qntdParcelasColumn];
    situacao = map[situacaoColumn];
  }

  // esta função pega os dados do contato e transforma em um mapa
  Map toMap() {
    Map<String, dynamic> map = {
      descricaoColumn: descricao,
      estabelecimentoColumn: estabelecimento,
      valorColumn: valor,
      contaParceladaColumn: contaParcelada,
      qntdParcelasColumn: qntdParcelas,
      situacaoColumn: situacao
    };
    if(id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Conta (id: $id, descrição: $descricao, estabelecimento: $estabelecimento, valor: $valor,"
        "contaParcelada: $contaParcelada, qntdParcelas: $qntdParcelas, situacao: $situacao)";
  }

}