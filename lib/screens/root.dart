import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Root extends HookConsumerWidget {
  const Root({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var index = useState(0);

    var currentPage =
        GoRouter.of(context).routeInformationProvider.value.uri.path;
    switch (currentPage) {
      case "/notes":
        index.value = 0;
        break;
      case "/cheatsheets":
        index.value = 1;
        break;
      case "/calculator":
        index.value = 2;
        break;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index.value,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.notes), label: "Notes"),
          NavigationDestination(icon: Icon(Icons.book), label: "Cheatsheets"),
          NavigationDestination(
              icon: Icon(Icons.calculate), label: "Calculator"),
        ],
        onDestinationSelected: (newIndex) {
          index.value = newIndex;
          switch (newIndex) {
            case 0:
              context.go("/notes");
            case 1:
              context.go("/cheatsheets");
            case 2:
              context.go("/calculator");
          }
        },
      ),
    );
  }
}
