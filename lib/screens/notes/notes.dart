import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/riverpods/notes_riverpod.dart';
import 'package:mathx/screens/notes/deeplinked_note_error_dialogs.dart';
import 'package:mathx/widgets/note_list_tile.dart';

class Notes extends HookConsumerWidget {
  Notes({super.key, this.failedToObtainNote = false});

  bool failedToObtainNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var searchTerm = useState("");
    var notes = ref.watch(notesRiverpodProvider);

    if (failedToObtainNote) {
      Future.delayed(
        Duration.zero,
        () async {
          await showCouldNotParseNoteFromDeeplink(context);
          failedToObtainNote = false;
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ref
                .read(notesRiverpodProvider.notifier)
                .createNewNoteAndGo(context);
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchBar(
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.search),
                    ),
                    onChanged: (newText) {
                      searchTerm.value = newText;
                    },
                    hintText: "Search for a note",
                  ),
                ],
              ),
            ),
            Expanded(
                child: switch (notes) {
              AsyncData(:final value) => ListView(
                  children: value.map((e) => NoteListTile(note: e)).toList(),
                ),
              AsyncError(:final error) => Text(error.toString()),
              _ => const Center(child: CircularProgressIndicator()),
            })
          ],
        ),
      ),
    );
  }
}
