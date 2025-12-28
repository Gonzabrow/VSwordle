import 'package:flutter/material.dart';
import 'package:vs_wordle/const/color.dart';
import 'package:vs_wordle/game/widget/menu_button.dart';

class MatchSelectPage extends StatelessWidget {
  const MatchSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!.start;

    return Scaffold(
      backgroundColor: appColors.Background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: appColors.MainText),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select Match Type',
              style: TextStyle(
                fontSize: 50, 
                fontWeight: FontWeight.bold, 
                color: appColors.MainText,
              ),
            ),
            const SizedBox(height: 32),
            MenuButton(
              label: 'Private Match',
              onPressed: () {},
              backgroundColor: appColors.ButtonPrimary,
              textColor: appColors.LightText,
              borderColor: appColors.ButtonPrimary,
            ),
            const SizedBox(height: 8),
            MenuButton(
              label: 'Random Match',
              onPressed: () {},
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
