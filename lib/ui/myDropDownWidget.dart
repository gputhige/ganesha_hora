import 'package:flutter/material.dart';
import 'package:parashara_hora/ui/theme.dart';

class MyDropDownWidget extends StatefulWidget {
  final String title;
  String listSex;
  final List<String> sex;
  final String hint;
  final TextStyle textStyle;
  final double containerWidth;
  final Function onchanged;

  MyDropDownWidget(
      {Key? key,
      required this.title,
      required this.listSex,
      required this.sex,
      required this.hint,
      required this.textStyle,
      required this.onchanged,
      required this.containerWidth})
      : super(key: key);

  @override
  State<MyDropDownWidget> createState() => _MyDropDownWidgetState();
}

class _MyDropDownWidgetState extends State<MyDropDownWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: widget.textStyle,
          ),
          Container(
              width: widget.containerWidth,
              height: 35,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.0),
                  borderRadius: const BorderRadius.all(Radius.circular(5.0))),
              child: DropdownButton<String>(
                  value: widget.listSex,
                  dropdownColor: Colors.amber,
                  items:
                      widget.sex.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ));
                  }).toList(),
                  onChanged: widget.onchanged()))
        ],
      ),
    );
  }
}
