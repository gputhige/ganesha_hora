import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String label;
  final TextStyle textStyle;
  final Function() onTap;
  final Color colorScheme;

  const MyButton({
    Key? key,
    required this.label,
    required this.onTap,
    required this.textStyle,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        //margin: const EdgeInsets.all(6.0),
        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 8.0),
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            label,
            style: textStyle,
            //textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
