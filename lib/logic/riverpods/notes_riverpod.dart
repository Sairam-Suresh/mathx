import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:mathx/logic/data_storage/database.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:mathx/logic/riverpods/db_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'notes_riverpod.g.dart';

@Riverpod(keepAlive: true)
class NotesRiverpod extends _$NotesRiverpod {
  @override
  FutureOr<List<MathNote>> build() async {
    var db = ref.read(databaseRiverpodProvider);

    return db.select(db.mathNotes).get();
  }

  Future createNewNoteAndGo(BuildContext? context) async {
    var db = ref.read(databaseRiverpodProvider);

    var uuidOfNewNote = (const Uuid().v1().toString());

    await db.into(db.mathNotes).insert(MathNotesCompanion(
        uuid: Value(uuidOfNewNote),
        name: const Value("New Note"),
        content: const Value(""),
        renderMath: const Value(true)));

    ref.invalidateSelf();

    context?.go("/notes/edit/$uuidOfNewNote?new=true");
  }

  Future<MathNote> obtainNoteByUUID(String uuid) {
    var db = ref.read(databaseRiverpodProvider);

    return (db.select(db.mathNotes)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingle();
  }

  Future<void> updateNoteEntryInDb(MathNote note) async {
    var db = ref.read(databaseRiverpodProvider);

    await (db.update(db.mathNotes)..where((t) => t.uuid.equals(note.uuid)))
        .write(MathNotesCompanion(
            name: Value(note.name),
            content: Value(note.content),
            renderMath: Value(note.renderMath),
            lastModifiedDate: Value(DateTime.now())));

    ref.invalidateSelf();
  }

  SingleSelectable<MathNote> watchNoteEntryByUUID(String uuid) {
    var db = ref.read(databaseRiverpodProvider);

    return db.select(db.mathNotes)..where((t) => t.uuid.equals(uuid));
  }

  Future saveNoteToDb(MathNote note) async {
    var db = ref.read(databaseRiverpodProvider);

    print(await getApplicationDocumentsDirectory());

    await db.into(db.mathNotes).insert(MathNotesCompanion(
          uuid: Value(note.uuid),
          name: Value(note.name),
          content: Value(note.content),
          renderMath: Value(note.renderMath),
          lastModifiedDate: Value(DateTime.now()),
        ));

    ref.invalidateSelf();
  }

  Future deleteNoteFromDb(MathNote note) async {
    var db = ref.read(databaseRiverpodProvider);

    await (db.delete(db.mathNotes)..where((tbl) => tbl.uuid.equals(note.uuid)))
        .go();

    ref.invalidateSelf();
  }
}
