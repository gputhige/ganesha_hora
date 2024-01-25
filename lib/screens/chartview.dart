import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:parashara_hora/screens/basics_screen.dart';
import 'package:parashara_hora/screens/userlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweph/sweph.dart';

import 'dasa_screen.dart';
import 'dasa_screen2.dart';

class ChartView extends StatefulWidget {
  final List<double> housedata;
  final int ascendant;
  const ChartView({Key? key, required this.housedata, required this.ascendant})
      : super(key: key);

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  double blockOne = 0, screenwidth = 0, screenheight = 0, safearea = 0;
  Future? future;
  double moonloc = 0, sunloc = 0;
  int asc = 0;
  int ascMovement = 0;
  double angle = -90 * math.pi / 180;
  double screenwd = 0, screenht = 0;
  List<double> radians = [];
  final List _planetDegree = [
    90 - 90 - 15 + 64.24 * -1,
    90 - 90 - 15 + 230.11 * -1,
    90 - 90 - 15 + 76.27 * -1,
    90 - 90 - 15 + 213.30 * -1,
    90 - 90 - 15 + 270.98 * -1,
    90 - 90 - 15 + 83.48 * -1,
    90 - 90 - 15 + 254.77 * -1,
    90 - 90 - 15 + 263.31 * -1,
    90 - 90 - 15 + 137.45 * -1,
    90 - 90 - 15 + 317.45 * -1
  ];

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
    /*  screenheight = MediaQuery.of(context).size.height;
    screenwidth = MediaQuery.of(context).size.width;
    safearea = MediaQuery.of(context).viewPadding.top; */

    screenheight = screenht;
    safearea = 24;
    blockOne = screenht - safearea;
    await Sweph.init(
      epheAssets: [
        "packages/sweph/assets/ephe/sefstars.txt",
      ],
    );
    _planetDegree.clear();
    _planetDegree.addAll(widget.housedata);
    asc = widget.ascendant;
    //_getPlanetData();
    return 0;
  }

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
                                  angle: ((asc - 1) * 30) * math.pi / 180,
                                  child: SvgPicture.asset(
                                    'assets/charts/chart_one.svg',
                                    width: screenwd * .55,
                                    height: screenwd * .55,
                                  ),
                                ),
                              ),
                              Center(
                                child: SvgPicture.asset(
                                  'assets/charts/chart_two.svg',
                                ),
                              ),
                              Center(
                                child: SvgPicture.asset(
                                  'assets/charts/chart_four.svg',
                                ),
                              ),
                              Center(
                                child: Image.asset(
                                  'assets/planets/om.png',
                                  scale: 2,
                                ),
                              ),
                              for (var i = 0; i < 10; i++)
                                Positioned(
                                  top: Offset.fromDirection(
                                          (degreeToRadian(
                                                  -15 + (asc * 30) - 90)) +
                                              (degreeToRadian(
                                                  _planetDegree[i] * -1)) +
                                              6.25,
                                          240)
                                      .dy,
                                  left: Offset.fromDirection(
                                          (degreeToRadian(
                                                  -15 + (asc * 30) - 90)) +
                                              (degreeToRadian(
                                                  _planetDegree[i] * -1)) +
                                              6.25,
                                          240)
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
                              Positioned(
                                top: screenht * .84,
                                left: 10,
                                child: ElevatedButton(
                                  onPressed: () {},
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
                              Positioned(
                                top: screenht * .84,
                                left: screenwd * .5,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(() => UserList(
                                        sizes: [screenwd, screenht, safearea]));
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
                            ],
                          )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        //Second Block Area ======
                        SizedBox(
                          width: screenwd * .4,
                          height: screenwd * .55,
                          /*  child: DasaScreen(
                            moondegree: widget.housedata[2],
                          ), */
                          //child: BasicsScreen(user: widget.userd,),
                          /* DasaScreen2(
                            moondegree: widget.housedata[2],
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
}
