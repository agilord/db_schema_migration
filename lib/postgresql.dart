// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:db_schema_migration/db_schema_migration.dart';
import 'package:postgresql/postgresql.dart';

/// Postgresql schema migration using the `postgresql` library.
/// Stores the current versions in the `schema_version` table.
class PostgresqlSchemaMigrator extends DBSchemaMigrator<Connection> {
  Set<String> _names = new Set();
  String _tableName;

  PostgresqlSchemaMigrator({String schema, String table: 'schema_version'}) {
    if (schema != null) {
      _tableName = '$schema.$table';
    } else {
      _tableName = table;
    }
  }

  @override
  Future executeSql(Connection connection, String sql) =>
      connection.execute(sql);

  @override
  Future initializeBackingTable(Connection connection) async {
    if (_names.isNotEmpty) return;
    await connection.execute('CREATE TABLE IF NOT EXISTS '
        '$_tableName('
        'name VARCHAR(127) PRIMARY KEY, '
        'version VARCHAR(127), '
        'updated TIMESTAMP);');
  }

  @override
  Future<String> readVersion(Connection connection, String name) async {
    List<Row> rows = await connection.query(
        'SELECT version FROM $_tableName WHERE name = @0', [name]).toList();
    return rows.isEmpty ? null : rows[0][0];
  }

  @override
  Future updateVersion(
      Connection connection, String name, String version) async {
    bool exists = _names.contains(name);
    if (!exists) {
      String cv = await readVersion(connection, name);
      exists = cv != null;
    }
    if (exists) {
      await connection.execute(
          'UPDATE $_tableName SET updated = now(), version = @0 WHERE name = @1',
          [version, name]);
    } else {
      await connection.execute(
          'INSERT INTO $_tableName VALUES (@0, @1, now())', [name, version]);
      _names.add(name);
    }
  }
}
