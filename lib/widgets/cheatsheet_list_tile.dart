import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/data_storage/tables/cheatsheets.dart';
import 'package:mathx/logic/riverpods/cheatsheets_riverpod.dart';

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

class CheatsheetListTile extends HookConsumerWidget {
  const CheatsheetListTile({super.key, required this.sheet});

  final Cheatsheet sheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isLiked = useState(sheet.starred); // Require this for updating

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            autoClose: true,
            onPressed: (context) async {
              ref
                  .read(cheatsheetsRiverpodProvider.notifier)
                  .toggleCheatsheetLikeStatus(sheet);
              isLiked.value = !isLiked.value;
            },
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
            icon: isLiked.value ? Icons.star_border : Icons.star,
            label: isLiked.value ? 'Unstar' : 'Star',
          ),
        ],
      ),
      child: ListTile(
        leading: cheatsheetIcon(sheet.secondaryLevel),
        title: Text(sheet.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            (isLiked.value) ? const Icon(Icons.star) : Container(),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          context.go("/cheatsheets/view/${sheet.name.replaceAll(" ", "_")}");
        },
      ),
    );
  }
}
