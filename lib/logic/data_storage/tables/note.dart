import 'package:drift/drift.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get content => text()();
  DateTimeColumn get lastModifiedDate => dateTime()();
  BoolColumn get renderMath => boolean()();
}

// Custom row class for the Notes table
class Note {
  final String id;
  final String name;
  final String content;
  final DateTime lastModifiedDate;
  final bool renderMath;

  Note(
      {required this.id,
      required this.name,
      required this.content,
      required this.lastModifiedDate,
      required this.renderMath});

  factory Note.fromDeepLink(Uri uri) {
    var decodedData = utf8.decode(base64Decode(uri.queryParameters["source"]!));
    var extractedData = decodedData.split(" ␢␆␝⎠⎡⍰⎀ ");

    return Note(
        name: extractedData[0],
        content: extractedData[1].replaceAll("~", "~~"),
        renderMath: extractedData[2] == "true" ? true : false,
        lastModifiedDate: DateTime.now(),
        id: const Uuid().v1());
  }
}
