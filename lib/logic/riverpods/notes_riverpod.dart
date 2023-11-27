import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:mathx/logic/data_storage/database.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:mathx/logic/riverpods/db_riverpod.dart';
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

    context?.go("/notes/view/$uuidOfNewNote");
  }
}
