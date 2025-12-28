import 'package:flutter/material.dart';

class StateColorSet {
  final Color hit;
  final Color blow;
  final Color absent;

  const StateColorSet({
    required this.hit,
    required this.blow,
    required this.absent,
  });

  static StateColorSet lerp(StateColorSet a, StateColorSet b, double t) {
    return StateColorSet(
      hit: Color.lerp(a.hit, b.hit, t)!,
      blow: Color.lerp(a.blow, b.blow, t)!,
      absent: Color.lerp(a.absent, b.absent, t)!,
    );
  }
}

class GameFieldColorSet {
  final Color Background;
  final Color BorderPrimary;
  final Color BorderSecondary;
  final Color Keyboard;
  final Color TextPrimary;
  final Color TextSecondary;

  const GameFieldColorSet({
    required this.Background,
    required this.BorderPrimary,
    required this.BorderSecondary,
    required this.Keyboard,
    required this.TextPrimary,
    required this.TextSecondary,
  });

  static GameFieldColorSet lerp(GameFieldColorSet a, GameFieldColorSet b, double t) {
    return GameFieldColorSet(
      Background: Color.lerp(a.Background, b.Background, t)!,
      BorderPrimary: Color.lerp(a.BorderPrimary, b.BorderPrimary, t)!,
      BorderSecondary: Color.lerp(a.BorderSecondary, b.BorderSecondary, t)!,
      Keyboard: Color.lerp(a.Keyboard, b.Keyboard, t)!,
      TextPrimary: Color.lerp(a.TextPrimary, b.TextPrimary, t)!,
      TextSecondary: Color.lerp(a.TextSecondary, b.TextSecondary, t)!,
    );
  }
}

class StartFieldColorSet {
  final Color Background;
  final Color ButtonPrimary;
  final Color ButtonSecondary;
  final Color MainText;
  final Color DarkText;
  final Color LightText;

  const StartFieldColorSet({
    required this.Background,
    required this.ButtonPrimary,
    required this.ButtonSecondary,
    required this.MainText,
    required this.DarkText,
    required this.LightText,
  });

  static StartFieldColorSet lerp(StartFieldColorSet a, StartFieldColorSet b, double t) {
    return StartFieldColorSet(
      Background: Color.lerp(a.Background, b.Background, t)!,
      ButtonPrimary: Color.lerp(a.ButtonPrimary, b.ButtonPrimary, t)!,
      ButtonSecondary: Color.lerp(a.ButtonSecondary, b.ButtonSecondary, t)!,
      MainText: Color.lerp(a.MainText, b.MainText, t)!,
      DarkText: Color.lerp(a.DarkText, b.DarkText, t)!,
      LightText: Color.lerp(a.LightText, b.LightText, t)!,
    );
  }
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final StateColorSet state;
  final GameFieldColorSet field;
  final StartFieldColorSet start;

  const AppColors( {
    required this.state,
    required this.field,
    required this.start,
  } );

  @override
  AppColors copyWith({
    StateColorSet? state,
    GameFieldColorSet? field,
    StartFieldColorSet? start,
  }) {
    return AppColors(
      state: state ?? this.state,
      field: field ?? this.field,
      start: start ?? this.start,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      state: StateColorSet.lerp(state, other.state, t),
      field: GameFieldColorSet.lerp(field, other.field, t),
      start: StartFieldColorSet.lerp(start, other.start, t),
    );
  }

  static const AppColors light = AppColors(
    state: StateColorSet(
      hit: Color(0xFF6AAA64),
      blow: Color(0xFFC9B458),
      absent: Color(0xFF787C7E),
    ),

    field: GameFieldColorSet(
      Background: Color(0xFFFFFFFF),
      BorderPrimary: Color(0xFFD3D6DA),
      BorderSecondary: Color(0xFF86898C),
      Keyboard: Color(0xFFD3D6DC),
      TextPrimary: Color(0xFF000000),
      TextSecondary: Color(0xFFFFFFFF),
    ),

    start: StartFieldColorSet(
      Background: Color(0xFFE3E3E1),
      ButtonPrimary: Color(0xFF121212),
      ButtonSecondary: Color(0xFFE3E3E1),
      MainText: Color(0xFF000000),
      DarkText: Color(0xFF121212),
      LightText: Color(0xFFE8E8E8),
    ),
  );

  static const AppColors dark = AppColors(
    state: StateColorSet(
      hit: Color(0xFF528D4D),
      blow: Color(0xFFB59F3A),
      absent: Color(0xFF3A3A3C),
    ),

    field: GameFieldColorSet(
      Background: Color(0xFF121212), 
      BorderPrimary: Color(0xFF3A3A3C),
      BorderSecondary: Color(0xFF565759),
      Keyboard: Color(0xFF818385),
      TextPrimary: Color(0xFFF8F8F8),
      TextSecondary: Color(0xFFF8F8F8),
    ),

    start: StartFieldColorSet(
      Background: Color(0xFFE3E3E1),
      ButtonPrimary: Color(0xFF121212),
      ButtonSecondary: Color(0xFFE3E3E1),
      MainText: Color(0xFF000000),
      DarkText: Color(0xFF121212),
      LightText: Color(0xFFE8E8E8),
    ),
  );

  // static const Color darkBackground = Color(0xFF121212);
  // static const Color darkBorder = Color(0xFF353536);
  // static const Color darkKeyboard = Color(0xFF818385);
  // static const Color darkTextPrimary = Color(0xFFFFFFFF);

  // static const Color lightBackground = Color(0xFFF5F5F5);

  // static const Color hit = Color(0xFF528D4D);
  // static const Color blow = Color(0xFFB59F3A);
  // static const Color absent = Color(0xFF3A3A3C);
}