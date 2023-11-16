import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Notes extends HookConsumerWidget {
  const Notes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchBar(
                    leading: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.search),
                    ),
                    hintText: "Search for a note",
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [],
              ),
            )
          ],
        ),
      ),
    );
  }
}
