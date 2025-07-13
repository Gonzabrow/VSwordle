import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vs_wordle/const/color.dart';
import 'package:vs_wordle/game/game_page.dart';
import 'package:vs_wordle/provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'VSwordle',
      debugShowCheckedModeBanner: false, // これなに？

      theme: ThemeData.light().copyWith(
        extensions: const [AppColors.light],
        splashFactory: NoSplash.splashFactory,
      ),
      darkTheme: ThemeData.dark().copyWith(
        extensions: const [AppColors.dark],
        splashFactory: NoSplash.splashFactory,
      ),
      themeMode: themeMode,
      
      home: const GamePage(), 
    );
  }
}