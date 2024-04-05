import 'package:flutter/material.dart';
import 'package:parashara_hora/ui/theme.dart';

class MyTextInputWidget extends StatelessWidget {
  final String title;
  final String hint;
  final TextStyle textStyle;
  final TextCapitalization textCapital;
  final TextEditingController? controller;
  final Widget? widget;
  final TextInputType textInputType;
  final bool? isObscure;
  final double containerWidth;

  const MyTextInputWidget(
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
            width: containerWidth,
            height: 35,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.0),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: TextFormField(
              autofocus: false,
              cursorColor: Colors.white,
              controller: controller,
              style: contentStyle,
              keyboardType: textInputType,
              textCapitalization: textCapital,
              autovalidateMode: AutovalidateMode.always,
              obscureText: isObscure ?? false,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: hintStyle,
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 0.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 1.0),
                ),
              ),
              onChanged: (value) {},
            ),
          )
        ],
      ),
    );
  }
}
