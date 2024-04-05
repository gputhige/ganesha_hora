import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/ui/myDropDownWidget.dart';
import 'package:parashara_hora/ui/myTextInputWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/text_input_widget.dart';
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
  String selectedTime = DateFormat('hh:mm a').format(DateTime.now());
  int coord = 1;
  List<String> listsex = <String>['Male', 'Female'];
  List<String> listns = <String>['North', 'South'];
  List<String> listew = ['East', 'West'];
  List<String> listzne = ['+ Pstv', '- Ngtv'];
  List<String> errmsg = [
    'Incomplete Text/Dropdown Fields',
    'Incorrect Date/Time Entered',
    'Incorrect Coordinates'
  ];
  List<String> listmnths = [
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

  String? sex, mnts, nors, estw, zone;
  bool allOkay = true;

  @override
  void initState() {
    // TODO: implement initState
    future = _future();
    super.initState();
  }

  Future<int> _future() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    screenwd = widget.sizes[0];
    screenht = widget.sizes[1];
    for (int i = 0; i < 17; i++) {
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
                      height: screenht * .65,
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
                                  'Personal Details',
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
                                Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sex',
                                        style: paraBoldStyle,
                                      ),
                                      Container(
                                        width: 100,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1.0),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5.0))),
                                        child: DropdownButton<String>(
                                            value: sex,
                                            dropdownColor: Colors.amber,
                                            items: listsex
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ));
                                            }).toList(),
                                            onChanged: (String? value) {
                                              setState(() {
                                                sex = value!;
                                              });
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                MyTextInputWidget(
                                  title: 'Location',
                                  hint: 'Bangalore',
                                  textStyle: paraBoldStyle,
                                  textInputType: TextInputType.name,
                                  textCapital: TextCapitalization.words,
                                  controller: textController[1],
                                  containerWidth: 200,
                                ),
                                const Spacer(),
                                ElevatedButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {
                                      String url =
                                          'https://www.timeanddate.com/worldclock/india/${textController[1].text}';
                                      final _url = Uri.parse(url);
                                      print(url);
                                      /* if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) { // <--
    throw Exception('Could not launch $_url');
  } */
                                    },
                                    child: Text(
                                      'Get Coord',
                                      style: paraBoldStyle,
                                    )),
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
                                    Container(
                                      margin: const EdgeInsets.only(top: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Month',
                                            style: paraBoldStyle,
                                          ),
                                          Container(
                                            width: 100,
                                            height: 35,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 1.0),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(5.0))),
                                            child: DropdownButton<String>(
                                                value: mnts,
                                                dropdownColor: Colors.amber,
                                                items: listmnths.map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                          String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ));
                                                }).toList(),
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    mnts = value!;
                                                  });
                                                }),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  'Time Zone:',
                                  style: titleStyleBlack,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '+ or - GMT',
                                        style: paraBoldStyle,
                                      ),
                                      Container(
                                        width: 80,
                                        height: 35,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white,
                                                width: 1.0),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5.0))),
                                        child: DropdownButton<String>(
                                            value: zone,
                                            dropdownColor: Colors.amber,
                                            items: listzne
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ));
                                            }).toList(),
                                            onChanged: (String? value) {
                                              setState(() {
                                                zone = value!;
                                              });
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                MyTextInputWidget(
                                  title: 'Hrs',
                                  hint: '5',
                                  textStyle: paraBoldStyle,
                                  textInputType: TextInputType.number,
                                  textCapital: TextCapitalization.words,
                                  controller: textController[15],
                                  containerWidth: 36,
                                ),
                                const Text(' : '),
                                MyTextInputWidget(
                                  title: 'Mins',
                                  hint: '30',
                                  textStyle: paraBoldStyle,
                                  textInputType: TextInputType.number,
                                  textCapital: TextCapitalization.words,
                                  controller: textController[16],
                                  containerWidth: 36,
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
                                    )),
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
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'North/South',
                                                  style: paraBoldStyle,
                                                ),
                                                Container(
                                                  width: 80,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 1.0),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  child: DropdownButton<String>(
                                                      value: nors,
                                                      dropdownColor:
                                                          Colors.amber,
                                                      items: listns.map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                                String>(
                                                            value: value,
                                                            child: Text(
                                                              value,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ));
                                                      }).toList(),
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          nors = value!;
                                                        });
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'East/West',
                                              style: paraBoldStyle,
                                            ),
                                            Container(
                                              width: 80,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: DropdownButton<String>(
                                                  value: estw,
                                                  dropdownColor: Colors.amber,
                                                  items: listew.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                            String>(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ));
                                                  }).toList(),
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      estw = value!;
                                                    });
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
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
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'North/South',
                                                  style: paraBoldStyle,
                                                ),
                                                Container(
                                                  width: 80,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 1.0),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  5.0))),
                                                  child: DropdownButton<String>(
                                                      value: nors,
                                                      dropdownColor:
                                                          Colors.amber,
                                                      items: listns.map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                                String>(
                                                            value: value,
                                                            child: Text(
                                                              value,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ));
                                                      }).toList(),
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          nors = value!;
                                                        });
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                          const Text(' : '),
                                          MyTextInputWidget(
                                            title: 'Secs',
                                            hint: '30',
                                            textStyle: paraBoldStyle,
                                            textInputType: TextInputType.number,
                                            textCapital:
                                                TextCapitalization.words,
                                            controller: textController[11],
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
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'East/West',
                                              style: paraBoldStyle,
                                            ),
                                            Container(
                                              width: 80,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              5.0))),
                                              child: DropdownButton<String>(
                                                  value: estw,
                                                  dropdownColor: Colors.amber,
                                                  items: listew.map<
                                                          DropdownMenuItem<
                                                              String>>(
                                                      (String value) {
                                                    return DropdownMenuItem<
                                                            String>(
                                                        value: value,
                                                        child: Text(
                                                          value,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ));
                                                  }).toList(),
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      estw = value!;
                                                    });
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      MyTextInputWidget(
                                        title: 'Deg',
                                        hint: '80',
                                        textStyle: paraBoldStyle,
                                        textInputType: TextInputType.number,
                                        textCapital: TextCapitalization.words,
                                        controller: textController[12],
                                        containerWidth: 40,
                                      ),
                                      const Text(' : '),
                                      MyTextInputWidget(
                                        title: 'Mins',
                                        hint: '30',
                                        textStyle: paraBoldStyle,
                                        textInputType: TextInputType.number,
                                        textCapital: TextCapitalization.words,
                                        controller: textController[13],
                                        containerWidth: 40,
                                      ),
                                      const Text(' : '),
                                      MyTextInputWidget(
                                        title: 'Secs',
                                        hint: '30',
                                        textStyle: paraBoldStyle,
                                        textInputType: TextInputType.number,
                                        textCapital: TextCapitalization.words,
                                        controller: textController[14],
                                        containerWidth: 40,
                                      ),
                                      const Spacer(),
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
              return Container(child: Text('No DATA'));
            }));
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
          print('All Okay');
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
      for (int i = 9; i < 15; i++) {
        textController[i].text = '0';
      }
    }
    for (int i = 0; i < textController.length; i++) {
      if (textController[i].text.isEmpty) {
        allOkay = false;
        return false;
      }
    }

    if (sex == null ||
        mnts == null ||
        nors == null ||
        estw == null ||
        zone == null) {
      return false;
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
        ('${mnts!} ${textController[2].text}, ${textController[3].text}');

    DateFormat formatted = DateFormat('MMMM dd, yyyy');
    var formDate = formatted.parse(birthdte);
    formDate = formDate.add(Duration(
        hours: int.parse(textController[4].text),
        minutes: int.parse(textController[5].text),
        seconds: int.parse(textController[6].text)));

    if (formDate.isAfter(DateTime.now())) {
      allOkay = false;
      _showSnackBar(errmsg[1]);
    }

    return true;
  }

  Future<bool> _cordCheck() async {
    if (coord == 1) {
      if (int.parse(textController[9].text) > 90 ||
          int.parse(textController[10].text) > 60 ||
          int.parse(textController[11].text) > 60 ||
          int.parse(textController[12].text) > 180 ||
          int.parse(textController[13].text) > 60 ||
          int.parse(textController[14].text) > 60) {
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
      var nsec = int.parse(textController[11].text);
      var emin = int.parse(textController[13].text);
      var esec = int.parse(textController[14].text);
      var lat = int.parse(textController[9].text) + nmin / 60 + nsec / 3600;
      var lng = int.parse(textController[12].text) + emin / 60 + esec / 3600;
      print('$lat $lng');
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
}
