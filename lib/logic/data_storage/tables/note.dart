import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';

@UseRowClass(Note)
class MathNotes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid =>
      text().withDefault(Constant(const UuidV1().generate().toString()))();
  TextColumn get name => text()();
  TextColumn get content => text()();
  DateTimeColumn get lastModifiedDate =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get renderMath => boolean().withDefault(const Constant(true))();
}

// Custom row class for the Notes table
class Note {
  final String uuid;
  final String name;
  final String content;
  final DateTime lastModifiedDate;
  final bool renderMath;

  Note(
      {required this.uuid,
      required this.name,
      required this.content,
      required this.lastModifiedDate,
      required this.renderMath});

  factory Note.fromDeepLink(Uri uri) {
    var decodedData = utf8.decode(base64Decode(uri.queryParameters["source"]!));
    var extractedData = decodedData.split(" ␢␆␝⎠⎡⍰⎀ ");

    return Note(
        uuid: const Uuid().v1().toString(),
        name: extractedData[0],
        content: extractedData[1].replaceAll("~", "~~"),
        renderMath: extractedData[2] == "true" ? true : false,
        lastModifiedDate: DateTime.now());
  }
}
