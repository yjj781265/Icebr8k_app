import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

import 'ib_config.dart';

class IbThemes {
  static final dark = ThemeData.dark().copyWith(
      primaryColor: const Color(0xff424242),
      toggleableActiveColor: IbColors.accentColor,
      tabBarTheme: const TabBarTheme(
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        labelColor: Colors.white,
        unselectedLabelColor: IbColors.lightGrey,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: IbConfig.kPageTitleSize,
            fontWeight: FontWeight.bold),
      ),
      scaffoldBackgroundColor: Colors.black,
      textTheme: GoogleFonts.gudeaTextTheme().copyWith(
        headline1: const TextStyle(color: Colors.white),
        headline2: const TextStyle(color: Colors.white),
        headline3: const TextStyle(color: Colors.white),
        headline4: const TextStyle(color: Colors.white),
        headline5: const TextStyle(color: Colors.white),
        headline6: const TextStyle(color: Colors.white),
        bodyText1: const TextStyle(color: Colors.white),
        bodyText2: const TextStyle(color: Colors.white),
        subtitle1: const TextStyle(color: Colors.white),
        subtitle2: const TextStyle(color: Colors.white),
        button: const TextStyle(color: IbColors.lightGrey),
        caption: const TextStyle(color: IbColors.lightGrey),
        overline: const TextStyle(color: IbColors.lightGrey),
      ));

  static final light = ThemeData.light().copyWith(
      toggleableActiveColor: IbColors.accentColor,
      primaryColor: IbColors.white,
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: IbColors.lightBlue,
        elevation: 0,
        titleSpacing: 0,
        titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: IbConfig.kPageTitleSize,
            fontWeight: FontWeight.bold),
      ),
      tabBarTheme: const TabBarTheme(
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        labelColor: Colors.black,
        unselectedLabelColor: IbColors.lightGrey,
      ),
      scaffoldBackgroundColor: IbColors.lightBlue,
      textTheme: GoogleFonts.gudeaTextTheme().copyWith(
        headline1: const TextStyle(color: Colors.black),
        headline2: const TextStyle(color: Colors.black),
        headline3: const TextStyle(color: Colors.black),
        headline4: const TextStyle(color: Colors.black),
        headline5: const TextStyle(color: Colors.black),
        headline6: const TextStyle(color: Colors.black),
        bodyText1: const TextStyle(color: Colors.black),
        bodyText2: const TextStyle(color: Colors.black),
        subtitle1: const TextStyle(color: Colors.black),
        subtitle2: const TextStyle(color: Colors.black),
        button: const TextStyle(color: IbColors.lightGrey),
        caption: const TextStyle(color: IbColors.lightGrey),
        overline: const TextStyle(color: IbColors.lightGrey),
      ));

  IbThemes._();
}
