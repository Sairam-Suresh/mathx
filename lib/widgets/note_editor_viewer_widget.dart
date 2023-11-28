import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart'
    hide QuillToolbarFormulaButton;
import 'package:mathx/logic/custom_embed_quill_blocks/quill_math_block.dart';

class NoteViewOrEditorWidget extends StatelessWidget {
  const NoteViewOrEditorWidget(
      {super.key, required this.quillController, this.readOnly = false});

  final QuillController quillController;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return QuillProvider(
      configurations: QuillConfigurations(
        controller: quillController,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('en'),
        ),
      ),
      child: Column(
        children: [
          if (!readOnly)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: QuillToolbar(
                configurations: QuillToolbarConfigurations(
                  embedButtons: [
                    ...FlutterQuillEmbeds.toolbarButtons(),
                    (controller, toolbarIconSize, iconTheme, dialogTheme) =>
                        QuillToolbarFormulaButton(
                            controller: quillController,
                            options: const QuillToolbarFormulaButtonOptions())
                  ],
                ),
              ),
            ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                readOnly: readOnly,
                showCursor: !readOnly,
                embedBuilders: [
                  ...FlutterQuillEmbeds.editorBuilders(),
                  const QuillEditorFormulaEmbedBuilder(),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
