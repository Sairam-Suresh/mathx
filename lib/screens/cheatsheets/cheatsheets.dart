import 'package:flutter/material.dart' hide State;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mathx/logic/riverpods/cheatsheets_riverpod.dart';
import 'package:mathx/widgets/cheatsheet_list_tile.dart';

class FilterState {
  FilterState({required this.filters});
  final Set<int> filters;
}

class FilterAction {}

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

    var searchTermNotEmpty = searchTerm.value.isNotEmpty;

    var filter = useReducer<FilterState, FilterAction>(reducer,
        initialState: FilterState(filters: {}), initialAction: FilterAction());

    var cheatsheets = ref.watch(cheatsheetsRiverpodProvider);
    var anyFilterSelected = filter.state.filters.isNotEmpty;

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

          // TODO: Make this look a bit better
          (cheatsheets.valueOrNull == null)
              ? const Center(child: CircularProgressIndicator())
              : !anyFilterSelected
                  ? Expanded(
                      child: ListView(
                          shrinkWrap: true,
                          children: cheatsheets.value!
                              .map((e) => (!searchTermNotEmpty ||
                                      e.name.toLowerCase().contains(
                                          searchTerm.value.toLowerCase()))
                                  ? CheatsheetListTile(sheet: e)
                                  : Container())
                              .toList()),
                    )
                  : Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: cheatsheets.value!
                            .map((e) => (filter.state.filters
                                        .contains(e.secondaryLevel) &&
                                    (!searchTermNotEmpty ||
                                        e.name.toLowerCase().contains(
                                            searchTerm.value.toLowerCase())))
                                ? CheatsheetListTile(sheet: e)
                                : Container())
                            .toList(),
                      ),
                    )
        ],
      ),
    ));
  }
}
