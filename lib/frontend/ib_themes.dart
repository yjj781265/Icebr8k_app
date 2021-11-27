import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

import 'ib_config.dart';

class IbThemes {
  BuildContext context;

  IbThemes(this.context);

  ThemeData buildDarkTheme() {
    final dark = ThemeData.dark().copyWith(
        cupertinoOverrideTheme: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        primaryColor: const Color(0xff424242),
        iconTheme: const IconThemeData(color: Colors.white),
        toggleableActiveColor: IbColors.primaryColor,
        tabBarTheme: const TabBarTheme(
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
              color: IbColors.primaryColor,
              borderRadius: BorderRadius.all(
                  Radius.circular(IbConfig.kCardCornerRadius))),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelColor: Colors.white,
          unselectedLabelColor: IbColors.lightGrey,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleSpacing: 0,
          titleTextStyle: GoogleFonts.sourceSansPro(
              fontSize: IbConfig.kPageTitleSize,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.sourceSansProTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: IbColors.primaryColor));
    return dark;
  }

  ThemeData buildLightTheme() {
    final light = ThemeData.light().copyWith(
        cupertinoOverrideTheme: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(color: Colors.black),
          ),
        ),
        toggleableActiveColor: IbColors.primaryColor,
        primaryColor: IbColors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        appBarTheme: AppBarTheme(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: IbColors.lightBlue,
            elevation: 0,
            titleSpacing: 0,
            titleTextStyle: GoogleFonts.sourceSansPro(
                fontSize: IbConfig.kPageTitleSize,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
        tabBarTheme: const TabBarTheme(
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
              color: IbColors.primaryColor,
              borderRadius: BorderRadius.all(
                  Radius.circular(IbConfig.kCardCornerRadius))),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelColor: Colors.white,
          unselectedLabelColor: IbColors.lightGrey,
        ),
        scaffoldBackgroundColor: IbColors.lightBlue,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: IbColors.primaryColor),
        textTheme: GoogleFonts.sourceSansProTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.black, displayColor: Colors.black));
    return light;
  }
}
