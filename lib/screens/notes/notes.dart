import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
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

    var searchController = useTextEditingController();

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
                    controller: searchController,
                    trailing: (searchTerm.value.isNotEmpty)
                        ? [
                            IconButton(
                                onPressed: () {
                                  searchController.clear();
                                  searchTerm.value = "";
                                },
                                icon: const Icon(Icons.clear))
                          ]
                        : null,
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
              AsyncData(:final value) =>
                buildNoteListView(value, searchTerm, context),
              AsyncError(:final error) => Text(error.toString()),
              _ => const Center(child: CircularProgressIndicator()),
            })
          ],
        ),
      ),
    );
  }

  Widget buildNoteListView(List<MathNote> mathNotes,
      ValueNotifier<String> searchTerm, BuildContext context) {
    final mathNotesCopy = mathNotes.map((e) => e).toList();

    if (searchTerm.value.isNotEmpty) {
      mathNotesCopy.removeWhere((element) => !(element.name
          .toLowerCase()
          .contains(searchTerm.value.toLowerCase())));
    }
    if (mathNotesCopy.isEmpty) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                "We could not find any notes with your search term",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const Text(
                "Try using another search term",
                textAlign: TextAlign.center,
              ),
              const Spacer()
            ],
          ),
        ),
      );
    }

    return ListView(
      children: mathNotesCopy
          .map((e) =>
              (e.name.toLowerCase().contains(searchTerm.value.toLowerCase()))
                  ? NoteListTile(note: e)
                  : Container())
          .toList(),
    );
  }
}
