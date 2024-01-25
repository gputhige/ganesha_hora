import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color blueClr = Color(0xFF2196F3);
const Color yellowClr = Color(0xFFFFB746);
const Color pinkClr = Color(0xFFff4667);
const Color darkGreyClr = Color(0xFF121212);
const darkHdrClr = Color(0xFF424242);
const primaryClr = blueClr;
const secondaryClr = yellowClr;

class Themes {
  static final light =
      ThemeData(primaryColor: primaryClr, brightness: Brightness.light);
  static final dark =
      ThemeData(primaryColor: darkGreyClr, brightness: Brightness.dark);
}

TextStyle get headingStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  ));
}

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black));
}

TextStyle get titleStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
  ));
}

TextStyle get titleStyleBlack {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black));
}

TextStyle get subTitleStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ));
}

TextStyle get contentStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  ));
}

TextStyle get hintStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color.fromRGBO(0, 0, 0, .5),
  ));
}

TextStyle get paraBoldStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  ));
}

TextStyle get paraBoldStyleBlack {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ));
}

TextStyle get paraStyle {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  ));
}

TextStyle get paraStylRed {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.red,
  ));
}

TextStyle get paraStyleBlack {
  return GoogleFonts.lato(
      textStyle: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  ));
}
