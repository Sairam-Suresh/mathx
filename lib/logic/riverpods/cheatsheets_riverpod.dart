import 'package:drift/drift.dart';
import 'package:mathx/logic/data_storage/database.dart';
import 'package:mathx/logic/data_storage/tables/cheatsheets.dart';
import 'package:mathx/logic/riverpods/db_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cheatsheets_riverpod.g.dart';

@riverpod
class CheatsheetsRiverpod extends _$CheatsheetsRiverpod {
  @override
  FutureOr<List<Cheatsheet>> build() async {
    var db = ref.read(databaseRiverpodProvider);

    return db.select(db.cheatsheets).get();
  }

  // Cheatsheet itself, followed by a link to it.
  Future<(Cheatsheet, String)> obtainCheatsheetByName(String name) async {
    var db = ref.read(databaseRiverpodProvider);

    var targetSheet = await ((db.select(db.cheatsheets)
          ..where((tbl) => tbl.name.equals(name)))
        .getSingle());

    var pathToSheet =
        "${(await getApplicationDocumentsDirectory()).path}/cheatsheets/pdfs/${targetSheet.name}.pdf";

    return (targetSheet, pathToSheet);
  }

  Future<List<Cheatsheet>> obtainAllLikedCheatsheets() async {
    var db = ref.read(databaseRiverpodProvider);

    return (db.select(db.cheatsheets)..where((tbl) => tbl.starred.equals(true)))
        .get();
  }

  Future toggleCheatsheetLikeStatus(Cheatsheet sheet) async {
    var db = ref.read(databaseRiverpodProvider);

    await (db.update(db.cheatsheets)
          ..where((tbl) => tbl.name.equals(sheet.name)))
        .write(CheatsheetsCompanion(
      starred: Value(!sheet.starred),
    ));

    ref.invalidateSelf();
  }
}
