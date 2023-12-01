import 'package:flutter/material.dart' hide State;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/data_storage/tables/cheatsheets.dart';
import 'package:mathx/logic/riverpods/cheatsheets_riverpod.dart';
import 'package:mathx/widgets/cheatsheet_list_tile.dart';

class FilterState {
  FilterState({required this.filters});
  final Set<int> filters;
}

class FilterAction {} // This class needs to be extended by the actions

class AddFilterAction extends FilterAction {
  final int level;
  AddFilterAction({required this.level});
}

class RemoveFilterAction extends FilterAction {
  final int level;
  RemoveFilterAction({required this.level});
}

FilterState reducer(FilterState state, action) {
  if (action is AddFilterAction) {
    return FilterState(filters: state.filters..add(action.level));
  } else if (action is RemoveFilterAction) {
    return FilterState(filters: state.filters..remove(action.level));
  }
  return state;
}

class Cheatsheets extends HookConsumerWidget {
  const Cheatsheets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var searchTerm = useState("");

    var filter = useReducer<FilterState, FilterAction>(reducer,
        initialState: FilterState(filters: {}), initialAction: FilterAction());

    var cheatsheets = ref.watch(cheatsheetsRiverpodProvider);

    var searchController = useTextEditingController();

    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Column(
              children: [
                SearchBar(
                  onChanged: (str) {
                    searchTerm.value = str;
                  },
                  controller: searchController,
                  leading: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.search),
                  ),
                  hintText: "Search for a cheatsheet",
                  trailing: (searchController.text.isNotEmpty)
                      ? [
                          IconButton(
                            onPressed: () {
                              searchController.clear();
                              searchTerm.value = "";
                            },
                            icon: const Icon(Icons.clear),
                          )
                        ]
                      : [
                          IconButton(
                            onPressed: () {
                              context.go("/cheatsheets/starred");
                            },
                            icon: const Icon(Icons.stars),
                          )
                        ],
                ),
                const SizedBox(
                  height: 8,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [1, 2, 3, 4]
                        .map((e) => Row(
                              children: [
                                FilterChip(
                                    selected: filter.state.filters.contains(e),
                                    label: Text("Secondary $e"),
                                    onSelected: (selected) {
                                      if (selected) {
                                        filter.dispatch(
                                            AddFilterAction(level: e));
                                      } else {
                                        filter.dispatch(
                                            RemoveFilterAction(level: e));
                                      }
                                    }),
                                const SizedBox(
                                  width: 8,
                                )
                              ],
                            ))
                        .toList(),
                  ),
                )
              ],
            ),
          ),
          (cheatsheets.valueOrNull == null)
              ? const Center(child: CircularProgressIndicator())
              : buildCheatSheetList(cheatSheetList, filter.state, searchTerm)
        ],
      ),
    ));
  }
}

Widget buildCheatSheetList(List<Cheatsheet> cheatsheets, FilterState filters,
    ValueNotifier<String> search) {
  final cheatsheetsCopy = cheatsheets.map((e) => e).toList();

  if (filters.filters.isNotEmpty) {
    cheatsheetsCopy.removeWhere(
        (element) => !(filters.filters.contains(element.secondaryLevel)));
  }

  if (search.value.isNotEmpty) {
    cheatsheetsCopy.removeWhere((element) =>
        !(element.name.toLowerCase().contains(search.value.toLowerCase())));
  }

  return Expanded(
    child: ListView(
      shrinkWrap: true,
      children:
          cheatsheetsCopy.map((e) => CheatsheetListTile(sheet: e)).toList(),
    ),
  );
}
