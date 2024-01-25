import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/models/nakshatra.dart';
import 'package:parashara_hora/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/grahas.dart';
import '../ui/theme.dart';
import '../utils/databasehelper.dart';

class DasaScreen2 extends StatefulWidget {
  //final List<double> sizes;
  final double moondegree;
  final Users user;
  const DasaScreen2({Key? key, required this.moondegree, required this.user})
      : super(key: key);

  @override
  State<DasaScreen2> createState() => _DasaScreen2State();
}

class _DasaScreen2State extends State<DasaScreen2> {
  final dbHelper = DatabaseHelper.db;
  Future? future;
  List<Grahas> grahas = [];
  List<Grahas> mahaGrahaList = [];
  List<Nakshatra> nakshatra = [];
  List<AllGrahaList> allGrahaList = [];
  double balyear = 0, screenht = 0, screenwd = 0;
  DateTime birthdate = DateTime.now();
  DateTime dasastartdate = DateTime.now();
  DateTime dasaEndDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = _future();
  }

  Future<int> _future() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    birthdate =
        DateFormat('yyyy-MM-dd HH:mm').parse(widget.user.birthdttm.toString());
    screenht = prefs.get('Height') as double;
    screenwd = prefs.get('Width') as double;

    grahas = await dbHelper.getGrahaSorted();
    nakshatra = await dbHelper.getNakLord(widget.moondegree);

    if (nakshatra.isNotEmpty) {
      var balYear = await getBalYear(
          nakshatra[0].lord!, nakshatra[0].degend!, widget.moondegree);

      if (balYear != 0) {
        //print(' $dasaEndDate $firstlord');
        // var graha = await _sortGrahas(firstlord, dasaEndDate);
        var mahadasa = await _mahaDasa(balYear);
        if (mahadasa == 0) {
          print('Enter Second Loop');
          var subdasas = await _subDasas();
          if (subdasas == 0) {
            print('Loop Complete');
          }
        }
      }
    }

    return 0;
  }

  //Calculating balance Dasa for the first year
  Future<int> getBalYear(String nakLord, double degend, double moondeg) async {
    final startGraha = grahas.firstWhere((element) => element.name == nakLord);
    print('Start Graha ${startGraha.dasaorder} ${startGraha.name}');
    balyear = degend - moondeg;

    int baldasa = (startGraha.dasayears! * balyear / 13.3333 * 365.25).ceil();
    int prevdasa =
        (startGraha.dasayears! * (13.3333 - balyear) / 13.3333 * 365.25).ceil();
    dasastartdate = birthdate.subtract(Duration(days: prevdasa));
    dasaEndDate = birthdate.add(Duration(days: baldasa));

    return startGraha.dasaorder!;
  }

  //Populating Maha Dasa
  Future<int> _mahaDasa(int startGraha) async {
    int mahastart = startGraha - 1;

    allGrahaList.clear();

    DateTime startingdate = dasastartdate;
    DateTime endingdate = dasaEndDate;

    for (int i = 0; i < 9; i++) {
      if (i > 0) {
        endingdate = startingdate.add(
            Duration(days: (grahas[i + mahastart].dasayears! * 365.25).ceil()));
      }
      //print('First Graha: ${grahas[startGraha].name}');
      allGrahaList.add(AllGrahaList(
          serial: i,
          grahaName: grahas[i + (mahastart)].name!,
          dasaYears: grahas[i + (mahastart)].dasayears!,
          dasaStart: _dateToString(startingdate),
          dasaEnd: _dateToString(endingdate)));

      startingdate = _stringToDate(allGrahaList[i].dasaEnd);
      // print('This Graha: $i ${allGrahaList[i].grahaName} $startGraha');

      if (i + mahastart == 8) {
        mahastart = mahastart - 9;
      }
    }

    return 0;
  }

//Populating Sub Dasa
  Future<int> _subDasas() async {
    DateTime startingdate = dasastartdate;
    DateTime endingdate = _stringToDate(allGrahaList[0].dasaEnd);
    int counter = allGrahaList.length;
    int dasaperiod = ((endingdate.difference(dasastartdate).inMinutes));

    for (int i = 0; i < 9; i++) {
      allGrahaList.add(AllGrahaList(
          serial: counter + i,
          grahaName: allGrahaList[i].grahaName,
          dasaYears: allGrahaList[i].dasaYears,
          dasaStart: _dateToString(startingdate),
          dasaEnd: _dateToString(startingdate.add(Duration(
              minutes:
                  (dasaperiod * allGrahaList[i].dasaYears / 120).ceil())))));

      startingdate = _stringToDate(allGrahaList[i + 9].dasaEnd);
    }
    startingdate = dasastartdate;
    endingdate = _stringToDate(allGrahaList[9].dasaEnd);
    counter = allGrahaList.length;
    dasaperiod = ((endingdate.difference(dasastartdate).inMinutes));

    for (int i = 0; i < 9; i++) {
      allGrahaList.add(AllGrahaList(
          serial: counter + i,
          grahaName: allGrahaList[i + 9].grahaName,
          dasaYears: allGrahaList[i + 9].dasaYears,
          dasaStart: _dateToString(startingdate),
          dasaEnd: _dateToString(startingdate.add(Duration(
              minutes: (dasaperiod * allGrahaList[i + 9].dasaYears / 120)
                  .ceil())))));

      startingdate = _stringToDate(allGrahaList[i + 18].dasaEnd);
    }

    return 0;
  }

  //Re-sort Subdasas and populate the list
  Future<int> _resortSubDasas2(int loopid, AllGrahaList balDasas) async {
    int startindex = 9, loopnumber = 18;
    List<Grahas> subGrahas = [];
    List<Grahas> tempGrahas = [];
    if (loopid == 1) {
      allGrahaList.removeRange(9, 27);
    } else {
      startindex = 18;
      loopnumber = 9;
      allGrahaList.removeRange(18, 27);
    }
    subGrahas = await dbHelper.getGrahaSorted();
    var index =
        subGrahas.indexWhere((element) => element.name == balDasas.grahaName);
    print('Index : $index');

    tempGrahas.addAll(grahas);
    tempGrahas.removeRange(index, 9);
    subGrahas.removeRange(0, index);
    subGrahas.addAll(tempGrahas);

    DateTime startingdate = _stringToDate(balDasas.dasaStart);
    DateTime endingdate = _stringToDate(balDasas.dasaEnd);
    int balMin = _convertDasas(startingdate, endingdate);

    int counter = 0;

    for (int i = 0; i < loopnumber; i++) {
      if (counter == 9) {
        startingdate = _stringToDate(allGrahaList[startindex].dasaStart);
        endingdate = _stringToDate(allGrahaList[startindex].dasaEnd);
        balMin = _convertDasas(startingdate, endingdate);
        counter = 0;
      }
      allGrahaList.add(AllGrahaList(
          serial: allGrahaList.last.serial + 1,
          grahaName: subGrahas[counter].name!,
          dasaYears: subGrahas[counter].dasayears!,
          dasaStart: _dateToString(startingdate),
          dasaEnd: _dateToString(startingdate.add(Duration(
              minutes: (balMin * grahas[counter].dasayears!).ceil())))));

      startingdate = _stringToDate(allGrahaList.last.dasaEnd);
      counter++;
    }

    return 0;
  }

  String _dateToString(DateTime indate) {
    var outdate = DateFormat('dd-MM-yyyy').format(indate);
    return outdate;
  }

  DateTime _stringToDate(String indate) {
    var outdate = DateFormat('dd-MM-yyyy').parse(indate);
    return outdate;
  }

  int _convertDasas(DateTime firstdate, DateTime seconddate) {
    //print('Start and End dates: $firstdate $seconddate');
    int diffMin = (((seconddate).difference(firstdate)).inMinutes);
    int diffdasa = (diffMin / 120).round();

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
                                    textBlock('Sno', 18),
                                    const SizedBox(
                                      width: 5,
                                    ),
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
                                            textBlock(
                                                allGrahaList[i]
                                                    .serial
                                                    .toString(),
                                                18),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  allGrahaList[i].grahaName,
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  allGrahaList[i]
                                                      .dasaYears
                                                      .toString(),
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  allGrahaList[i].dasaStart,
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  allGrahaList[i].dasaEnd, 18),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _resortSubDasas2(
                                                1, allGrahaList[i]);
                                            print(
                                                'Resort SubDasa: ${allGrahaList[i].grahaName}');
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                textBlock('Antar Dasa', 20),
                                for (int i = 9; i < allGrahaList.length; i++)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      i == 18
                                          ? textBlock('Pryatanthar Dasa', 20)
                                          : textBlock('', 0),
                                      GestureDetector(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            textBlock(
                                                allGrahaList[i]
                                                    .serial
                                                    .toString(),
                                                18),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  allGrahaList[i].grahaName,
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  allGrahaList[i]
                                                      .dasaYears
                                                      .toString(),
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  allGrahaList[i].dasaStart,
                                                  18),
                                            ),
                                            Expanded(
                                              child: textBlock(
                                                  allGrahaList[i].dasaEnd, 18),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _resortSubDasas2(
                                                18, allGrahaList[i]);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
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
      // style: paraBoldStyle,
      style: TextStyle(fontSize: fontsze, color: Colors.white),
    );
  }
}

class AllGrahaList {
  int serial;
  String grahaName;
  int dasaYears;
  String dasaStart;
  String dasaEnd;

  AllGrahaList(
      {required this.serial,
      required this.grahaName,
      required this.dasaYears,
      required this.dasaStart,
      required this.dasaEnd});
}
