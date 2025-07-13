// これどこに置くのがいいんだろね？
import 'package:flutter/material.dart';
import 'package:vs_wordle/const/color.dart';
import 'package:vs_wordle/const/type.dart';

Color getColorForStatus(LetterStatus status, AppColors appColors) {
  switch (status) {
    case LetterStatus.hit:
      return appColors.state.hit;
    case LetterStatus.blow:
      return appColors.state.blow;
    case LetterStatus.absent:
      return appColors.state.absent;
  }
}