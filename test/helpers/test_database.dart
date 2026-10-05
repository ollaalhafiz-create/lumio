import 'dart:ffi';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart';

/// Points the `sqlite3` package at the system library on Linux.
///
/// The published package resolves the library by name, which works on Android
/// and macOS but not on a Debian container where the file is versioned. Failing
/// here would surface as an opaque "cannot open shared object" error, so the
/// known locations are probed once at startup.
void useSystemSqlite() {
  if (!Platform.isLinux) {
    sqfliteFfiInit();
    return;
  }

  const List<String> candidates = <String>[
    '/usr/lib/x86_64-linux-gnu/libsqlite3.so',
    '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
    '/lib/x86_64-linux-gnu/libsqlite3.so.0',
  ];

  for (final String candidate in candidates) {
    try {
      DynamicLibrary.open(candidate);
    } on ArgumentError {
      continue;
    }
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open(candidate),
    );
    break;
  }

  sqfliteFfiInit();
}

/// The factory used by every database test.
DatabaseFactory get testDatabaseFactory => databaseFactoryFfiNoIsolate;
