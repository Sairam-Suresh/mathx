import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/riverpods/cheatsheets_riverpod.dart';
import 'package:mathx/widgets/cheatsheet_list_tile.dart';

class LikedCheatsheetsViewer extends HookConsumerWidget {
  const LikedCheatsheetsViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cheatsheets = ref.watch(
        cheatsheetsRiverpodProvider); // So that widget can update on change

    var likedCheatsheets = useCallback(
        () => ref
            .read(cheatsheetsRiverpodProvider.notifier)
            .obtainAllLikedCheatsheets(),
        []);

    return FutureBuilder(
        future: likedCheatsheets(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Your Liked Cheatsheets"),
            ),
            body: (snapshot.hasData)
                ? ListView(
                    children: snapshot.data!
                        .map((e) => CheatsheetListTile(sheet: e))
                        .toList(),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        });
  }
}
