import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/models/nakshatra.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grahas.dart';
import '../utils/databasehelper.dart';

class DasaScreen extends StatefulWidget {
  //final List<double> sizes;
  final double moondegree;
  const DasaScreen({Key? key, required this.moondegree}) : super(key: key);

  @override
  State<DasaScreen> createState() => _DasaScreenState();
}

class _DasaScreenState extends State<DasaScreen> {
  final dbHelper = DatabaseHelper.db;
  Future? future;
  List<Grahas> grahas = [];
  List<Nakshatra> nakshatra = [];
  List<Grahas> firstGrahaList = [];
  List<Grahas> secondGrahaList = [];
  List<Grahas> thirdGrahaList = [];
  int selectedIndex = -1;
  double balyear = 0, screenht = 0, screenwd = 0;
  DateTime birthdate = DateTime.now();
  DateTime dasaDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = _future();
  }

  Future<int> _future() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    birthdate =
        DateFormat('yyyy-MM-dd HH:mm').parse(prefs.get('BirthDate').toString());
    screenht = prefs.get('Height') as double;
    screenwd = prefs.get('Width') as double;

    grahas = await dbHelper.getGraha();
    nakshatra = await dbHelper.getNakLord(widget.moondegree);

    if (nakshatra.isNotEmpty) {
      var firstlord = await getBalYear(
          nakshatra[0].lord!, nakshatra[0].degend!, widget.moondegree);

      if (firstlord != 0) {
        var graha = await _sortGrahas(firstlord, dasaDate);
        if (graha == 0) {
          var second =
              await _firstDasaSecondLoop(0, firstGrahaList[0].dasayears!);
          if (second == 1) {
            var third = await _seconddDasaSecondLoop(
                graha, firstGrahaList[0].dasayears!);
          }
        }
      }
    }

    return 0;
  }

  //Calculating balance Dasa for the first year
  Future<int> getBalYear(String nakLord, double degend, double moondeg) async {
    balyear = degend - moondeg;
    int baldasa = 0;
    int firstyear = 0;
    int firstlord = 0;
    for (int i = 0; i < grahas.length; i++) {
      if (nakLord == grahas[i].name) {
        firstyear = grahas[i].dasayears!;
        firstlord = grahas[i].dasaorder!;
        break;
      }
    }
    baldasa = (firstyear * balyear / 13.3333 * 365.25).ceil();

    dasaDate = DateTime(
        birthdate.year, birthdate.month, birthdate.day + baldasa.toInt());

    return firstlord;
  }

  //Sorting the Grahas and filling in Dasa Periods
  Future<int> _sortGrahas(int firstlord, DateTime dasaDate) async {
    List<Grahas> balgrahas = [];
    balgrahas.clear();
    firstGrahaList.clear();

    for (int i = 0; i < grahas.length; i++) {
      if (i < firstlord - 1) {
        balgrahas.add(grahas[i]);
      } else if (i > (firstlord - 2)) {
        firstGrahaList.add(grahas[i]);
      }
    }
    firstGrahaList.addAll(balgrahas);
    //First Dasa Period

    firstGrahaList[0].fillerone = _dateToString(birthdate);
    firstGrahaList[0].fillertwo = _dateToString(dasaDate);
    //Subsequent Dasa Periods
    for (int i = 1; i < firstGrahaList.length; i++) {
      firstGrahaList[i].fillerone = DateFormat('dd-MM-yyyy').format(dasaDate);
      dasaDate = DateTime(dasaDate.year + firstGrahaList[i].dasayears!,
          dasaDate.month, dasaDate.day);
      firstGrahaList[i].fillertwo = _dateToString(dasaDate);
    }

    return 0;
  }

  Future<int> _firstDasaSecondLoop(int graha, int dasayear) async {
    secondGrahaList.clear();
    DateTime startdate = DateTime(0);
    int origgraha = graha;

    if (graha == 0) {
      startdate = birthdate.subtract(Duration(
          days: ((13.3333 - balyear) /
                  13.3333 *
                  firstGrahaList[0].dasayears! *
                  365.25)
              .round()));

      for (int i = 0; i < firstGrahaList.length; i++) {
        secondGrahaList.add(Grahas());
        secondGrahaList[i].name = firstGrahaList[i].name;
        secondGrahaList[i].dasayears = firstGrahaList[i].dasayears;
        secondGrahaList[i].fillerone = _dateToString(startdate);
        secondGrahaList[i].fillertwo = _dateToString(startdate.add(Duration(
            days: (365.25 * dasayear * firstGrahaList[i].dasayears! / 120)
                .round())));
        startdate =
            DateFormat('dd-MM-yyyy').parse(secondGrahaList[i].fillertwo!);
      }
    } else {
      startdate =
          DateFormat('dd-MM-yyyy').parse(firstGrahaList[graha].fillerone!);
      for (int i = 0; i < firstGrahaList.length; i++) {
        if (i == firstGrahaList.length - graha) {
          graha = graha - 9;
        }
        secondGrahaList.add(Grahas());
        secondGrahaList[i].name = firstGrahaList[i + graha].name;
        secondGrahaList[i].dasayears = firstGrahaList[i + graha].dasayears;
        secondGrahaList[i].fillerone = _dateToString(startdate);
        secondGrahaList[i].fillertwo = _dateToString(startdate.add(Duration(
            days:
                (365.25 * dasayear * firstGrahaList[i + graha].dasayears! / 120)
                    .round())));
        startdate =
            DateFormat('dd-MM-yyyy').parse(secondGrahaList[i].fillertwo!);
      }
    }

    if (origgraha > 0) {
      print(origgraha);
      _seconddDasaSecondLoop(1, dasayear);
    }

    return 1;
  }

  _seconddDasaSecondLoop(int graha, int dasayear) {
    thirdGrahaList.clear();
    DateTime startdate = DateTime(0);

    if (graha == 0) {
      startdate = birthdate.subtract(Duration(
          days: ((13.3333 - balyear) /
                  13.3333 *
                  firstGrahaList[0].dasayears! *
                  365.25)
              .round()));
      int diffdasa = _convertDasas(
          secondGrahaList[0].fillerone!, secondGrahaList[0].fillertwo!);
      for (int i = 0; i < firstGrahaList.length; i++) {
        thirdGrahaList.add(Grahas());
        thirdGrahaList[i].name = firstGrahaList[i].name;
        thirdGrahaList[i].dasayears = firstGrahaList[i].dasayears;
        thirdGrahaList[i].fillerone = _dateToString(startdate);
        thirdGrahaList[i].fillertwo = _dateToString((startdate
            .add(Duration(hours: (diffdasa * firstGrahaList[i].dasayears!)))));

        startdate =
            DateFormat('dd-MM-yyyy').parse(thirdGrahaList[i].fillertwo!);
      }
    } else {
      startdate =
          DateFormat('dd-MM-yyyy').parse(firstGrahaList[graha].fillerone!);
      int diffdasa = _convertDasas(
        secondGrahaList[0 + graha].fillerone!,
        secondGrahaList[0 + graha].fillertwo!,
      );
      for (int i = 0; i < firstGrahaList.length; i++) {
        if (i == firstGrahaList.length - graha) {
          graha = graha - 9;
        }

        thirdGrahaList.add(Grahas());
        thirdGrahaList[i].name = firstGrahaList[i + graha].name;
        thirdGrahaList[i].dasayears = firstGrahaList[i + graha].dasayears;
        thirdGrahaList[i].fillerone = _dateToString(startdate);
        thirdGrahaList[i].fillertwo =
            _dateToString((startdate.add(Duration(days: diffdasa))));
        startdate =
            DateFormat('dd-MM-yyyy').parse(thirdGrahaList[i].fillertwo!);
      }
    }
  }

  String _dateToString(DateTime indate) {
    var outdate = DateFormat('dd-MM-yyyy').format(indate);
    return outdate;
  }

  DateTime _stringToDate(String indate) {
    var outdate = DateFormat('dd-MM-yyyy').parse(indate);
    return outdate;
  }

  int _convertDasas(String firstdate, String seconddate) {
    print('Start and End dates: $firstdate $seconddate');
    int diffhours =
        (((_stringToDate(seconddate)).difference(_stringToDate(firstdate)))
            .inHours);

    int diffdasa = (diffhours / 120).round();

    return diffdasa;
  }

  @override
  Widget build(BuildContext context) {
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
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
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
                  return Container(
                      color: Colors.brown,
                      width: screenwd * .4,
                      height: screenht,
                      //height: widget.sizes[1],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          children: [
                            Column(
                              children: [
                                textBlock('Maha Dasa', 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(child: textBlock('Graha', 18)),
                                    Expanded(child: textBlock('Years', 18)),
                                    Expanded(child: textBlock('From', 18)),
                                    Expanded(child: textBlock('To', 18)),
                                  ],
                                ),
                                for (int i = 0; i < grahas.length; i++)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: textBlock(
                                                  firstGrahaList[i].name!, 18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  firstGrahaList[i]
                                                      .dasayears
                                                      .toString(),
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  firstGrahaList[i].fillerone!,
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  firstGrahaList[i].fillertwo!,
                                                  18),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _firstDasaSecondLoop(i,
                                                firstGrahaList[i].dasayears!);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                textBlock('Antardasa', 20),
                                for (int i = 0; i < grahas.length; i++)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: textBlock(
                                                  secondGrahaList[i].name!, 18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  secondGrahaList[i]
                                                      .dasayears
                                                      .toString(),
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  secondGrahaList[i].fillerone!,
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  secondGrahaList[i].fillertwo!,
                                                  18),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          /*  setState(() {
                                            print('Tapped $i');
                                          }); */
                                        },
                                      ),
                                    ],
                                  ),
                                textBlock('Pratyantardasa', 20),
                                for (int i = 0; i < grahas.length; i++)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: textBlock(
                                                  thirdGrahaList[i].name!, 18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  thirdGrahaList[i]
                                                      .dasayears
                                                      .toString(),
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  thirdGrahaList[i].fillerone!,
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  thirdGrahaList[i].fillertwo!,
                                                  18),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            )
                          ],
                        ),
                      ));
                }
              }
              return Container();
            }));
  }

  Widget textBlock(String text, double fontsze) {
    return Text(
      text,
      style: TextStyle(fontSize: fontsze, color: Colors.white),
    );
  }
}
