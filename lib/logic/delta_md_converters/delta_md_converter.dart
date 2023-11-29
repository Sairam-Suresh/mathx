import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:delta_markdown_converter/src/ast.dart' as ast;
import 'package:delta_markdown_converter/src/document.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show
        Attribute,
        AttributeScope,
        BlockEmbed,
        Delta,
        DeltaIterator,
        LinkAttribute,
        Style;

class CustomDeltaMarkdownEncoder extends Converter<String, String> {
  static const _lineFeedAsciiCode = 0x0A;

  late StringBuffer markdownBuffer;
  late StringBuffer lineBuffer;

  Attribute? currentBlockStyle;
  late Style currentInlineStyle;

  late List<String> currentBlockLines;

  /// Converts the [input] delta to Markdown.
  @override
  String convert(String input) {
    markdownBuffer = StringBuffer();
    lineBuffer = StringBuffer();
    currentInlineStyle = const Style();
    currentBlockLines = <String>[];

    final inputJson = jsonDecode(input) as List<dynamic>?;
    if (inputJson is! List<dynamic>) {
      throw ArgumentError('Unexpected formatting of the input delta string.');
    }
    final delta = Delta.fromJson(inputJson);
    final iterator = DeltaIterator(delta);

    while (iterator.hasNext) {
      final operation = iterator.next();

      if (operation.data is String) {
        final operationData = operation.data as String;

        if (!operationData.contains('\n')) {
          _handleInline(lineBuffer, operationData, operation.attributes);
        } else {
          _handleLine(operationData, operation.attributes);
        }
      } else if (operation.data is Map<String, dynamic>) {
        _handleEmbed(operation.data as Map<String, dynamic>);
      } else {
        throw ArgumentError('Unexpected formatting of the input delta string.');
      }
    }

    _handleBlock(currentBlockStyle); // Close the last block

    return markdownBuffer.toString();
  }

  void _handleInline(
    StringBuffer buffer,
    String text,
    Map<String, dynamic>? attributes,
  ) {
    final style = Style.fromJson(attributes);

    // First close any current styles if needed
    final markedForRemoval = <Attribute>[];
    // Close the styles in reverse order, e.g. **_ for _**Test**_.
    for (final value
        in currentInlineStyle.attributes.values.toList().reversed) {
      if (value.scope == AttributeScope.block) {
        continue;
      }
      if (style.containsKey(value.key)) {
        continue;
      }

      final padding = _trimRight(buffer);
      _writeAttribute(buffer, value, close: true);
      if (padding.isNotEmpty) {
        buffer.write(padding);
      }
      markedForRemoval.add(value);
    }

    // Make sure to remove all attributes that are marked for removal.
    for (final value in markedForRemoval) {
      currentInlineStyle.attributes.removeWhere((_, v) => v == value);
    }

    // Now open any new styles.
    for (final attribute in style.attributes.values) {
      // TODO(tillf): Is block correct?
      if (attribute.scope == AttributeScope.block) {
        continue;
      }
      if (currentInlineStyle.containsKey(attribute.key)) {
        continue;
      }
      final originalText = text;
      text = text.trimLeft();
      final padding = ' ' * (originalText.length - text.length);
      if (padding.isNotEmpty) {
        buffer.write(padding);
      }
      _writeAttribute(buffer, attribute);
    }

    // Write the text itself
    buffer.write(text);
    currentInlineStyle = style;
  }

  void _handleLine(String data, Map<String, dynamic>? attributes) {
    final span = StringBuffer();

    for (var i = 0; i < data.length; i++) {
      if (data.codeUnitAt(i) == _lineFeedAsciiCode) {
        if (span.isNotEmpty) {
          // Write the span if it's not empty.
          _handleInline(lineBuffer, span.toString(), attributes);
        }
        // Close any open inline styles.
        _handleInline(lineBuffer, '', null);

        final lineBlock = Style.fromJson(attributes)
            .attributes
            .values
            .singleWhereOrNull((a) => a.scope == AttributeScope.block);

        if (lineBlock == currentBlockStyle) {
          currentBlockLines.add(lineBuffer.toString());
        } else {
          _handleBlock(currentBlockStyle);
          currentBlockLines
            ..clear()
            ..add(lineBuffer.toString());

          currentBlockStyle = lineBlock;
        }
        lineBuffer.clear();

        span.clear();
      } else {
        span.writeCharCode(data.codeUnitAt(i));
      }
    }

    // Remaining span
    if (span.isNotEmpty) {
      _handleInline(lineBuffer, span.toString(), attributes);
    }
  }

  void _handleEmbed(Map<String, dynamic> data) {
    // TODO: HANDLE LaTeX HERE!!!

    final embed = BlockEmbed(data.keys.first, data.values.first as String);

    if (embed.type == 'image') {
      _writeEmbedTag(lineBuffer, embed);
      _writeEmbedTag(lineBuffer, embed, close: true);
    } else if (embed.type == 'divider') {
      _writeEmbedTag(lineBuffer, embed);
      _writeEmbedTag(lineBuffer, embed, close: true);
    } else if (embed.type == 'formula') {
      _writeEmbedTag(lineBuffer, embed);
      _writeEmbedTag(lineBuffer, embed, close: true);
    }
  }

  void _handleBlock(Attribute? blockStyle) {
    if (currentBlockLines.isEmpty) {
      return; // Empty block
    }

    // If there was a block before this one, add empty line between the blocks
    if (markdownBuffer.isNotEmpty) {
      markdownBuffer.writeln();
    }

    if (blockStyle == null) {
      markdownBuffer
        ..write(currentBlockLines.join('\n'))
        ..writeln();
    } else if (blockStyle == Attribute.codeBlock) {
      _writeAttribute(markdownBuffer, blockStyle);
      markdownBuffer.write(currentBlockLines.join('\n'));
      _writeAttribute(markdownBuffer, blockStyle, close: true);
      markdownBuffer.writeln();
    } else {
      // Dealing with lists or a quote.
      for (final line in currentBlockLines) {
        _writeBlockTag(markdownBuffer, blockStyle);
        markdownBuffer
          ..write(line)
          ..writeln();
      }
    }
  }

  String _trimRight(StringBuffer buffer) {
    final text = buffer.toString();
    if (!text.endsWith(' ')) {
      return '';
    }

    final result = text.trimRight();
    buffer
      ..clear()
      ..write(result);
    return ' ' * (text.length - result.length);
  }

  void _writeAttribute(
    StringBuffer buffer,
    Attribute attribute, {
    bool close = false,
  }) {
    if (attribute.key == Attribute.bold.key) {
      buffer.write('**');
    } else if (attribute.key == Attribute.italic.key) {
      buffer.write('_');
    } else if (attribute.key == Attribute.link.key) {
      buffer.write(!close ? '[' : '](${attribute.value})');
    } else if (attribute == Attribute.codeBlock) {
      buffer.write(!close ? '```\n' : '\n```');
    } else if (attribute == Attribute.inlineCode) {
      buffer.write(!close ? '`\n' : '\n`');
    } else {
      // TODO: Try to warn the user about certain data losses which might happen during conversion
      // throw ArgumentError('Cannot handle $attribute');
    }
  }

  void _writeBlockTag(
    StringBuffer buffer,
    Attribute block, {
    bool close = false,
  }) {
    if (close) {
      return; // no close tag needed for simple blocks.
    }

    if (block == Attribute.blockQuote) {
      buffer.write('> ');
    } else if (block == Attribute.ul) {
      buffer.write('* ');
    } else if (block == Attribute.ol) {
      buffer.write('1. ');
    } else if (block.key == Attribute.h1.key && block.value == 1) {
      buffer.write('# ');
    } else if (block.key == Attribute.h2.key && block.value == 2) {
      buffer.write('## ');
    } else if (block.key == Attribute.h3.key && block.value == 3) {
      buffer.write('### ');
    } else if (block.key == Attribute.list.key && block.value == "checked") {
      buffer.write('- [x] ');
    } else if (block.key == Attribute.list.key && block.value == "unchecked") {
      buffer.write('- '); // For some reason there is already a "[]" there
    } else {
      throw ArgumentError('Cannot handle block $block');
    }
  }

  void _writeEmbedTag(
    StringBuffer buffer,
    BlockEmbed embed, {
    bool close = false,
  }) {
    const kImageType = 'image';
    const kDividerType = 'divider';
    const kFormulaType = 'formula';

    if (embed.type == kImageType) {
      if (close) {
        buffer.write('](${embed.data})');
      } else {
        buffer.write('![');
      }
    } else if (embed.type == kDividerType && close) {
      buffer.write('\n---\n\n');
    } else if (embed.type == kFormulaType) {
      if (close) {
        buffer.write("${embed.data}\$");
      } else {
        buffer.write("\$");
      }
    }
  }
}

class CustomDeltaMarkdownDecoder extends Converter<String, String> {
  @override
  String convert(String input) {
    final lines = input.replaceAll('\r\n', '\n').split('\n');

    final markdownDocument = Document().parseLines(lines);

    return jsonEncode(_DeltaVisitor().convert(markdownDocument).toJson());
  }
}

class _DeltaVisitor implements ast.NodeVisitor {
  static final _blockTags =
      RegExp('h1|h2|h3|h4|h5|h6|hr|pre|ul|ol|blockquote|p|pre|formula');

  static final _embedTags = RegExp('hr|img|formula');

  late Delta delta;

  late Queue<Attribute> activeInlineAttributes;
  Attribute? activeBlockAttribute;
  late Set<String> uniqueIds;

  ast.Element? previousElement;
  late ast.Element previousToplevelElement;

  Delta convert(List<ast.Node> nodes) {
    delta = Delta();
    activeInlineAttributes = Queue<Attribute>();
    uniqueIds = <String>{};

    for (final node in nodes) {
      node.accept(this);
    }

    // Ensure the delta ends with a newline.
    if (delta.length > 0 && delta.last.value != '\n') {
      delta.insert('\n', activeBlockAttribute?.toJson());
    }

    return delta;
  }

  @override
  void visitText(ast.Text text) {
    final str = text.text;

    final attributes = <String, dynamic>{};
    for (final attr in activeInlineAttributes) {
      attributes.addAll(attr.toJson());
    }

    var newlineIndex = str.indexOf('\n');
    var startIndex = 0;
    while (newlineIndex != -1) {
      final previousText = str.substring(startIndex, newlineIndex);
      if (previousText.isNotEmpty) {
        delta.insert(previousText, attributes.isNotEmpty ? attributes : null);
      }
      delta.insert('\n', activeBlockAttribute?.toJson());

      startIndex = newlineIndex + 1;
      newlineIndex = str.indexOf('\n', newlineIndex + 1);
    }

    if (startIndex < str.length) {
      final lastStr = str.substring(startIndex);
      delta.insert(lastStr, attributes.isNotEmpty ? attributes : null);
    }
  }

  @override
  bool visitElementBefore(ast.Element element) {
    final attr = _tagToAttribute(element);

    if (delta.isNotEmpty && _blockTags.firstMatch(element.tag) != null) {
      if (element.isToplevel) {
        if (previousToplevelElement.tag != 'ul' &&
            previousToplevelElement.tag != 'ol' &&
            previousToplevelElement.tag != 'pre' &&
            previousToplevelElement.tag != 'hr') {
          delta.insert('\n', activeBlockAttribute?.toJson());
        }
      } else if (element.tag == 'p' &&
          previousElement != null &&
          !previousElement!.isToplevel &&
          !previousElement!.children!.contains(element)) {
        delta
          ..insert('\n', activeBlockAttribute?.toJson())
          ..insert('\n', activeBlockAttribute?.toJson());
      }
    }

    if (element.isToplevel && element.tag != 'hr') {
      activeBlockAttribute = attr;
    }

    if (_embedTags.firstMatch(element.tag) != null) {
      if (element.tag == 'formula') {
        delta.insert({"formula": ""});
      } else {
        delta.insert(attr!.toJson());
      }
    } else if (_blockTags.firstMatch(element.tag) == null && attr != null) {
      activeInlineAttributes.addLast(attr);
    }

    previousElement = element;
    if (element.isToplevel) {
      previousToplevelElement = element;
    }

    if (element.isEmpty) {
      if (element.tag == 'br') {
        delta.insert('\n');
      }

      return false;
    } else {
      return true;
    }
  }

  @override
  void visitElementAfter(ast.Element element) {
    if (element.tag == 'li' &&
        (previousToplevelElement.tag == 'ol' ||
            previousToplevelElement.tag == 'ul')) {
      delta.insert('\n', activeBlockAttribute?.toJson());
    }

    final attr = _tagToAttribute(element);
    if (attr == null || !attr.isInline || activeInlineAttributes.last != attr) {
      return;
    }
    activeInlineAttributes.removeLast();

    previousElement = element;
  }

  String uniquifyId(String id) {
    if (!uniqueIds.contains(id)) {
      uniqueIds.add(id);
      return id;
    }

    var suffix = 2;
    var suffixedId = '$id-$suffix';
    while (uniqueIds.contains(suffixedId)) {
      suffixedId = '$id-${suffix++}';
    }
    uniqueIds.add(suffixedId);
    return suffixedId;
  }

  Attribute? _tagToAttribute(ast.Element el) {
    if (el.tag == 'formula') {
      return Attribute.fromKeyValue("formula", "");
    }

    switch (el.tag) {
      case 'em':
        return Attribute.italic;
      case 'strong':
        return Attribute.bold;
      case 'ul':
        return Attribute.ul;
      case 'ol':
        return Attribute.ol;
      case 'pre':
        return Attribute.codeBlock;
      case 'blockquote':
        return Attribute.blockQuote;
      case 'h1':
        return Attribute.h1;
      case 'h2':
        return Attribute.h2;
      case 'h3':
        return Attribute.h3;
      case 'a':
        final href = el.attributes['href'];
        return LinkAttribute(href);
      case 'img':
        final href = el.attributes['src'];
        return ImageAttribute(href);
      case 'hr':
        return const DividerAttribute();
    }

    return null;
  }
}

class ImageAttribute extends Attribute<String?> {
  const ImageAttribute(String? val)
      : super('image', AttributeScope.embeds, val);
}

class DividerAttribute extends Attribute<String?> {
  const DividerAttribute() : super('divider', AttributeScope.embeds, 'hr');
}
