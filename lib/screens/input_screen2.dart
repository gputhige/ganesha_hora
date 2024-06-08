import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/screens/sweph_data.dart';
import 'package:parashara_hora/ui/myTextInputWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import '../ui/theme.dart';

class InputScreen2 extends StatefulWidget {
  final List<double> sizes;
  const InputScreen2({Key? key, required this.sizes}) : super(key: key);

  @override
  State<InputScreen2> createState() => _InputScreen2State();
}

class _InputScreen2State extends State<InputScreen2> {
  Future? future;
  double screenwd = 0, screenht = 0;
  List<TextEditingController> textController = [];
  DateTime selectedDate = DateTime.now();
  DateTime? formDate;
  String selectedTime = DateFormat('hh:mm a').format(DateTime.now());
  int coord = 1;
  List<String> listsex = <String>['', 'Male', 'Female'];
  List<String> listns = <String>['', 'North', 'South'];
  List<String> listew = ['', 'East', 'West'];
  List<String> listzne = ['', ' (+) ', ' (-) '];
  List<String> errmsg = [
    'Incomplete Text/Dropdown Fields',
    'Incorrect Date/Time Entered',
    'Incorrect Coordinates'
  ];
  List<String> listmnths = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<String> dropString = ['', '', '', '', ''];
  String? sex, mnts, nors, estw, zone;
  bool allOkay = true;
  double? latt, lngg;

  @override
  void initState() {
    // TODO: implement initState
    future = _future();
    super.initState();
  }

  Future<int> _future() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    screenwd = widget.sizes[0];
    screenht = widget.sizes[1];
    for (int i = 0; i < 16; i++) {
      textController.add(TextEditingController());
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange,
        body: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  'Data Error...Please try again',
                  style: Theme.of(context).textTheme.titleSmall,
                ));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  'Waiting',
                  style: Theme.of(context).textTheme.titleSmall,
                );
              } else if (!snapshot.hasData) {
                return Text(
                  'No Data',
                  style: Theme.of(context).textTheme.titleSmall,
                );
              } else if (snapshot.hasData) {
                //Block I====================================================
                return SafeArea(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                          border: Border.all(width: 2.0), color: Colors.blue),
                      width: screenwd * .8,
                      height: screenht * .75,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              'Enter Details',
                              style: subHeadingStyle,
                            ),
                            Text(
                              'Start Date: 01-01-1900; Time Format: 24 Hour',
                              style: titleStyleBlack,
                            ),
                            const SizedBox(
                              height: 25.0,
                            ),
                            const Divider(height: 5, color: Colors.black),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal-Details',
                                  style: titleStyleBlack,
                                ),
                                const SizedBox(
                                  width: 23,
                                ),
                                MyTextInputWidget(
                                  title: 'Name',
                                  hint: 'Enter Name',
                                  textStyle: paraBoldStyle,
                                  textInputType: TextInputType.name,
                                  textCapital: TextCapitalization.words,
                                  controller: textController[0],
                                  containerWidth: 200,
                                ),
                                const Spacer(),
                                dropDownMenu(
                                    'Sex', dropString[0], listsex, 0, 80),
                                const Spacer(),
                                MyTextInputWidget(
                                  title: 'City',
                                  hint: 'Bangalore',
                                  textStyle: paraBoldStyle,
                                  textInputType: TextInputType.name,
                                  textCapital: TextCapitalization.words,
                                  controller: textController[1],
                                  containerWidth: 150,
                                ),
                                const Spacer(),
                                MyTextInputWidget(
                                  title: 'Country',
                                  hint: 'India',
                                  textStyle: paraBoldStyle,
                                  textInputType: TextInputType.name,
                                  textCapital: TextCapitalization.words,
                                  controller: textController[15],
                                  containerWidth: 100,
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              height: 5,
                              color: Colors.black,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            //Block II====================================================
                            Row(
                              children: [
                                Text(
                                  'Birth Details',
                                  style: titleStyleBlack,
                                ),
                                const SizedBox(
                                  width: 52,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    dropDownMenu('Month', dropString[1],
                                        listmnths, 1, 100),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    MyTextInputWidget(
                                      title: 'Day',
                                      hint: '01',
                                      textStyle: paraBoldStyle,
                                      textInputType: TextInputType.number,
                                      textCapital: TextCapitalization.words,
                                      controller: textController[2],
                                      containerWidth: 40,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    MyTextInputWidget(
                                      title: 'Year',
                                      hint: '1900',
                                      textStyle: paraBoldStyle,
                                      textInputType: TextInputType.number,
                                      textCapital: TextCapitalization.words,
                                      controller: textController[3],
                                      containerWidth: 60,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                                Text(
                                  '\n- ',
                                  style: paraBoldStyle,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                MyTextInputWidget(
                                  title: 'Hrs',
                                  hint: '01',
                                  textStyle: paraBoldStyle,
                                  textInputType: TextInputType.number,
                                  textCapital: TextCapitalization.words,
                                  controller: textController[4],
                                  containerWidth: 40,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                MyTextInputWidget(
                                  title: 'Mins',
                                  hint: '30',
                                  textStyle: paraBoldStyle,
                                  textInputType: TextInputType.number,
                                  textCapital: TextCapitalization.words,
                                  controller: textController[5],
                                  containerWidth: 40,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                MyTextInputWidget(
                                  title: 'Secs',
                                  hint: '30',
                                  textStyle: paraBoldStyle,
                                  textInputType: TextInputType.number,
                                  textCapital: TextCapitalization.words,
                                  controller: textController[6],
                                  containerWidth: 40,
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              height: 5,
                              color: Colors.black,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            //Block III====================================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Coordinates',
                                  style: titleStyleBlack,
                                ),
                                const SizedBox(
                                  width: 53,
                                ),
                                ElevatedButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        coord = 1;
                                      });
                                    },
                                    child: Text(
                                      'Degree',
                                      style: paraBoldStyle,
                                    )),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Or',
                                  style: subTitleStyle,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.blueGrey),
                                  onPressed: () {
                                    setState(() {
                                      coord = 0;
                                    });
                                  },
                                  child: Text(
                                    'Decimal',
                                    style: paraBoldStyle,
                                  ),
                                ),
                                const Spacer(),
                                (textController[1].text.isNotEmpty &&
                                        textController[15].text.isNotEmpty)
                                    ? ElevatedButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        onPressed: () {
                                          String url =
                                              'https://www.timeanddate.com/worldclock/${textController[15].text}/${textController[1].text}';
                                          FlutterWebBrowser.openWebPage(
                                              url: url);
                                        },
                                        child: Text(
                                          'Get Coord',
                                          style: paraBoldStyle,
                                        ))
                                    : Container(),
                                const Spacer(),
                                const Text('Use Standard Time for Time Zone'),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Divider(
                              height: 5,
                              color: Colors.black,
                            ),
                            //Block IV====================================================
                            coord == 0
                                ? Row(
                                    children: [
                                      Text(
                                        'Latitude',
                                        style: titleStyleBlack,
                                      ),
                                      const SizedBox(
                                        width: 85,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          dropDownMenu('North/South',
                                              dropString[3], listns, 3, 100),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          MyTextInputWidget(
                                            title: 'Latitude',
                                            hint: '16.255',
                                            textStyle: paraBoldStyle,
                                            textInputType: const TextInputType
                                                    .numberWithOptions(
                                                decimal: true),
                                            textCapital:
                                                TextCapitalization.words,
                                            controller: textController[7],
                                            containerWidth: 70,
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        'Longitude',
                                        style: titleStyleBlack,
                                      ),
                                      const SizedBox(
                                        width: 30,
                                      ),
                                      dropDownMenu('East/West', dropString[4],
                                          listew, 4, 100),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      MyTextInputWidget(
                                        title: 'Longitude',
                                        hint: '80.255',
                                        textStyle: paraBoldStyle,
                                        textInputType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        textCapital: TextCapitalization.words,
                                        controller: textController[8],
                                        containerWidth: 70,
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Time Zone:',
                                        style: titleStyleBlack,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      dropDownMenu('(+) or (-) GMT',
                                          dropString[2], listzne, 2, 80),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      MyTextInputWidget(
                                        title: 'Hrs',
                                        hint: '5',
                                        textStyle: paraBoldStyle,
                                        textInputType: TextInputType.number,
                                        textCapital: TextCapitalization.words,
                                        controller: textController[13],
                                        containerWidth: 36,
                                      ),
                                      const Text(' : '),
                                      MyTextInputWidget(
                                        title: 'Mins',
                                        hint: '30',
                                        textStyle: paraBoldStyle,
                                        textInputType: TextInputType.number,
                                        textCapital: TextCapitalization.words,
                                        controller: textController[14],
                                        containerWidth: 36,
                                      ),
                                      const Spacer(),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Text(
                                        'Latitude',
                                        style: titleStyleBlack,
                                      ),
                                      const SizedBox(
                                        width: 85,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          dropDownMenu('North/South',
                                              dropString[3], listns, 3, 100),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          MyTextInputWidget(
                                            title: 'Deg',
                                            hint: '12',
                                            textStyle: paraBoldStyle,
                                            textInputType: TextInputType.number,
                                            textCapital:
                                                TextCapitalization.words,
                                            controller: textController[9],
                                            containerWidth: 40,
                                          ),
                                          const Text(' : '),
                                          MyTextInputWidget(
                                            title: 'Mins',
                                            hint: '30',
                                            textStyle: paraBoldStyle,
                                            textInputType: TextInputType.number,
                                            textCapital:
                                                TextCapitalization.words,
                                            controller: textController[10],
                                            containerWidth: 40,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Longitude',
                                        style: titleStyleBlack,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      dropDownMenu('East/West', dropString[4],
                                          listew, 4, 100),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      MyTextInputWidget(
                                        title: 'Deg',
                                        hint: '80',
                                        textStyle: paraBoldStyle,
                                        textInputType: TextInputType.number,
                                        textCapital: TextCapitalization.words,
                                        controller: textController[11],
                                        containerWidth: 40,
                                      ),
                                      const Text(' : '),
                                      MyTextInputWidget(
                                        title: 'Mins',
                                        hint: '30',
                                        textStyle: paraBoldStyle,
                                        textInputType: TextInputType.number,
                                        textCapital: TextCapitalization.words,
                                        controller: textController[12],
                                        containerWidth: 40,
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Time Zone:',
                                        style: titleStyleBlack,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      dropDownMenu('(+) or (-) GMT',
                                          dropString[2], listzne, 2, 80),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      MyTextInputWidget(
                                        title: 'Hrs',
                                        hint: '5',
                                        textStyle: paraBoldStyle,
                                        textInputType: TextInputType.number,
                                        textCapital: TextCapitalization.words,
                                        controller: textController[13],
                                        containerWidth: 36,
                                      ),
                                      const Text(' : '),
                                      MyTextInputWidget(
                                        title: 'Mins',
                                        hint: '30',
                                        textStyle: paraBoldStyle,
                                        textInputType: TextInputType.number,
                                        textCapital: TextCapitalization.words,
                                        controller: textController[14],
                                        containerWidth: 36,
                                      ),
                                    ],
                                  ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              height: 5,
                              color: Colors.black,
                            ),
                            //Block V===============================================
                            const SizedBox(
                              height: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {},
                                    child: const Text('Go Back')),
                                ElevatedButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.blueGrey),
                                    onPressed: () {
                                      for (int i = 0;
                                          i < textController.length;
                                          i++) {
                                        setState(() {
                                          textController[i].clear();
                                        });
                                      }
                                      setState(() {
                                        sex = null;
                                        mnts = null;
                                        nors = null;
                                        estw = null;
                                        zone = null;
                                      });
                                    },
                                    child: const Text('Clear')),
                                ElevatedButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.amber),
                                    onPressed: () {
                                      _validate();
                                    },
                                    child: const Text('Save')),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const Text('No DATA');
            }));
  }

  Widget dropDownMenu(String title, String inputTxt, List<String> stringList,
      int count, double wdth) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: paraBoldStyle,
          ),
          Container(
            width: wdth,
            height: 35,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.0),
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: DropdownButton<String>(
              style: paraBoldStyle,
              dropdownColor: Colors.amber,
              items: stringList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white),
                    ));
              }).toList(),
              onChanged: (String? value1) {
                setState(() {
                  inputTxt = value1!;
                  dropString[count] = value1;
                });
              },
              value: inputTxt,
            ),
          ),
        ],
      ),
    );
  }

  Future<int> _validate() async {
    var inpt = await _entryCheck();
    if (inpt == false) {
      setState(() {
        allOkay = false;
        _showSnackBar(errmsg[0]);
      });
      return 1;
    } else {
      var dte = await _dateCheck();
      if (dte == true) {
        var cord = await _cordCheck();
        if (cord == true) {
          showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopUpDialogue(context));
        }
      }
    }

    return 0;
  }

  Future<bool> _entryCheck() async {
    if (coord == 1) {
      textController[7].text = '0';
      textController[8].text = '0';
    } else if (coord == 0) {
      for (int i = 9; i < 16; i++) {
        textController[i].text = '0';
      }
    }
    for (int i = 0; i < textController.length; i++) {
      if (textController[i].text.isEmpty) {
        allOkay = false;
        return false;
      }
    }
    for (int j = 0; j < dropString.length; j++) {
      if (dropString[j].isEmpty) {
        return false;
      }
    }
    setState(() {});
    return true;
  }

  Future<bool> _dateCheck() async {
    if (int.parse(textController[2].text) > 31 ||
        int.parse(textController[3].text) < 1900 ||
        int.parse(textController[3].text) > DateTime.now().year ||
        int.parse(textController[4].text) > 23 ||
        int.parse(textController[5].text) > 60 ||
        int.parse(textController[6].text) > 60) {
      setState(() {
        allOkay = false;
        _showSnackBar(errmsg[1]);
      });
      return false;
    }

    var birthdte =
        ('${dropString[1]} ${textController[2].text}, ${textController[3].text}');

    DateFormat formatted = DateFormat('MMMM dd, yyyy');
    formDate = formatted.parse(birthdte);
    formDate = formDate!.add(Duration(
        hours: int.parse(textController[4].text),
        minutes: int.parse(textController[5].text),
        seconds: int.parse(textController[6].text)));
    if (formDate!.isAfter(DateTime.now())) {
      allOkay = false;
      _showSnackBar(errmsg[1]);
    }

    return true;
  }

  Future<bool> _cordCheck() async {
    if (coord == 1) {
      if (int.parse(textController[9].text) > 90 ||
          int.parse(textController[10].text) > 60 ||
          int.parse(textController[11].text) > 180 ||
          int.parse(textController[12].text) > 60) {
        allOkay = false;
        _showSnackBar(errmsg[2]);
        return false;
      }
    } else {
      if (double.parse(textController[7].text) > 90 ||
          double.parse(textController[8].text) > 180) {
        allOkay = false;
        _showSnackBar(errmsg[2]);
        return false;
      }
    }
    if (coord == 1) {
      var nmin = int.parse(textController[10].text);
      var emin = int.parse(textController[12].text);

      var lat = int.parse(textController[9].text) + nmin / 60;
      var lng = int.parse(textController[11].text) + emin / 60;
      if (dropString[3] == 'South') {
        lat = lat * -1;
      }
      if (dropString[4] == 'West') {
        lng = lng * -1;
      }
      latt = lat;
      lngg = lng;
    } else {
      var lat = double.parse(textController[7].text);
      var lng = double.parse(textController[8].text);
      if (dropString[3] == 'South') {
        lat = lat * -1;
      }
      if (dropString[4] == 'West') {
        lng = lng * -1;
      }
      latt = lat;
      lngg = lng;
    }
    return true;
  }

  _showSnackBar(String err) {
    final snackbar = SnackBar(
      content: Text(err),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Widget _buildPopUpDialogue(BuildContext context) {
    return AlertDialog(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            'Data Summary',
            style: titleStyleBlack,
          ),
        ),
        content: SizedBox(
          width: 300,
          height: 200,
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name : ',
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        'Sex : ',
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        'City : ',
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        'Birth Details:',
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        'Longitude:',
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        'Latitude',
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        'Time Zone:',
                        style: paraBoldStyleBlack,
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textController[0].text,
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        dropString[0],
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        textController[1].text,
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        '${dropString[1]} ${textController[2].text}, ${textController[3].text} ${textController[4].text}:${textController[5].text}:${textController[6].text}',
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        lngg!.toStringAsFixed(4),
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        latt!.toStringAsFixed(4),
                        style: paraBoldStyleBlack,
                      ),
                      Text(
                        '${dropString[2]} ${textController[13].text}: ${textController[14].text} GMT',
                        style: paraBoldStyleBlack,
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: paraBoldStyleBlack,
                      )),
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () async {
                        double timez = double.parse(textController[13].text) +
                            (double.parse(textController[14].text)) / 60;
                        Get.to(() => SwephData(
                              sizes: widget.sizes,
                              birthdate: formDate!,
                              latt: latt!,
                              long: lngg!,
                              timezone: timez,
                            ));
                      },
                      child: Text(
                        'Confirm',
                        style: paraBoldStyleBlack,
                      )),
                ],
              ),
            ],
          ),
        ));
  }
}
