import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:higherground/utils/my_colors.dart';

enum AppTheme { White, Dark }

/// Returns enum value name without enum class name.
String enumName(AppTheme anyEnum) {
  return anyEnum.toString().split('.')[1];
}

final appThemeData = {
  AppTheme.White: ThemeData(
    useMaterial3: true,
    dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
      color: Colors.grey[100],
    )),
    brightness: Brightness.light,
    primaryColor: MyColors.primary,
    //primarySwatch: MyColors.primary,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: MyColors.mainC0lor,
            statusBarIconBrightness: Brightness.light),
        color: MyColors.mainC0lor,
        elevation: 1,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        toolbarTextStyle: TextStyle(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
    cardTheme: CardThemeData(
      color: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: Colors.black87,
    ),

    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontFamily: 'WorkSans',
      ),
      headlineMedium: TextStyle(
        color: Colors.black54,
        fontFamily: 'WorkSans',
      ),
      titleSmall: TextStyle(
        color: Colors.white70,
        fontFamily: 'WorkSans',
        fontSize: 18.0,
      ),
    ),
  ),
  AppTheme.Dark: ThemeData(
    scaffoldBackgroundColor: Colors.black,
    fontFamily: "airbnb",
    primaryColor: MyColors.backgroundColor,
    canvasColor: MyColors.backgroundColor,
    brightness: Brightness.light,
    dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
      color: Colors.black,
    )),
    appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
        ),
        color: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        titleTextStyle: TextStyle(color: Colors.white)),
    bottomSheetTheme: BottomSheetThemeData(
        //backgroundColor: MyColors.grey_90,
        ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MyColors.backgroundColor,
    ),
    bottomAppBarTheme: BottomAppBarThemeData(color: MyColors.backgroundColor),
    dividerColor: Colors.grey.shade800,
    //bottomAppBarTheme: BottomAppBarTheme(color: MyColors.grey_90),
    cardTheme: CardThemeData(color: MyColors.backgroundColor, elevation: 20),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 20.0,
        fontFamily: 'airbnb',
      ),
      titleSmall: TextStyle(
        color: Colors.black,
        fontFamily: 'airbnb',
        fontSize: 18.0,
      ),
      headlineMedium: TextStyle(
        color: Colors.black,
        fontFamily: 'airbnb',
      ),
      displaySmall: TextStyle(
        color: Colors.black,
        fontFamily: 'airbnb',
      ),
      displayMedium: TextStyle(
        color: Colors.black,
        fontFamily: 'airbnb',
      ),
      displayLarge: TextStyle(
        color: Colors.black,
        fontFamily: 'airbnb',
      ),
      titleMedium: TextStyle(
        color: Colors.black,
        fontFamily: 'airbnb',
      ),
      bodyMedium: TextStyle(
        color: Colors.black,
        fontFamily: 'airbnb',
      ),
      bodyLarge: TextStyle(
        color: Colors.black,
        fontFamily: 'airbnb',
      ),
      labelSmall: TextStyle(
        color: Colors.black,
      ),
      bodySmall: TextStyle(
        color: Colors.black,
      ),
    ),
  ),
};


