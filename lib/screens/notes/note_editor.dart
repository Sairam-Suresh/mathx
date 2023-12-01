import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/custom_hooks/note_hook.dart';
import 'package:mathx/logic/custom_hooks/quill_controller_hook.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:mathx/logic/riverpods/notes_riverpod.dart';
import 'package:mathx/widgets/note_editor_viewer_widget.dart';

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

    var initialisedNewNote = useState(false);

    var newNote = useState<MathNote?>(null);

    useEffect(() {
      // Initialise variables with data from the database
      if (note != null) {
        titleController.text = note.name;
        newTitle.value = note.name;
        newContent.value = note.content;
        newRenderMath.value = note.renderMath;

        newNote.value =
            newNote.value?.copyWith(lastModifiedDate: note.lastModifiedDate) ??
                note;
        Future.delayed(Duration(milliseconds: 500), () {
          initialisedNewNote.value = true;
        });
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
        if (event.source == ChangeSource.local) {
          newContent.value =
              jsonEncode(quillController.document.toDelta().toJson());
        }
      });

      return null;
    }, []);

    useEffect(() {
      if (initialisedNewNote.value) {
        newNote.value = MathNote(
            uuid: uuid,
            name: newTitle.value,
            content: newContent.value,
            lastModifiedDate: DateTime.now(),
            renderMath: newRenderMath.value);
      }

      return null;
    }, [newTitle.value, newContent.value, newRenderMath.value]);

    return (note != null)
        ? Scaffold(
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
                  cursorColor: Theme.of(context).brightness == Brightness.dark
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
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () {
                  if (newNote.value?.lastModifiedDate
                              .compareTo(note.lastModifiedDate) !=
                          0 &&
                      newNote.value != null) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Warning"),
                              content: const Text(
                                  "Would you like to save your changes?"),
                              actions: [
                                FilledButton(
                                  onPressed: () {
                                    context.pop();
                                    context.go(
                                        "/notes/view/${newNote.value!.uuid}");
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.white),
                                  ),
                                  child: const Text("No"),
                                ),
                                FilledButton(
                                    onPressed: () {
                                      ref
                                          .read(notesRiverpodProvider.notifier)
                                          .updateNoteEntryInDb(newNote.value!);
                                      context.pop();
                                      context.go(
                                          "/notes/view/${newNote.value!.uuid}");
                                    },
                                    child: const Text("Yes")),
                              ],
                            ));
                  } else {
                    context.go("/notes/view/${note.uuid}");
                  }
                },
                icon: Icon(Platform.isIOS
                    ? Icons.arrow_back_ios_new
                    : Icons.arrow_back),
              ),
            ),
            body: NoteViewOrEditorWidget(quillController: quillController))
        : const Scaffold(
            body: Center(
            child: CircularProgressIndicator(),
          ));
  }
}
