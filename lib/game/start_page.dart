import 'package:flutter/material.dart';
import 'package:vs_wordle/const/color.dart';
import 'package:vs_wordle/game/game_page.dart';
import 'package:vs_wordle/game/widget/menu_button.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!.start;

    return Scaffold(
      backgroundColor: appColors.Background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'VSwordle',
              style: TextStyle(
                fontSize: 50, 
                fontWeight: FontWeight.bold, 
                color: appColors.MainText,
              ),
            ),
            const SizedBox(height: 32),
            MenuButton(
              label: 'Play',
              onPressed: () {},
              backgroundColor: appColors.ButtonPrimary,
              textColor: appColors.LightText,
              borderColor: appColors.ButtonPrimary,
            ),
            const SizedBox(height: 8),
            MenuButton(
              label: 'Practice',
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const GamePage(),
                  ),
                );
              },
              backgroundColor: appColors.ButtonSecondary,
              textColor: appColors.DarkText,
              borderColor: appColors.ButtonPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
