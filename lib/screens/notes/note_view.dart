import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/custom_embed_quill_blocks/quill_math_block.dart';
import 'package:mathx/logic/custom_hooks/note_hook.dart';
import 'package:mathx/logic/custom_hooks/quill_controller_hook.dart';

class NoteView extends HookConsumerWidget {
  const NoteView({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var note = useGetNote(ref, uuid, shouldWatch: true);
    var quillController = useQuillController(null);

    useEffect(() {
      if (note != null && note.content != "") {
        quillController.clear();
        quillController.compose(
            Delta.fromJson(jsonDecode(note.content)),
            const TextSelection(baseOffset: 0, extentOffset: 0),
            ChangeSource.local);
      }
      return null;
    }, [note]);

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push("/notes/edit/$uuid");
          },
          child: const Icon(Icons.edit),
        ),
        appBar: (note != null)
            ? AppBar(
                title: Text(note.name),
              )
            : null,
        body: (note != null)
            ? QuillProvider(
                configurations: QuillConfigurations(
                  controller: quillController,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('en'),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: QuillEditor.basic(
                    configurations: QuillEditorConfigurations(
                      expands: true,
                      readOnly: true,
                      showCursor: false,
                      embedBuilders: [
                        ...FlutterQuillEmbeds.editorBuilders(),
                        const QuillEditorFormulaEmbedBuilder()
                      ],
                    ),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
