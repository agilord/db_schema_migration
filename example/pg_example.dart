// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:db_schema_migration/db_schema_migration.dart';
import 'package:db_schema_migration/postgresql.dart';

import 'package:postgresql/postgresql.dart';

Future main() async {
  final Connection connection = await _getConnection();
  final migrator = new PostgresqlSchemaMigrator();
  final migrations = new Migrations();
  migrations.add(1,
      'CREATE TABLE user(name VARCHAR(127) PRIMARY KEY, password_hash VARCHAR(127));');
  migrations.add(2, 'ALTER TABLE user ADD COLUMN address varchar(127);');
  await migrator.migrate(connection, 'account', migrations);
  // Now the DB has a user table with name, password_hash and address columns.
}

Future<Connection> _getConnection() async => null;
