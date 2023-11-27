import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/custom_hooks/note_hook.dart';

class NoteView extends HookConsumerWidget {
  const NoteView({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var note = useGetNote(ref, uuid);

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
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SingleChildScrollView(child: Text(note.content)),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
