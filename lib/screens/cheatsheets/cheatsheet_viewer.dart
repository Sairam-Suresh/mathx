import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/riverpods/cheatsheets_riverpod.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class CheatSheetViewer extends HookConsumerWidget {
  const CheatSheetViewer({super.key, required this.noteName});

  final String noteName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var allCheatsheets = ref.watch(
        cheatsheetsRiverpodProvider); // So that this view updates as well

    var cheatsheet = useCallback(
        () => ref
            .read(cheatsheetsRiverpodProvider.notifier)
            .obtainCheatsheetByName(noteName.replaceAll("_", " ")),
        [allCheatsheets]);

    return FutureBuilder(
        future: cheatsheet(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: (snapshot.hasData)
                ? AppBar(
                    title: Text(snapshot.data!.$1.name),
                    actions: [
                      IconButton(
                          onPressed: () {
                            ref
                                .read(cheatsheetsRiverpodProvider.notifier)
                                .changeCheatsheetLikeStatus(
                                    snapshot.data!.$1.name);
                          },
                          icon: snapshot.data!.$1.starred
                              ? const Icon(Icons.star)
                              : const Icon(Icons.star_border))
                    ],
                  )
                : null,
            body: (snapshot.hasData) ? PdfView(path: snapshot.data!.$2) : null,
          );
        });
  }
}
