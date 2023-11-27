import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:mathx/logic/riverpods/notes_riverpod.dart';

MathNote? useGetNote(WidgetRef ref, String uuid, {bool shouldWatch = false}) {
  return use(_ObtainNote(ref: ref, uuid: uuid, watch: shouldWatch));
}

class _ObtainNote extends Hook<MathNote?> {
  const _ObtainNote(
      {required this.ref, required this.uuid, required this.watch});

  final WidgetRef ref;
  final String uuid;
  final bool watch;

  @override
  _TimeAliveState createState() => _TimeAliveState();
}

class _TimeAliveState extends HookState<MathNote?, _ObtainNote> {
  MathNote? returnedNote;
  StreamSubscription? noteSub;

  @override
  void initHook() {
    super.initHook();
    (hook.ref.read(notesRiverpodProvider.notifier).obtainNoteByUUID(hook.uuid))
        .then((value) {
      returnedNote = value;
      setState(() {});
    });
    if (hook.watch) {
      noteSub = hook.ref
          .read(notesRiverpodProvider.notifier)
          .watchNoteEntryByUUID(hook.uuid)
          .watchSingle()
          .listen((event) {
        returnedNote = event;
        setState(() {});
      });
    }
  }

  @override
  MathNote? build(BuildContext context) => returnedNote;

  @override
  void dispose() {
    noteSub?.cancel();
    super.dispose();
  }
}
