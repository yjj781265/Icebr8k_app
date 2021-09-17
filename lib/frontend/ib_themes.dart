import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

import 'ib_config.dart';

class IbThemes {
  static final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      toggleableActiveColor: IbColors.accentColor,
      backgroundColor: IbColors.lightBlue,
      primaryColor: IbColors.primaryColor,
      primaryColorDark: IbColors.darkPrimaryColor,
      fontFamily: 'OpenSans',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
        titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: IbConfig.kPageTitleSize,
            fontWeight: FontWeight.bold),
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue)
          .copyWith(secondary: IbColors.accentColor));

  static final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      backgroundColor: IbColors.lightBlue,
      primaryColor: IbColors.primaryColor,
      primaryColorDark: IbColors.darkPrimaryColor,
      fontFamily: 'OpenSans',
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.lightBlue)
          .copyWith(secondary: IbColors.accentColor));

  IbThemes._();
}
