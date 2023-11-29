import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/custom_hooks/quill_controller_hook.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:mathx/logic/riverpods/notes_riverpod.dart';
import 'package:mathx/widgets/note_editor_viewer_widget.dart';

class NotePreview extends HookConsumerWidget {
  const NotePreview({
    super.key,
    required this.noteData,
  });

  final Uri noteData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var note = useCallback(() => MathNote.fromDeepLink(noteData), []);
    var quillController =
        useQuillController(Document.fromJson(jsonDecode(note().content)));

    var titleController = useTextEditingController(text: note().name);

    return Scaffold(
        appBar: AppBar(title: const Text("Note Preview")),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ListTile(
              title: const Text("Name: "),
              trailing: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: TextField(
                  textAlign: TextAlign.right,
                  controller: titleController,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: NoteViewOrEditorWidget(
                  quillController: quillController,
                  readOnly: true,
                ),
              ),
            ),
            FilledButton(
                onPressed: () {
                  ref.read(notesRiverpodProvider.notifier).saveNoteToDb(
                      MathNote(
                          uuid: note().uuid,
                          name: titleController.text,
                          content: note().content,
                          lastModifiedDate: DateTime.now(),
                          renderMath: note().renderMath));
                  context.pop();
                },
                child: const Row(
                  children: [
                    Spacer(),
                    Text("Save, With changes"),
                    Spacer(),
                  ],
                )),
            FilledButton(
              onPressed: () async {
                if (await getConfirmation(context, "Save",
                    "Are you sure you want to save without your modifications?")) {
                  ref.read(notesRiverpodProvider.notifier).saveNoteToDb(note());
                  context.pop();
                }
              },
              child: const Row(
                children: [
                  Spacer(),
                  Text("Save, Without changes"),
                  Spacer(),
                ],
              ),
            ),
            FilledButton(
              onPressed: () async {
                if (await getConfirmation(
                    context, "Delete Note", "Are you sure?")) {
                  context.pop();
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Row(
                children: [
                  Spacer(),
                  Text("Delete"),
                  Spacer(),
                ],
              ),
            )
          ],
        ));
  }
}

Future<bool> getConfirmation(
    BuildContext context, String title, String description) async {
  var confirmationStatus = false;

  await showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: [
              FilledButton(
                onPressed: () {
                  context.pop();
                },
                child: const Row(
                  children: [
                    Spacer(),
                    Text("No"),
                    Spacer(),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () {
                  confirmationStatus = true;
                  context.pop();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Row(
                  children: [
                    Spacer(),
                    Text("Yes"),
                    Spacer(),
                  ],
                ),
              )
            ],
          ));

  return confirmationStatus;
}
