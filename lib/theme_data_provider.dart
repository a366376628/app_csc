import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:laundrivr/src/model/provider/provider.dart';

class ThemeDataProvider extends Provider<ThemeData> {
  @override
  void initialize() {}

  @override
  ThemeData provide() {
    return ThemeData.dark().copyWith(extensions: <ThemeExtension<dynamic>>[
      LaundrivrTheme(
        opaqueBackgroundColor: const Color(0xff0F162A),
        secondaryOpaqueBackgroundColor: const Color(0xff182243),
        tertiaryOpaqueBackgroundColor: const Color(0xff14223D),
        primaryBrightTextColor: const Color(0xffffffff),
        primaryTextStyle: GoogleFonts.urbanist(),
        selectedIconColor: const Color(0xffb3b8c8),
        unselectedIconColor: const Color(0xff546087),
        goldenTextColor: const Color(0xffFDDD02),
        bottomNavBarBackgroundColor: const Color(0xff273563),
        brightBadgeBackgroundColor: const Color(0xff479ade),
        pricingGreen: const Color(0xff6EF54C),
        backButtonBackgroundColor: const Color(0xD9D9D9D9),
        pinCodeInactiveColor: const Color(0xff546087),
        pinCodeActiveValidColor: const Color(0xff6EF54C),
        pinCodeActiveInvalidColor: const Color(
          0xffFF0000,
        ),
      )
    ]);
  }
}
