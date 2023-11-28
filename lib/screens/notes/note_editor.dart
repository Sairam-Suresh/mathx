import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart'
    hide QuillToolbarFormulaButton;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/custom_embed_quill_blocks/quill_math_block.dart';
import 'package:mathx/logic/custom_hooks/note_hook.dart';
import 'package:mathx/logic/custom_hooks/quill_controller_hook.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:mathx/logic/riverpods/notes_riverpod.dart';

class NoteEditor extends HookConsumerWidget {
  const NoteEditor({
    super.key,
    required this.uuid,
  });

  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var note = useGetNote(ref, uuid);
    var titleController = useTextEditingController();
    var titleFocusNode = useFocusNode();

    var newTitle = useState("");
    var newContent = useState("");
    var newRenderMath = useState(false);

    var newNote = useState<MathNote?>(null);

    useEffect(() {
      // Initialise variables with data from the database
      if (note != null) {
        titleController.text = note.name;
        newTitle.value = note.name;
        newContent.value = note.content;
        newRenderMath.value = note.renderMath;
      }
      return null;
    }, [note]);

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

    useEffect(() {
      quillController.changes.listen((event) {
        newContent.value =
            jsonEncode(quillController.document.toDelta().toJson());
      });

      return null;
    }, []);

    useEffect(() {
      newNote.value = MathNote(
          uuid: uuid,
          name: newTitle.value,
          content: newContent.value,
          lastModifiedDate: DateTime.now(),
          renderMath: newRenderMath.value);

      return null;
    }, [newTitle.value, newContent.value, newRenderMath.value]);

    return (note != null)
        ? QuillProvider(
            configurations: QuillConfigurations(
              controller: quillController,
              sharedConfigurations: const QuillSharedConfigurations(
                locale: Locale('en'),
              ),
            ),
            child: Scaffold(
                appBar: AppBar(
                  title: IntrinsicWidth(
                    child: EditableText(
                      backgroundCursorColor: Theme.of(context).primaryColor,
                      onChanged: (newText) {
                        newTitle.value = newText;
                      },
                      controller: titleController,
                      focusNode: titleFocusNode,
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleLarge?.fontSize),
                      cursorColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                    ),
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {
                          if (newNote.value != null) {
                            ref
                                .read(notesRiverpodProvider.notifier)
                                .updateNoteEntryInDb(newNote.value!);
                          }
                          context.pop();
                        },
                        icon: const Icon(Icons.check))
                  ],
                ),
                body: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: QuillToolbar(
                        configurations: QuillToolbarConfigurations(
                          embedButtons: [
                            ...FlutterQuillEmbeds.toolbarButtons(),
                            (controller, toolbarIconSize, iconTheme,
                                    dialogTheme) =>
                                QuillToolbarFormulaButton(
                                    controller: quillController,
                                    options:
                                        const QuillToolbarFormulaButtonOptions())
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: QuillEditor.basic(
                        configurations: QuillEditorConfigurations(
                          embedBuilders: [
                            ...FlutterQuillEmbeds.editorBuilders(),
                            const QuillEditorFormulaEmbedBuilder(),
                          ],
                        ),
                      ),
                    ))
                  ],
                )),
          )
        : const Scaffold(
            body: Center(
            child: CircularProgressIndicator(),
          ));
  }
}
