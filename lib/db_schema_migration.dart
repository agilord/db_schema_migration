// Copyright (c) 2016, Agilord. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:pub_semver/pub_semver.dart' show Version;

/// The set of migrations with their (semantic) versions that create the
/// ordering of the SQL statements to be executed.
class Migrations {
  Map<Version, String> _migrations = {};

  /// Add a new migration SQL to the set.
  void add(dynamic version, String sql) {
    if (version == null) {
      throw new Exception('Version mustn\'t be null.');
    }
    // Workaround until Version.parse handles incomplete versions.
    final List<String> t = '$version'.split('.');
    while (t.length < 3) t.add('0');
    final Version v = new Version.parse(t.join('.'));
    if (_migrations.containsKey(v)) {
      throw new Exception('Version key already in use: $version');
    }
    _migrations[v] = sql;
  }

  /// Add a map of migration SQL where the map key is already the version.
  void addAll(Map<dynamic, String> migrations) => migrations.forEach(add);

  /// List all versions in a semantically ascending order.
  List<Version> get versions => _migrations.keys.toList()..sort();

  /// Get the SQL statement for the given version.
  String getSql(Version version) => _migrations[version];
}

/// Base class for schema migration, which abstracts away the database-specific
/// code.
abstract class DBSchemaMigrator<C> {
  /// Initialize the backing table where we store the current versions.
  Future initializeBackingTable(C connection);

  /// Read the current version for the key `name`.
  Future<String> readVersion(C connection, String name);

  /// Updates the version for the key `name`.
  Future updateVersion(C connection, String name, String version);

  /// Executes a SQL command.
  Future executeSql(C connection, String sql);

  /// Migrate the current database to the latest version.
  Future<String> migrate(
      C connection, String name, Migrations migrations) async {
    await initializeBackingTable(connection);
    for (Version version in migrations.versions) {
      final String cv = await readVersion(connection, name);
      final Version current = cv == null ? Version.none : new Version.parse(cv);
      if (current < version) {
        final String sql = migrations.getSql(version);
        await executeSql(connection, sql);
        await updateVersion(connection, name, version.toString());
      }
    }
    return await readVersion(connection, name);
  }
}
