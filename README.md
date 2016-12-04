# Database schema migration

A database schema migration tool, to execute the proper sequence of
SQL commands that are required to get your DB to the desired state.

The sequence of operations is defined by the sorted order of versions.
Versions are [semver](http://semver.org/), and single numbers (`1`, `2`)
will be transformed accordingly (`1.0.0`, `2.0.0`). 

## Usage

A simple usage example:

    import 'dart:async';
    
    import 'package:db_schema_migration/db_schema_migration.dart';
    import 'package:db_schema_migration/postgresql.dart';
    
    import 'package:postgresql/postgresql.dart';
    
    Future main() async {
      Connection connection = await _getConnection();
      var migrator = new PostgresqlSchemaMigrator();
      var migrations = new Migrations();
      migrations.add(1,
          'CREATE TABLE user(name VARCHAR(127) PRIMARY KEY, password_hash VARCHAR(127));');
      migrations.add(2, 'ALTER TABLE user ADD COLUMN address varchar(127);');
      await migrator.migrate(connection, 'user', migrations);
      // Now the DB has a user table with name, password_hash and address columns.
    }

## Some usage patterns

How to group migrations:
- per-table migration scripts
  - for each table, there is a separate sequence of migrations
  - foreign keys must be run as separate migrations after the regular tables are done
- per-package migration scripts (recommended)
  - related tables, FKs and indexes are sharing a sequence of migrations

How to version migrations:
- regular numbers: `1`, `2`, `3`, ...
- date + number: `20161204.1`, `20161204.2`, ...
- date + package id + sequence: `20161204.134.1`, `20161204.134.2`, ...

## Links

- [source code][source]
- contributors: [Agilord][agilord]

[source]: https://github.com/agilord/db_schema_migration
[agilord]: https://www.agilord.com/
