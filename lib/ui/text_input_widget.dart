import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ui/theme.dart';

class MyTextInputField extends StatelessWidget {
  final String title;
  final String hint;
  final TextStyle textStyle;
  final TextCapitalization textCapital;
  final TextEditingController? controller;
  final Widget? widget;
  final TextInputType textInputType;
  final bool? isObscure;
  final double containerWidth;

  const MyTextInputField(
      {Key? key,
      required this.title,
      required this.hint,
      required this.textStyle,
      required this.textInputType,
      required this.textCapital,
      this.controller,
      this.widget,
      this.isObscure,
      required this.containerWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textStyle,
          ),
          Container(
            height: 42,
            width: containerWidth,
            margin: const EdgeInsets.only(top: 3.0),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0),
                borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autofocus: false,
                    cursorColor: Colors.white,
                    controller: controller,
                    style: contentStyle,
                    keyboardType: textInputType,
                    textCapitalization: textCapital,
                    autovalidateMode: AutovalidateMode.always,
                    obscureText: isObscure ?? false,
                    readOnly: widget != null ? true : false,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: hintStyle,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 0.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 0.0),
                      ),
                    ),
                  ),
                ),
                widget ??
                    Container(
                      child: widget,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
/* 
  TextStyle get contentStyle {
    return GoogleFonts.lato(
        textStyle: const TextStyle(fontSize: 16),
        fontWeight: FontWeight.normal);
  }

  TextStyle get hintStyle {
    return GoogleFonts.lato(
        textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.grey,
    ));
  } */
}
