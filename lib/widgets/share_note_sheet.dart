import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mathx/logic/data_storage/tables/math_notes.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareNote(BuildContext context, MathNote note) {
  var noteDeepLink = note.toDeepLink();
  var noteDeltaDeepLink = note.toDeltaDeepLink();

  print(note.toMDDeepLink());
  print(note.content);

  var exceedingQRLimits =
      !(noteDeepLink.length < 2592 && noteDeltaDeepLink.length < 2592);

  return showModalBottomSheet(
    showDragHandle: false,
    enableDrag: false,
    context: context,
    builder: (context) => BottomSheet(
      enableDrag: false,
      showDragHandle: false,
      onClosing: () {},
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(50.0)),
              child: ListTile(
                leading: !exceedingQRLimits
                    ? const Icon(Icons.qr_code_2)
                    : const Icon(Icons.close),
                title: const Text("Share via QR"),
                trailing: !exceedingQRLimits
                    ? null
                    : const Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message:
                            "Your note is too large to fit into a QR Code.",
                        child: Icon(Icons.question_mark),
                      ),
                onTap: !exceedingQRLimits
                    ? () {
                        context.pop();
                        showDialog(
                            context: context,
                            builder: (context) {
                              var useCompatMode = false;

                              return Dialog(
                                  child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: StatefulBuilder(
                                    builder: (context, setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "QR Code Sharing",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: QrImageView(
                                              backgroundColor: Colors.white,
                                              data: useCompatMode
                                                  ? note.toMDDeepLink()
                                                  : noteDeepLink,
                                              version: QrVersions.auto,
                                            ),
                                          ),
                                        ),
                                      ),
                                      CheckboxListTile(
                                          value: useCompatMode,
                                          onChanged: (newVal) {
                                            setState(() {
                                              useCompatMode = newVal!;
                                            });
                                          },
                                          title:
                                              const Text("Compatibility Mode"),
                                          subtitle: const Text(
                                              "Use this when sharing to iOS or older android versions of this app.")),
                                      FilledButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text("Done"),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Icon(Icons.check),
                                              ]))
                                    ],
                                  );
                                }),
                              ));
                            });
                      }
                    : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share via URL"),
              onTap: () {
                context.pop();
                Share.share(note.toDeepLink());
              },
            )
          ],
        );
      },
    ),
  );
}
