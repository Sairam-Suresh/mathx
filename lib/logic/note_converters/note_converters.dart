import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_quill/markdown_quill.dart';

String delToMd(String url) {
  final deltaToMd = DeltaToMarkdown(
    customEmbedHandlers: {
      EmbeddableTable.tableType: EmbeddableTable.toMdSyntax,
      "formula": (embed, out) => out.write("\$${embed.value.data}\$"),
    },
  );

  final mdDocument = deltaToMd.convert(Delta.fromJson(jsonDecode(url)));
  // final delta = jsonEncode(mdDocument);

  return mdDocument;
}

String mdToDel(String url) {
  final mdDocument = md.Document(
    encodeHtml: false,
    extensionSet: md.ExtensionSet.gitHubFlavored,

    // you can add custom syntax.
    blockSyntaxes: [const EmbeddableTableSyntax()],
  );

  final mdToDelta = MarkdownToDelta(
    markdownDocument: mdDocument,

    // you can add custom attributes based on tags
    customElementToBlockAttribute: {
      'h4': (element) => [const HeaderAttribute(level: 4)],
    },
    // custom embed
    customElementToEmbeddable: {
      EmbeddableTable.tableType: EmbeddableTable.fromMdSyntax,
      'formula': (elAttrs) {
        return Embeddable("formula", elAttrs['data']);
      },
    },
  );

  return jsonEncode((mdToDelta.convert(url)).toJson());
}
