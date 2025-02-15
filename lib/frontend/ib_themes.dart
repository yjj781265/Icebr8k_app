import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            dateTimePickerTextStyle: TextStyle(
              color: Colors.white,
              fontSize: IbConfig.kNormalTextSize,
            ),
          ),
        ),
        primaryColor: Colors.black,
        indicatorColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
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
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.oxygen(
              fontSize: IbConfig.kPageTitleSize,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.oxygenTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: IbColors.primaryColor), checkboxTheme: CheckboxThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return IbColors.primaryColor; }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return IbColors.primaryColor; }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return IbColors.primaryColor; }
 return null;
 }),
 trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return IbColors.primaryColor; }
 return null;
 }),
 ));
    return dark;
  }

  ThemeData buildLightTheme() {
    final light = ThemeData.light().copyWith(
        cupertinoOverrideTheme: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(
              color: Colors.black,
              fontSize: IbConfig.kNormalTextSize,
            ),
          ),
        ),
        primaryColor: IbColors.lightBlue,
        indicatorColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        appBarTheme: AppBarTheme(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: IbColors.lightBlue,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            titleSpacing: 0,
            titleTextStyle: GoogleFonts.oxygen(
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
        brightness: Brightness.light,
        textTheme: GoogleFonts.oxygenTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.black, displayColor: Colors.black), checkboxTheme: CheckboxThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return IbColors.primaryColor; }
 return null;
 }),
 ), radioTheme: RadioThemeData(
 fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return IbColors.primaryColor; }
 return null;
 }),
 ), switchTheme: SwitchThemeData(
 thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return IbColors.primaryColor; }
 return null;
 }),
 trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
 if (states.contains(MaterialState.disabled)) { return null; }
 if (states.contains(MaterialState.selected)) { return IbColors.primaryColor; }
 return null;
 }),
 ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: IbColors.primaryColor).copyWith(background: IbColors.creamYellow));
    return light;
  }
}
