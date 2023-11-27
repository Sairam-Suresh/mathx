import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:mathx/logic/riverpods/notes_riverpod.dart';

class NoteView extends HookConsumerWidget {
  const NoteView({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var note = useState<MathNote?>(null);

    useEffect(() {
      (ref.read(notesRiverpodProvider.notifier).obtainNoteByUUID(uuid))
          .then((value) {
        note.value = value;
      });

      return null;
    }, []);

    return Scaffold(
        appBar: (note.value != null)
            ? AppBar(
                title: Text(note.value!.name),
              )
            : null,
        body: (note.value != null)
            ? const Center(
                child: Text("Amongus"),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
