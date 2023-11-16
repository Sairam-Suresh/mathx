import 'package:drift/drift.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get content => text()();
  DateTimeColumn get lastModifiedDate => dateTime()();
  BoolColumn get renderMath => boolean()();
}
