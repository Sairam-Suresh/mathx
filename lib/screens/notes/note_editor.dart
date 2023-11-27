import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/custom_hooks/note_hook.dart';
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
            ),
            body: Text(uuid))
        : const Scaffold(
            body: Center(
            child: CircularProgressIndicator(),
          ));
  }
}
