import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:mathx/logic/riverpods/notes_riverpod.dart';

MathNote? useGetNote(WidgetRef ref, String uuid) {
  return use(_ObtainNote(ref: ref, uuid: uuid));
}

class _ObtainNote extends Hook<MathNote?> {
  const _ObtainNote({required this.ref, required this.uuid});

  final WidgetRef ref;
  final String uuid;

  @override
  _TimeAliveState createState() => _TimeAliveState();
}

class _TimeAliveState extends HookState<MathNote?, _ObtainNote> {
  MathNote? returnedNote;

  @override
  void initHook() {
    super.initHook();
    (hook.ref.read(notesRiverpodProvider.notifier).obtainNoteByUUID(hook.uuid))
        .then((value) {
      returnedNote = value;
      setState(() {});
    });
  }

  @override
  MathNote? build(BuildContext context) => returnedNote;

  @override
  void dispose() {
    super.dispose();
  }
}
