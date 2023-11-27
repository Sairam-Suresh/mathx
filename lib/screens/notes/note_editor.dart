import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoteEditor extends StatelessWidget {
  const NoteEditor({
    super.key,
    required this.uuid,
  });

  final String uuid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(Icons.check))
          ],
        ),
        body: Text(uuid));
  }
}
