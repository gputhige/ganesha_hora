import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:parashara_hora/screens/amsa_analysis.dart';
import 'package:parashara_hora/screens/basics_screen2.dart';
import 'package:parashara_hora/screens/graha_analysis.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/raasi.dart';
import '../models/users.dart';
import '../models/userdata.dart';
import '../screens/basics_screen.dart';
import '../screens/userlist.dart';
import '../utils/databasehelper.dart';
import '../screens/dasa_screen2.dart';
import '../utils/myfunctions.dart';

class ChartViewThree extends StatefulWidget {
  final Users user;
  final List<Map<String, Map<String, List<dynamic>>>> grahaData;
  const ChartViewThree({Key? key, required this.user, required this.grahaData})
      : super(key: key);

  @override
  State<ChartViewThree> createState() => _ChartViewThreeState();
}

class _ChartViewThreeState extends State<ChartViewThree> {
  final dbHelper = DatabaseHelper.db;
  double blockOne = 0, screenwd = 0, screenht = 0;
  Future? future;
  List<Map<String, Map<String, List<dynamic>>>> grahaData = [];
  bool arudaVisible = false;
  double moonloc = 0, sunloc = 0;
  int asc = 0, secondblock = 0;
  int ascMovement = 0,
      divMovement = 0,
      rasilord = 0,
      rasilordord = 0,
      rasilordIn = 0,
      dist = 0;

  double angle = -90 * math.pi / 180;
  List<double> radians = [];
  String divNumber = '';

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
    divNumber = 'D09';

    grahaData = widget.grahaData;
    ascMovement = grahaData[1]['D01']!['Rin']![0] + 1 ;

    if ((grahaData[2][divNumber]!['Deg']![0]) / 30 > 0) {
      divMovement = (grahaData[2][divNumber]!['Deg']![0]) ~/ 30 + 1;
    } else {
      (grahaData[2][divNumber]!['Deg']![0]) ~/ 30;
    }

    return 0;
  }

  _divChange(String divNo) {
    setState(() {
      divNumber = divNo;
      if ((grahaData[2][divNumber]!['Deg']![0]) / 30 > 0) {
        divMovement = (grahaData[2][divNumber]!['Deg']![0]) ~/ 30 + 1;
      } else {
        (grahaData[2][divNumber]!['Deg']![0]) ~/ 30;
      }
    });
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
                                      child: Text(divNumber,
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
                                                  90 +
                                                  2)) +
                                              (degreeToRadian(grahaData[1]
                                                      ['D01']!['Deg']![i] *
                                                  -1)) +
                                              6.25,
                                          260)
                                      .dy,
                                  left: Offset.fromDirection(
                                          (degreeToRadian(-15 +
                                                  (ascMovement * 30) -
                                                  90 +
                                                  2)) +
                                              (degreeToRadian(grahaData[1]
                                                      ['D01']!['Deg']![i] *
                                                  -1)) +
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
                              for (var i = 0; i < 12; i++)
                                arudaVisible == true
                                    ? Positioned(
                                        top: Offset.fromDirection(
                                                (degreeToRadian(-15 +
                                                        (ascMovement * 30) -
                                                        90)) +
                                                    (degreeToRadian(grahaData[3]
                                                                ['Ard']![
                                                            'D01']![i] *
                                                        -1)) +
                                                    6.25,
                                                223)
                                            .dy,
                                        left: Offset.fromDirection(
                                                (degreeToRadian(-15 +
                                                        (ascMovement * 30) -
                                                        90)) +
                                                    (degreeToRadian(grahaData[3]
                                                                ['Ard']![
                                                            'D01']![i] *
                                                        -1)) +
                                                    6.25,
                                                223)
                                            .dx,
                                        width: screenwd * .55,
                                        height: screenwd * .55,
                                        child: SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: Image.asset(
                                            'assets/planets/aruda$i.png',
                                            scale: 6.5,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              for (var i = 0; i < 10; i++)
                                Positioned(
                                  top: Offset.fromDirection(
                                          (degreeToRadian(-15 +
                                                  (divMovement * 30) -
                                                  90)) +
                                              (degreeToRadian(grahaData[2]
                                                      [divNumber]!['Deg']![i] *
                                                  -1)) +
                                              6.25,
                                          125)
                                      .dy,
                                  left: Offset.fromDirection(
                                          (degreeToRadian(-15 +
                                                  (divMovement * 30) -
                                                  90)) +
                                              (degreeToRadian(grahaData[2]
                                                      [divNumber]!['Deg']![i] *
                                                  -1)) +
                                              6.25,
                                          125)
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
                              for (var i = 0; i < 12; i++)
                                arudaVisible == true
                                    ? Positioned(
                                        top: Offset.fromDirection(
                                                (degreeToRadian(-15 +
                                                        (divMovement * 30) -
                                                        90)) +
                                                    (degreeToRadian(grahaData[3]
                                                                ['Ard']![
                                                            divNumber]![i] *
                                                        -1)) +
                                                    6.25,
                                                100)
                                            .dy,
                                        left: Offset.fromDirection(
                                                (degreeToRadian(-15 +
                                                        (divMovement * 30) -
                                                        90)) +
                                                    (degreeToRadian(grahaData[3]
                                                                ['Ard']![
                                                            divNumber]![i] *
                                                        -1)) +
                                                    6.25,
                                                100)
                                            .dx,
                                        width: screenwd * .55,
                                        height: screenwd * .55,
                                        child: SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: Image.asset(
                                            'assets/planets/aruda$i.png',
                                            scale: 8.5,
                                          ),
                                        ),
                                      )
                                    : Container(),
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
                          child: BasicsScreen2(
                              user: widget.user, grahadata: grahaData),
                          /*  child: BasicsScreen(
                            user: widget.user,
                            grahadata: grahaData,
                          ), */
                          //  child: BasicsScreen(user: UserData, planetPrg: [],)
                          /* secondblock == 3
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
                                          planetPrg: grahaData,
                                        )
                                      : GrahaAnalysis(
                                          planetPos: _planetPos,
                                          planetSpeed: _planetSpeed,
                                        ), */
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

//Menu Widget to show options
  void showSimpleDialogue(BuildContext context) => showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(0, 0, 0, .5),
      builder: (BuildContext context) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SimpleDialog(
                title: const Align(
                    alignment: Alignment.center, child: Text('Shodasa Varga')),
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
                              'D02',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D03');
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D03',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D03');
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D04',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                //divNumber = 'D09';
                                _divChange('D04');
                                // _divchart(9);
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D07',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                //divNumber = 'D09';
                                _divChange('D07');
                                // _divchart(9);
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D09',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                //divNumber = 'D09';
                                _divChange('D09');
                                // _divchart(9);
                                secondblock = 3;
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
                              'D10',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D10');
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D12',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D12');
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D16',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D16');
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D20',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D20');
                                secondblock = 3;
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
                                _divChange('D24');
                                secondblock = 3;
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
                              'D27',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D27');
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D30',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D30');
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D40',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D40');
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D45',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D45');
                                secondblock = 3;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'D60',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                _divChange('D60');
                                secondblock = 3;
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
                              'TRN',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                // _divchart(24);
                              });
                              Navigator.pop(context);
                            },
                          ),
                          SimpleDialogOption(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'ARD',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onPressed: () {
                              setState(() {
                                arudaVisible = !arudaVisible;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
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
}
