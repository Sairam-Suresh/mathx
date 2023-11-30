import 'package:drift/drift.dart' hide JsonKey;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cheatsheets.freezed.dart';

@UseRowClass(Cheatsheet)
class Cheatsheets extends Table {
  IntColumn get id => integer().autoIncrement()();

  // We use a special UUID instead of the actual ID since it would make it more
  // complicated to attempt to use the ID with a Frozen class.
  TextColumn get name => text()();
  IntColumn get secondaryLevel =>
      integer().check(secondaryLevel.isBetweenValues(1, 4))();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  BoolColumn get comingSoon => boolean().withDefault(const Constant(false))();
}

// Custom row class for the Notes table

@freezed
class Cheatsheet with _$Cheatsheet {
  factory Cheatsheet(
      {required String name,
      required int secondaryLevel,
      required bool starred,
      required bool comingSoon}) = _Cheatsheet;
}
