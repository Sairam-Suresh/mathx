import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:mathx/logic/riverpods/notes_riverpod.dart';
import 'package:mathx/widgets/share_note_sheet.dart';

class NoteListTile extends ConsumerWidget {
  const NoteListTile({super.key, required this.note});

  final MathNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: const Text("Warning"),
                    content: Text(
                        "Are you sure you want to delete the note \"${note.name}\"?"),
                    actions: [
                      FilledButton(
                          onPressed: () {
                            ref
                                .read(notesRiverpodProvider.notifier)
                                .deleteNoteFromDb(note);
                            context.pop();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white)),
                          child: const Text("Yes")),
                      FilledButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            context.pop();
                          })
                    ]),
              );
            },
            autoClose: true,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
          SlidableAction(
            onPressed: (context) async {
              await shareNote(context, note);
            },
            autoClose: true,
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            icon: Icons.share,
            label: 'Share',
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          note.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(note.lastModifiedDate.toLocal().toString()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          context.go("/notes/view/${note.uuid}");
        },
      ),
    );
  }
}
