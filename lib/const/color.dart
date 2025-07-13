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

class FieldColorSet {
  final Color Background;
  final Color BorderPrimary;
  final Color BorderSecondary;
  final Color Keyboard;
  final Color TextPrimary;
  final Color TextSecondary;

  const FieldColorSet({
    required this.Background,
    required this.BorderPrimary,
    required this.BorderSecondary,
    required this.Keyboard,
    required this.TextPrimary,
    required this.TextSecondary,
  });

  static FieldColorSet lerp(FieldColorSet a, FieldColorSet b, double t) {
    return FieldColorSet(
      Background: Color.lerp(a.Background, b.Background, t)!,
      BorderPrimary: Color.lerp(a.BorderPrimary, b.BorderPrimary, t)!,
      BorderSecondary: Color.lerp(a.BorderSecondary, b.BorderSecondary, t)!,
      Keyboard: Color.lerp(a.Keyboard, b.Keyboard, t)!,
      TextPrimary: Color.lerp(a.TextPrimary, b.TextPrimary, t)!,
      TextSecondary: Color.lerp(a.TextSecondary, b.TextSecondary, t)!,
    );
  }
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final StateColorSet state;
  final FieldColorSet field;

  const AppColors( {
    required this.state,
    required this.field,
  } );

  @override
  AppColors copyWith({
    StateColorSet? state,
    FieldColorSet? field,
  }) {
    return AppColors(
      state: state ?? this.state,
      field: field ?? this.field,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      state: StateColorSet.lerp(state, other.state, t),
      field: FieldColorSet.lerp(field, other.field, t),
    );
  }

  static const AppColors light = AppColors(
    state: StateColorSet(
      hit: Color(0xFF6AAA64),
      blow: Color(0xFFC9B458),
      absent: Color(0xFF787C7E),
    ),

    field: FieldColorSet(
      Background: Color(0xFFFFFFFF),
      BorderPrimary: Color(0xFFD3D6DA),
      BorderSecondary: Color(0xFF86898C),
      Keyboard: Color(0xFFD3D6DC),
      TextPrimary: Color(0xFF000000),
      TextSecondary: Color(0xFFFFFFFF),
    ),
  );

  static const AppColors dark = AppColors(
    state: StateColorSet(
      hit: Color(0xFF528D4D),
      blow: Color(0xFFB59F3A),
      absent: Color(0xFF3A3A3C),
    ),

    field: FieldColorSet(
      Background: Color(0xFF121212),
      BorderPrimary: Color(0xFF3A3A3C),
      BorderSecondary: Color(0xFF565759),
      Keyboard: Color(0xFF818385),
      TextPrimary: Color(0xFFF8F8F8),
      TextSecondary: Color(0xFFF8F8F8),
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