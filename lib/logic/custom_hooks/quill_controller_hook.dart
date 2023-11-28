import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';

QuillController useQuillController(Document? document) {
  return use(_QuillControl(document: document));
}

class _QuillControl extends Hook<QuillController> {
  const _QuillControl({this.document});

  final Document? document;

  @override
  _TimeAliveState createState() => _TimeAliveState();
}

class _TimeAliveState extends HookState<QuillController, _QuillControl> {
  QuillController? controller;

  @override
  void initHook() {
    controller = (hook.document != null)
        ? QuillController(
            document: hook.document!,
            selection: const TextSelection(baseOffset: 0, extentOffset: 0))
        : QuillController.basic();
    super.initHook();
  }

  @override
  QuillController build(BuildContext context) => controller!;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
