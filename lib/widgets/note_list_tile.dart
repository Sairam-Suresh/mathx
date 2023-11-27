import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';

class NoteListTile extends ConsumerWidget {
  const NoteListTile({super.key, required this.note});

  final MathNote note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        note.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(note.lastModifiedDate.toLocal().toString()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.go("/notes/view/${note.uuid}");
      },
    );
  }
}
