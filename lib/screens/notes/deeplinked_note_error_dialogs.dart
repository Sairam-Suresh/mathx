import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';

Future showCouldNotParseNoteFromDeeplink(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.all(8),
      title: const Text("Error"),
      content: const Row(
        children: [
          Expanded(
              child: Text(
                  "We could not obtain your note from the deep link you provided")),
          Tooltip(
            message:
                "Due to link limitations, MathX might not have been able to obtain the full URL needed extract your Note.",
            triggerMode: TooltipTriggerMode.tap,
            child: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.question_mark),
              ),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        FilledButton(
            onPressed: () async {
              context.pop();
              await showManuallyEnterDeeplink(context);
            },
            child: const Text("Enter URL Manually")),
        FilledButton(
            onPressed: () {
              context.pop();
            },
            child: const Text("Okay")),
      ],
    ),
  );
}

Future showManuallyEnterDeeplink(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        var text = "";
        var errorWithDeeplink = true;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Please enter your URL"),
            content: TextField(
                onChanged: (newText) => setState(() {
                      text = newText;
                      try {
                        MathNote.fromDeepLinkAdaptive(Uri.parse(text));
                        errorWithDeeplink = false;
                      } catch (e) {
                        errorWithDeeplink = true;
                      }
                    }),
                decoration: InputDecoration(
                    errorText: (errorWithDeeplink && text != "")
                        ? "Invalid Link"
                        : null)),
            actions: [
              FilledButton(
                  onPressed: (text != "" && !errorWithDeeplink)
                      ? () {
                          context.push(text);
                        }
                      : null,
                  child: const Text("Okay")),
            ],
          );
        });
      });
}
