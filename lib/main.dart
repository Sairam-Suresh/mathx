import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathx/screens/calculators/main_calculator.dart';
import 'package:mathx/screens/cheatsheets/cheatsheets.dart';
import 'package:mathx/screens/notes/note_view.dart';
import 'package:mathx/screens/notes/notes.dart';
import 'package:mathx/screens/root.dart';

void main() {
  runApp(const MyApp());
  runApp(const ProviderScope(child: MyApp()));
}

GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', redirect: (_, __) => "/notes"),
    ShellRoute(builder: (context, state, child) => Root(child: child), routes: [
      GoRoute(
          path: "/notes",
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: Notes()),
          routes: [
            GoRoute(
              path: "view/:note", // Use UUID Here
              builder: (context, state) => NoteViewAndEditor(),
            )
          ]),
      GoRoute(
          path: "/cheatsheets",
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: Cheatsheets())),
      GoRoute(
          path: "/calculator",
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MainCalculator())),
    ])
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true,
          brightness: Brightness.dark),
      routerConfig: _router,
    );
  }
}
