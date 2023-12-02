import 'dart:convert';

import 'package:drift/drift.dart' hide JsonKey;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mathx/logic/note_converters/note_converters.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';

part 'math_notes.freezed.dart';

@UseRowClass(MathNote)
class MathNotes extends Table {
  IntColumn get id => integer().autoIncrement()();

  // We use a special UUID instead of the actual ID since it would make it more
  // complicated to attempt to use the ID with a Frozen class.
  TextColumn get uuid =>
      text().withDefault(Constant(const UuidV1().generate().toString()))();
  TextColumn get name => text()();
  TextColumn get content => text()();
  DateTimeColumn get lastModifiedDate =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get renderMath => boolean().withDefault(const Constant(true))();
}

// Custom row class for the Notes table

@freezed
class MathNote with _$MathNote {
  factory MathNote(
      {required String uuid,
      required String name,
      required String content,
      required DateTime lastModifiedDate,
      required bool renderMath}) = _MathNote;

  factory MathNote.fromDeepLink(Uri uri) {
    var encoded = uri.queryParameters["source"]!;

    var decodedData = utf8.decode(base64Decode(encoded));
    var extractedData = decodedData.split(" ␢␆␝⎠⎡⍰⎀ ");

    if (extractedData.length == 4) {
      return MathNote(
          uuid: const Uuid().v1().toString(),
          name: extractedData[0],
          content: jsonDecode(extractedData[3]),
          renderMath: extractedData[2] == "true" ? true : false,
          lastModifiedDate: DateTime.now());
    }

    return MathNote(
        uuid: const Uuid().v1().toString(),
        name: extractedData[0],
        content: mdToDel(extractedData[1]),
        renderMath: extractedData[2] == "true" ? true : false,
        lastModifiedDate: DateTime.now());
  }

  factory MathNote.fromDeepLinkNew(Uri uri) {
    var encoded = uri.queryParameters["source"]!;
    var decodedData =
        utf8.decode(base64Decode(Uri.decodeQueryComponent(encoded)));

    var extractedData = decodedData.split(" ␢␆␝⎠⎡⍰⎀ ");

    if (extractedData.length == 4) {
      return MathNote(
          uuid: const Uuid().v1().toString(),
          name: extractedData[0],
          content: jsonDecode(extractedData[3]),
          renderMath: extractedData[2] == "true" ? true : false,
          lastModifiedDate: DateTime.now());
    }

    return MathNote(
        uuid: const Uuid().v1().toString(),
        name: extractedData[0],
        content: mdToDel(extractedData[1]),
        renderMath: extractedData[2] == "true" ? true : false,
        lastModifiedDate: DateTime.now());
  }

  factory MathNote.fromDeepLinkAdaptive(Uri uri) {
    try {
      return MathNote.fromDeepLink(uri);
    } catch (e) {
      try {
        return MathNote.fromDeepLinkNew(uri);
      } catch (e) {
        throw Exception("FAILURE!!!");
      }
    }
  }
}

extension DeepLinkUtils on MathNote {
  String contentToMarkDown() => delToMd(content);

  String toDeepLink(DeepLinkType type) {
    // if (type == DeepLinkType.delta) return "mathx:///notes?source=${base64Encode(utf8.encode("$name ␢␆␝⎠⎡⍰⎀ ${jsonEncode(content)} ␢␆␝⎠⎡⍰⎀ $renderMath"))}";
    if (type == DeepLinkType.md) {
      return "mathx:///notes?source=${base64Encode(utf8.encode("$name ␢␆␝⎠⎡⍰⎀ ${contentToMarkDown()} ␢␆␝⎠⎡⍰⎀ $renderMath"))}";
    }

    return "mathx:///notes?source=${base64Encode(utf8.encode("$name ␢␆␝⎠⎡⍰⎀ ${contentToMarkDown()} ␢␆␝⎠⎡⍰⎀ $renderMath ␢␆␝⎠⎡⍰⎀ ${jsonEncode(content)}"))}";
  }

  String toDeepLinkNew(DeepLinkType type) {
    final linkString =
        "mathx:///notes?source=${Uri.encodeQueryComponent(base64Encode(utf8.encode("$name ␢␆␝⎠⎡⍰⎀ ${contentToMarkDown()} ␢␆␝⎠⎡⍰⎀ $renderMath ␢␆␝⎠⎡⍰⎀ ${jsonEncode(content)}")))}";

    // if (type == DeepLinkType.delta) return Uri.encodeFull("mathx:///notes?source=${"$name ␢␆␝⎠⎡⍰⎀ ${jsonEncode(content)} ␢␆␝⎠⎡⍰⎀ $renderMath"}");
    if (type == DeepLinkType.md) {
      return "mathx:///notes?source=${Uri.encodeQueryComponent(base64Encode(utf8.encode("$name ␢␆␝⎠⎡⍰⎀ ${contentToMarkDown()} ␢␆␝⎠⎡⍰⎀ $renderMath")))}";
    }

    return Uri.encodeFull(linkString);
  }
}

enum DeepLinkType {
  // delta,
  md,
  combined
}
