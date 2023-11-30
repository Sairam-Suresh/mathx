import 'package:mathx/logic/data_storage/tables/cheatsheets.dart';
import 'package:mathx/logic/riverpods/db_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cheatsheets_riverpod.g.dart';

@riverpod
class CheatsheetsRiverpod extends _$CheatsheetsRiverpod {
  @override
  FutureOr<List<Cheatsheet>> build() async {
    var db = ref.read(databaseRiverpodProvider);

    return db.select(db.cheatsheets).get();
  }
}
