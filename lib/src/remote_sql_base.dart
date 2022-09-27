
import 'package:mysql1/mysql1.dart';
import 'package:postgres_pool/postgres_pool.dart';

final _kDialects = ['mySql', 'postgres'];

class QueryResults {
  final int? insertId;
  final int? affectedRows;
  final List<Map<String, dynamic>> rows;

  QueryResults(this.insertId, this.affectedRows, this.rows);

  QueryResults.empty()
      : insertId = null,
        affectedRows = 0,
        rows = [];
}

class RemoteSqlConnection {
  final Object? _connection;
  final String? _dialect;

  RemoteSqlConnection._(this._dialect, this._connection);

  static Future<RemoteSqlConnection> connect({
    required String dialect,
    required String host,
    required int port,
    String? user,
    String? password,
    required String db,
  }) async {
    if (!_kDialects.contains(dialect)) {
      throw Exception("unknown dialect, supported: $_kDialects");
    }

    Object? _connection;
    if (dialect == 'mySql') {
      _connection = await MySqlConnection.connect(
          ConnectionSettings(host: host, port: port, user: user, password: password, db: db));
    } else if (dialect == 'postgres') {

      // _connection = PostgreSQLConnection(host, 5432, db, username: user, password: password,
      //   timeoutInSeconds: 600,
      //   allowClearTextPassword: true,
      // );
      // await (_connection as PostgreSQLConnection).open();

      _connection = PgPool(
        PgEndpoint(
          host: host,
          port: 5432,
          database: db,
          username: user,
          password: password,
        ),
        settings: PgPoolSettings()
          ..maxConnectionAge = Duration(hours: 4)
          ..concurrency = 8,
      );


    }
    return RemoteSqlConnection._(dialect, _connection!);
  }

  Future<void> close() async {
    if (_dialect == 'mySql') {
      await (_connection as MySqlConnection).close();
    }
    else if (_dialect == 'postgres'){
      await (_connection as PgPool).close();
    }
  }

  Future<QueryResults?> query(String sql) async {
    if (_dialect == 'mySql') {
      Results results = await (_connection as MySqlConnection).query(sql);
      return QueryResults(
          results.insertId, results.affectedRows, results.map((item) => item.fields).toList());
    }
    if (_dialect == 'postgres') {
      PostgreSQLResult results = await (_connection as PgPool).query(
          sql.replaceAll('`', "'"));
      // PostgreSQLResult results = await (_connection as PostgreSQLConnection).query(
      //     sql.replaceAll('`', "'"));

      return QueryResults(
          null, results.affectedRowCount, results.map((item) => item.toColumnMap()).toList());
    }
    return null;
  }
}
