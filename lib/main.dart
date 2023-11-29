import 'package:flutter/material.dart';
import 'package:flutter_quill/translations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mathx/screens/calculators/main_calculator.dart';
import 'package:mathx/screens/cheatsheets/cheatsheets.dart';
import 'package:mathx/screens/notes/note_editor.dart';
import 'package:mathx/screens/notes/note_preview.dart';
import 'package:mathx/screens/notes/note_view.dart';
import 'package:mathx/screens/notes/notes.dart';
import 'package:mathx/screens/root.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', redirect: (_, __) => "/notes"),
    ShellRoute(builder: (context, state, child) => Root(child: child), routes: [
      GoRoute(
          path: "/notes",
          redirect: (context, state) {
            return (state.uri.queryParameters["source"] != null &&
                    state.uri.queryParameters["source"] != "" &&
                    state.fullPath != null &&
                    state.fullPath != "/notes/preview")
                ? "/notes/preview?source=${state.uri.queryParameters["source"]}"
                : null;
          },
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: Notes()),
          routes: [
            GoRoute(
                path: "preview",
                pageBuilder: (context, state) => MaterialPage(
                    child: NotePreview(noteData: state.uri),
                    fullscreenDialog: true)),
            GoRoute(
              path: "view/:note", // Use UUID Here
              pageBuilder: (context, state) => MaterialPage(
                  child: NoteView(
                uuid: state.pathParameters["note"]!,
              )),
            ),
            GoRoute(
              path: "edit/:note",
              pageBuilder: (context, state) {
                Widget child = NoteEditor(uuid: state.pathParameters["note"]!);

                return CustomTransitionPage(
                  child: child,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
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
          primaryColor: Colors.deepPurple,
          highlightColor: Colors.deepPurple,
          brightness: Brightness.dark),
      routerConfig: _router,
      localizationsDelegates: const [
        ...FlutterQuillLocalizations.localizationsDelegates
      ],
    );
  }
}
