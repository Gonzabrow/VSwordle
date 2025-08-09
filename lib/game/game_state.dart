import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../const/color.dart';
import '../provider.dart';
import 'game_page.dart';
import 'widget/word_grid.dart';
import 'widget/keyboard.dart';

class GamePageState extends ConsumerState<GamePage> {
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.field.Background,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            PreferredSize(
              preferredSize: Size.fromHeight(1.0), 
              child: AppBar(
                backgroundColor: appColors.field.Background,
                elevation: 0,
                title: Text(ref.watch(answerWordProvider)),
                actions: [
                  IconButton(
                    icon: Icon(Icons.brightness_6, color: appColors.field.TextPrimary),
                    onPressed: () { ref.read(themeModeProvider.notifier).toggle(); } 
                  ),
                ],
                shape: Border(
                  bottom: BorderSide(
                    color: appColors.field.BorderPrimary,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            WordGrid(),
            Spacer(),
            Keyboard(),
          ],
        ),
      )
    );
  }

}