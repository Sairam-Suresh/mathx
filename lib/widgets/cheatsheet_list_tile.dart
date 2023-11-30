import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mathx/logic/data_storage/tables/cheatsheets.dart';

Widget cheatsheetIcon(int level) {
  if (level == 1) {
    return const Icon(
      Icons.looks_one_outlined,
    );
  } else if (level == 2) {
    return const Icon(
      Icons.looks_two_outlined,
    );
  } else if (level == 3) {
    return const Icon(
      Icons.looks_3_outlined,
    );
  } else if (level == 4) {
    return const Icon(
      Icons.looks_4_outlined,
    );
  } else {
    throw ArgumentError("You can't have $level as a secondary school level!");
  }
}

class CheatsheetListTile extends StatelessWidget {
  const CheatsheetListTile({super.key, required this.sheet});

  final Cheatsheet sheet;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: cheatsheetIcon(sheet.secondaryLevel),
      title: Text(sheet.name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.go("/cheatsheets/view/${sheet.name.replaceAll(" ", "_")}");
      },
    );
  }
}
