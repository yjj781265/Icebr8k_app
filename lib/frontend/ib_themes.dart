import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

class IbThemes {
  static final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      backgroundColor: IbColors.lightBlue,
      primaryColor: IbColors.primaryColor,
      primaryColorDark: IbColors.darkPrimaryColor,
      fontFamily: 'OpenSans',
      primarySwatch: Colors.lightBlue,
      accentColor: IbColors.accentColor);

  static final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      backgroundColor: IbColors.lightBlue,
      primaryColor: IbColors.primaryColor,
      primaryColorDark: IbColors.darkPrimaryColor,
      fontFamily: 'OpenSans',
      primarySwatch: Colors.lightBlue,
      accentColor: IbColors.accentColor);

  IbThemes._();
}
