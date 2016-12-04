// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:db_schema_migration/db_schema_migration.dart';
import 'package:test/test.dart';

void main() {
  group('Migrations', () {
    test('Integers', () {
      Migrations m = new Migrations();
      for (int i = 3; i > 0; i--) {
        m.add(i, 'SQL#$i');
      }
      expect(m.versions.map((v) => v.toString()).toList(),
          ['1.0.0', '2.0.0', '3.0.0']);
    });

    test('Date-based versions', () {
      Migrations m = new Migrations();
      for (int i = 3; i > 0; i--) {
        m.add('20161204.$i', 'SQL#$i');
      }
      expect(m.versions.map((v) => v.toString()).toList(),
          ['20161204.1.0', '20161204.2.0', '20161204.3.0']);
    });
  });
  group('DBSchemaMigrator', () {
    test('Repeated execution.', () async {
      var t = new TestDBSchemaMigrator();
      var migrations = new Migrations()..addAll({1: '#1', 2: '#2'});
      var v = await t.migrate(null, 'entity', migrations);
      expect(v, '2.0.0');
      expect(t.executed, ['#1', '#2']);
      expect(t.versions['entity'], '2.0.0');
      v = await t.migrate(null, 'entity', migrations);
      expect(v, '2.0.0');
      expect(t.executed, ['#1', '#2']);
      expect(t.versions['entity'], '2.0.0');
    });

    test('Incremental execution.', () async {
      var t = new TestDBSchemaMigrator();
      var migrations = new Migrations()..addAll({1: '#1', 2: '#2'});
      var v = await t.migrate(null, 'entity', migrations);
      expect(v, '2.0.0');
      expect(t.executed, ['#1', '#2']);
      expect(t.versions['entity'], '2.0.0');
      migrations = new Migrations()..addAll({1: '#1', 2: '#2', 3: '#3'});
      v = await t.migrate(null, 'entity', migrations);
      expect(v, '3.0.0');
      expect(t.executed, ['#1', '#2', '#3']);
      expect(t.versions['entity'], '3.0.0');
    });
  });
}

class TestDBSchemaMigrator extends DBSchemaMigrator {
  List<String> executed = [];
  bool initialized = false;
  Map<String, String> versions = {};

  @override
  Future executeSql(connection, String sql) async {
    executed.add(sql);
  }

  @override
  Future initializeBackingTable(dynamic connection) async {
    initialized = true;
  }

  @override
  Future<String> readVersion(dynamic connection, String name) async {
    return versions[name];
  }

  @override
  Future updateVersion(dynamic connection, String name, String version) async {
    versions[name] = version;
  }
}
