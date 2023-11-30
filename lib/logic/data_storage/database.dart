// These imports are necessary to open the sqlite3 database
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mathx/logic/cheatsheets/cheatsheets_extraction_helper.dart';
import 'package:mathx/logic/data_storage/tables/cheatsheets.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/v1.dart';

part 'database.g.dart';

@DriftDatabase(tables: [MathNotes, Cheatsheets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        await batch((batch) {
          batch.insertAll(
              cheatsheets,
              cheatSheetList.map((e) => CheatsheetsCompanion(
                    name: Value(e.name),
                    secondaryLevel: Value(e.secondaryLevel),
                    starred: Value(e.starred),
                    comingSoon: Value(e.comingSoon),
                  )));
        });

        await extractCheatsheets();
        print(await getApplicationDocumentsDirectory());
      },
    );
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
