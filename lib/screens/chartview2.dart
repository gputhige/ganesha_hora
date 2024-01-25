import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:parashara_hora/screens/amsa_analysis.dart';
import 'package:parashara_hora/screens/graha_analysis.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/raasi.dart';
import '../models/users.dart';
import '../models/userdata.dart';
import '../screens/basics_screen.dart';
import '../screens/userlist.dart';
import '../utils/databasehelper.dart';
import '../screens/dasa_screen2.dart';

class ChartViewTwo extends StatefulWidget {
  final Users user;
  const ChartViewTwo({Key? key, required this.user}) : super(key: key);

  @override
  State<ChartViewTwo> createState() => _ChartViewTwoState();
}

class _ChartViewTwoState extends State<ChartViewTwo> {
  final dbHelper = DatabaseHelper.db;
  double blockOne = 0, screenwd = 0, screenht = 0;
  Future? future;
  double moonloc = 0, sunloc = 0;
  int asc = 0, secondblock = 0;
  int ascMovement = 0, divMovement = 0;
  double angle = -90 * math.pi / 180;
  List<double> radians = [];
  final List<double> _planetPos = [], _planetSpeed = [];
  final List<int> _planetIn = [];
  List<double> divPos = [], _planetPrg = [];
  List<double> _transitPos = [], _transitSpeed = [];
  UserData? userdata;
  String chartno = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = _future();
  }

  Future<int> _future() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    screenwd = prefs.get('Width') as double;
    screenht = prefs.get('Height') as double;
    blockOne = screenht;

    String planetPos = widget.user.planetpos.toString();
    String planetSpd = widget.user.planetspeed.toString();
    String transitPos = widget.user.transitpos.toString();
    String transitSpd = widget.user.transitspeed.toString();

    _planetPos.clear();
    _planetSpeed.clear();
    _transitPos.clear();
    _transitSpeed.clear();

    //update Planet/Transit Data
    for (int i = 0; i < 10; i++) {
      double _ppos = double.parse(planetPos.split(",")[i]);
      double _pspd = double.parse(planetSpd.split(",")[i]);
      double _tpos = double.parse(transitPos.split(",")[i]);
      double _tspd = double.parse(transitSpd.split(",")[i]);

      _planetPos.add(_ppos);
      _planetSpeed.add(_pspd);
      _transitPos.add(_tpos);
      _transitSpeed.add(_tspd);
      _planetIn.add(((_ppos ~/ 30).ceil()));
      _planetPrg.add((_planetPos[i] - (_planetIn[i] * 30)));
    }

    userdata = UserData(
        name: widget.user.name,
        sex: widget.user.sex,
        birthlong: widget.user.birthlong,
        birthlat: widget.user.birthlat,
        birthsunrise: widget.user.birthsunrise!,
        birthsunset: widget.user.birthsunset!,
        description: widget.user.description,
        birthdttm: widget.user.birthdttm,
        planetpos: _planetPos,
        planetspeed: _planetSpeed,
        transitpos: _transitPos,
        transitspeed: _transitSpeed);

    //Get Chart rotation degree from asc;
    if (_planetPos[0] / 30 > 0) {
      ascMovement = (_planetPos[0] ~/ 30) + 1;
    } else {
      ascMovement = (_planetPos[0] ~/ 30);
    }

    //Calculate Div Charts;
    var res = await _divchart(10);
    if (res != 0) {}

    return 0;
  }

//Degree To Radian
  double degreeToRadian(double degree) {
    return degree * math.pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    /*  double width1 = MediaQuery.of(context).size.width;
    double height1 = MediaQuery.of(context).size.height; */
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
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
                return SafeArea(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.amber,
                          width: screenwd * .55,
                          height: screenwd * .55,
                          child: Center(
                              child: Stack(
                            children: [
                              Center(
                                child: Transform.rotate(
                                  angle:
                                      ((ascMovement - 1) * 30) * math.pi / 180,
                                  child: SvgPicture.asset(
                                    'assets/charts/chart_v2_one.svg',
                                    width: screenwd * .55,
                                    height: screenwd * .55,
                                  ),
                                  /* child: SvgPicture.asset(
                                    'assets/charts/chart_one.svg',
                                    width: screenwd * .55,
                                    height: screenwd * .55,
                                  ), */
                                ),
                              ),
                              Center(
                                child: SvgPicture.asset(
                                  'assets/charts/chart_v2_two.svg',
                                  width: screenwd * .38,
                                  height: screenwd * .38,
                                ),
                              ),
                              Center(
                                child: Transform.rotate(
                                  angle:
                                      ((divMovement - 1) * 30) * math.pi / 180,
                                  child: SvgPicture.asset(
                                    'assets/charts/chart_v2_three.svg',
                                    width: screenwd * .25,
                                    height: screenwd * .25,
                                  ),
                                ),
                              ),
                              Center(
                                child: Image.asset(
                                  'assets/planets/om.png',
                                  scale: 2,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                /* child: Text(
                                  chartno,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ), */
                                width: screenwd * .55,
                                height: screenwd * .62,
                                child: TextButton(
                                  child: Container(
                                    width: 30,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(3))),
                                    child: Center(
                                      child: Text(chartno,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall),
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              for (var i = 0; i < 10; i++)
                                Positioned(
                                  top: Offset.fromDirection(
                                          (degreeToRadian(-15 +
                                                  (ascMovement * 30) -
                                                  90)) +
                                              (degreeToRadian(
                                                  _planetPos[i] * -1)) +
                                              6.25,
                                          260)
                                      .dy,
                                  left: Offset.fromDirection(
                                          (degreeToRadian(-15 +
                                                  (ascMovement * 30) -
                                                  90)) +
                                              (degreeToRadian(
                                                  _planetPos[i] * -1)) +
                                              6.25,
                                          260)
                                      .dx,
                                  width: screenwd * .55,
                                  height: screenwd * .55,
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: Image.asset(
                                      'assets/planets/planet_$i.png',
                                      scale: 3.5,
                                    ),
                                  ),
                                ),
                              for (var i = 0; i < 10; i++)
                                Positioned(
                                  top: Offset.fromDirection(
                                          (degreeToRadian(-15 +
                                                  (divMovement * 30) -
                                                  90)) +
                                              (degreeToRadian(divPos[i] * -1)) +
                                              6.25,
                                          120)
                                      .dy,
                                  left: Offset.fromDirection(
                                          (degreeToRadian(-15 +
                                                  (divMovement * 30) -
                                                  90)) +
                                              (degreeToRadian(divPos[i] * -1)) +
                                              6.25,
                                          120)
                                      .dx,
                                  width: screenwd * .55,
                                  height: screenwd * .55,
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: Image.asset(
                                      'assets/planets/planet_$i.png',
                                      scale: 4,
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: screenht * .84,
                                left: 10,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      Get.to(() => UserList(
                                          sizes: [screenwd, screenht]));
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    // styling the button
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(5),
                                    backgroundColor:
                                        Colors.white, // Button color
                                    foregroundColor:
                                        Colors.cyan, // Splash color
                                  ),
                                  child: const Icon(
                                    Icons.home,
                                    size: 40,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: screenht * .84,
                                left: screenwd * .5,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showSimpleDialogue(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    // styling the button
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(5),
                                    backgroundColor:
                                        Colors.white, // Button color
                                    foregroundColor:
                                        Colors.cyan, // Splash color
                                  ),
                                  child: const Icon(
                                    Icons.menu,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        //Second Block Area ==================================
                        SizedBox(
                          width: screenwd * .4,
                          height: screenwd * .55,
                          child: secondblock == 3
                              ? AmsaAnalysis(
                                  planetPos: divPos,
                                  planetSpeed: _planetSpeed,
                                  amsaNumber: chartno,
                                )
                              : secondblock == 1
                                  ? DasaScreen2(
                                      moondegree: _planetPos[2],
                                      user: widget.user,
                                    )
                                  : secondblock == 0
                                      ? BasicsScreen(
                                          user: userdata!,
                                          planetPrg: _planetPrg,
                                        )
                                      : GrahaAnalysis(
                                          planetPos: _planetPos,
                                          planetSpeed: _planetSpeed,
                                        ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return Container();
          }),
    );
  }

  Future<int> _divchart(int number) async {
    divPos.clear();
    if (number == 9) {
      setState(() {
        chartno = 'D09';
      });
      for (int i = 0; i < 10; i++) {
        var newpos = 0;
        if (_planetIn[i] == 0 || _planetIn[i] == 4 || _planetIn[i] == 8) {
          for (int j = 0; j < 11; j++) {
            if (_planetPrg[i] < j * (30 / 9)) {
              newpos = j + 0 - 1;
              if (newpos > 12) newpos = newpos - 12;
              divPos.add(newpos.toDouble() * 30);
              break;
            }
          }
        } else if (_planetIn[i] == 1 ||
            _planetIn[i] == 5 ||
            _planetIn[i] == 9) {
          for (int j = 0; j < 11; j++) {
            if (_planetPrg[i] < j * (30 / 9)) {
              newpos = j + 9 - 1;
              if (newpos > 12) newpos = newpos - 12;
              divPos.add(newpos.toDouble() * 30);
              break;
            }
          }
        } else if (_planetIn[i] == 2 ||
            _planetIn[i] == 6 ||
            _planetIn[i] == 10) {
          for (int j = 0; j < 11; j++) {
            if (_planetPrg[i] < j * (30 / 9)) {
              newpos = j + 6 - 1;
              if (newpos > 12) newpos = newpos - 12;
              divPos.add(newpos.toDouble() * 30);
              print(
                  'Planet: $i  In Navamsa:  $j Progress ${_planetPrg[i]} Planet Pos: ${_planetIn[i]} ');
              break;
            }
          }
        } else if (_planetIn[i] == 3 ||
            _planetIn[i] == 7 ||
            _planetIn[i] == 11) {
          for (int j = 0; j < 11; j++) {
            if (_planetPrg[i] < j * (30 / 9)) {
              newpos = j + 3 - 1;
              if (newpos > 12) newpos = newpos - 12;
              divPos.add(newpos.toDouble() * 30);
              print(
                  'Planet: $i  In Navamsa:  $j Progress ${_planetPrg[i]} Planet Pos: ${_planetIn[i]} ');
              break;
            }
          }
        }
      }
    } else if (number == 10) {
      setState(() {
        chartno = 'D10';
      });
      for (int i = 0; i < 10; i++) {
        int signIn = _planetPos[i] ~/ 30.ceil();
        double planetAdv = _planetPos[i] - (signIn * 30);
        int newDeg = 0;
        if ((signIn + 1).isEven) {
          newDeg = (planetAdv ~/ 3);
          newDeg = await _reduceRasi((newDeg + signIn + 9 - 1));
          divPos.add(newDeg.toDouble() * 30);
        } else {
          newDeg = (planetAdv ~/ 3);
          newDeg = await _reduceRasi(newDeg + signIn);
          divPos.add(newDeg.toDouble() * 30);
        }
      }
    } else if (number == 24) {
      setState(() {
        chartno = 'D24';
      });
      double counter = 0;
      //Divide each Rasi into 24 parts and calculate new position
      for (int i = 0; i < 10; i++) {
        if ((_planetPos[i] / 30).ceil().isEven) {
          var newpos = 0;
          var newdeg = (_planetPos[i] - ((_planetPos[i] ~/ 30) * 30));
          for (int j = 0; j < 24; j++) {
            if (newdeg < ((j) * 1.25)) {
              newpos = j + 4 - 2;
              if (newpos > 12) {
                newpos = newpos - 12;
              }
              divPos.add(newpos.toDouble() * 30);
              break;
            }
          }
        } else {
          var newdeg = (_planetPos[i] - ((_planetPos[i] ~/ 30) * 30));
          var newpos = 0;
          for (int j = 0; j < 24; j++) {
            if (newdeg < ((j) * 1.25)) {
              newpos = j + 5 - 2;
              if (newpos > 12) {
                newpos = newpos - 12;
              }
              divPos.add(newpos.toDouble() * 30);
              break;
            }
          }
        }
        counter = counter + 3;
      }
    }

//Summarize number of planets in one Rasi - to space them within the Rasi
    var counts = divPos.fold<Map<dynamic, int>>({}, (map, element) {
      map[element] = (map[element] ?? 0) + 1;
      return map;
    });

    var entries = counts.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      int counter = 1;
      for (int p = 0; p < entries[i].value; p++) {
        for (int j = 0; j < divPos.length; j++) {
          if (divPos[j] == entries[i].key) {
            divPos[j] = divPos[j] + (30 / ((entries[i].value + 1)) * counter);

            counter = counter + 1;
          }
        }
      }
      counter = 1;
    }

    if (divPos[0] / 30 > 0) {
      divMovement = (divPos[0] ~/ 30) + 1;
    } else {
      divMovement = (divPos[0] ~/ 30);
    }
    return 0;
  }

//Menu Widget to show options
  void showSimpleDialogue(BuildContext context) => showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(0, 0, 0, .5),
      builder: (BuildContext context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SimpleDialog(
                title: const Align(
                    alignment: Alignment.center, child: Text('Select an Amsa')),
                backgroundColor: Colors.blue,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SimpleDialogOption(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'D09',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onPressed: () {
                          setState(() {
                            _divchart(9);
                          });
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'D10',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onPressed: () {
                          setState(() {
                            _divchart(10);
                          });
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'D24',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onPressed: () {
                          setState(() {
                            _divchart(24);
                          });
                          Navigator.pop(context);
                        },
                      ),
                      SimpleDialogOption(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Transit',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        onPressed: () {
                          setState(() {
                            // _divchart(24);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                ],
              ),
              SimpleDialog(
                title: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Select Info',
                  ),
                ),
                backgroundColor: Colors.blue,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Basic Data',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                secondblock = 0;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Dasa Data',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                secondblock = 1;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Graha Analysis',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                secondblock = 2;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Amsa Analysis',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ));

  Future<int> _reduceRasi(int rasi) async {
    while (rasi > 12) {
      rasi = rasi - 12;
    }
    return rasi;
  }
}
