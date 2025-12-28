import 'package:flutter/material.dart';
import 'package:vs_wordle/const/color.dart';
import 'package:vs_wordle/game/widget/menu_button.dart';

class EnterRoomIDPage extends StatefulWidget {
  const EnterRoomIDPage({super.key});

  @override
  State<EnterRoomIDPage> createState() => _EnterRoomIDPageState();
}

class _EnterRoomIDPageState extends State<EnterRoomIDPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter Room ID',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: appColors.MainText,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Room ID',
                  hintStyle: TextStyle(color: appColors.ButtonSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appColors.ButtonPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appColors.ButtonPrimary, width: 2),
                  ),
                  filled: true,
                  fillColor: appColors.Background,
                ),
                style: TextStyle(color: appColors.MainText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              MenuButton(
                label: 'Enter',
                onPressed: () {
                  // TODO: ルーム入室処理
                  final roomId = _controller.text;
                  print('Room ID: $roomId');
                },
                backgroundColor: appColors.ButtonPrimary,
                textColor: appColors.LightText,
                borderColor: appColors.ButtonPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
