import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:parashara_hora/models/nakshatra.dart';
import 'package:parashara_hora/models/raasi.dart';
import 'package:parashara_hora/ui/theme.dart';
import 'package:parashara_hora/utils/databasehelper.dart';

import '../models/grahas.dart';

class GrahaAnalysis extends StatefulWidget {
  final List<dynamic> planetPos;
  final List<dynamic> planetSpeed;
  const GrahaAnalysis(
      {Key? key, required this.planetPos, required this.planetSpeed})
      : super(key: key);

  @override
  State<GrahaAnalysis> createState() => _GrahaAnalysisState();
}

class _GrahaAnalysisState extends State<GrahaAnalysis> {
  final dbHelper = DatabaseHelper.db;
  Future? future;
  List<Grahas> dasagraha = [];
  List<Raasi> raasi = [];
  List<Nakshatra> nak = [];
  List<double> planetPos = [], planetSpeed = [];
  double asc = 0;
  Map<String, List<dynamic>> grahaDetails = {};
  Map<String, List<dynamic>> bhavaDetails = {};
  List<Map<String, List<dynamic>>> grahaDignity = [];
  List<Map<String, List<String>>> fixedRelMap = [];
  List<Map<String, List<String>>> allRelMap = [];
  List<Map<String, List<String>>> allAspMap = [];
  List<String> grahaList = [
    'Ra',
    'Ch',
    'Bu',
    'Sk',
    'Kj',
    'Gu',
    'Sh',
    'Rh',
    'Ke'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = _future();
  }

  Future<int> _future() async {
    dasagraha = await dbHelper.getGraha();
    raasi = await dbHelper.getRaasiList();
    nak = await dbHelper.getNakList();

    planetPos.addAll(widget.planetPos as Iterable<double>);
    planetSpeed.addAll(widget.planetSpeed as Iterable<double>);
    print('Graha Details');
    var res1 = await _getGrahaDetails();
    if (res1 == 1) {
      var res2 = await _getGrahaDignity();
      if (res2 == 1) {
        var res3 = await _getAllRelation();
        if (res3 == 1) {
          var res4 = await _getBhavaDetails();
          if (res4 == 1) {
            var res5 = await _getAspects();
          }
        }
      }
    }

    return 0;
  }

//Get data for populating Graha Details
  Future<int> _getGrahaDetails() async {
    asc = planetPos[0];
    planetPos.removeAt(0);
    planetSpeed.removeAt(0);
    int plposint = 0, ascposint = asc ~/ 30 - 1;

    for (int i = 0; i < 9; i++) {
      plposint = planetPos[i] ~/ 30.ceil();
      if (plposint - ascposint < 0) {
        plposint = plposint + 12;
      }
      _updateMap(grahaDetails, "grh", dasagraha[i].name!);
      _updateMap(grahaDetails, "bhv", (plposint - ascposint).toString());
      _updateMap(grahaDetails, "deg", (planetPos[i].toStringAsFixed(2)));
      _updateMap(
          grahaDetails, "ras", ((planetPos[i] ~/ 30.ceil() + 1).toString()));
      _updateMap(
          grahaDetails, 'rnm', raasi[(planetPos[i] ~/ 30).ceil()].shortname!);
      _updateMap(grahaDetails, 'rld', raasi[(planetPos[i] ~/ 30).ceil()].lord!);
      _updateMap(
          grahaDetails,
          'pad',
          (((planetPos[i] - (((planetPos[i] ~/ 27)) * 27)) * .13333)
              .ceil()
              .toStringAsFixed(0)));

      for (int j = 0; j < nak.length; j++) {
        if (planetPos[i] < nak[j].degend!) {
          _updateMap(grahaDetails, 'nnm', nak[j].name!);
          _updateMap(grahaDetails, 'nld', nak[j].lord!);
          break;
        }
      }
      List<int> cnt = [];
      for (int p = 0; p < raasi.length; p++) {
        if (grahaDetails['rld']![i] == raasi[p].lord) {
          if (p - (asc ~/ 30) < 0) {
            cnt.add(p - (asc ~/ 30) + 12 + 1);
          } else {
            cnt.add(p - (asc ~/ 30) + 1);
          }
        }
      }
      _updateMap(grahaDetails, 'bhv2', cnt.toString());

      for (int k = 0; k < 9; k++) {
        if (grahaDetails['rld']![i] == dasagraha[k].name) {
          _updateMap(
              grahaDetails, 'rlt', dasagraha[i].relations!.split(',')[k]);
          break;
        }
      }
      cnt.clear();
    }

    return 1;
  }

//Get data for populating Bhava Details
  Future<int> _getBhavaDetails() async {
    int cnd = 0;
    List<String> rel = [];
    for (int i = 1; i < 13; i++) {
      cnd = 0;
      for (int j = 0; j < 9; j++) {
        //update data where Rasi has a Graha in it
        //  print('Graha bhv  $i - ${grahaDetails['bhv']![j]}');
        if (i == double.parse(grahaDetails['bhv']![j])) {
          cnd = 1;
          _updateMap(bhavaDetails, 'bhv', grahaDetails['bhv']![j]);
          _updateMap(bhavaDetails, 'rld', grahaDetails['rld']![j]);
          _updateMap(bhavaDetails, 'bhv2', grahaDetails['bhv2']![j]);
          _updateMap(bhavaDetails, 'grh', grahaDetails['grh']![j]);
          if (planetSpeed[j] < 0) {
            if (j == 7 || j == 8) {
              _updateMap(bhavaDetails, 'spd', '-');
            } else {
              _updateMap(bhavaDetails, 'spd', 'R');
            }
          } else {
            _updateMap(bhavaDetails, 'spd', '-');
          }
        }
      }
      //update data if the Rasi does not have a Graha in it
      if (cnd != 1) {
        _updateMap(bhavaDetails, 'bhv', i.toString());
        if ((i + asc ~/ 30 - 1) > 11) {
          _updateMap(
              bhavaDetails, 'rld', raasi[i + (asc ~/ 30 - 1) - 12].lord!);
        } else {
          _updateMap(bhavaDetails, 'rld', raasi[i + (asc ~/ 30) - 1].lord!);
        }

        List<int> cnt = [];
        for (int p = 0; p < raasi.length; p++) {
          if (bhavaDetails['rld']!.last == raasi[p].lord) {
            if (p - (asc ~/ 30) < 0) {
              cnt.add(p - (asc ~/ 30) + 12 + 1);
            } else {
              cnt.add(p - (asc ~/ 30) + 1);
            }
          }
        }
        bhavaDetails.update("bhv2", (list) => list..add(cnt),
            ifAbsent: () => [cnt]);
        _updateMap(bhavaDetails, 'grh', '----');
        _updateMap(bhavaDetails, 'rlt', '-');
        _updateMap(bhavaDetails, 'spd', '-');
      }
    }
    return 1;
  }

//Calculate Exhalted,Debilitated,Moola,Own Houses and Points
  Future<int> _getGrahaDignity() async {
    List<Map<String, List<dynamic>>> dign = [];
    List<double> digndouble = [];
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < dasagraha[i].grahadignity!.split(',').length; j++) {
        digndouble.add(double.parse(dasagraha[i].grahadignity!.split(',')[j]));
      }
      dign.addAll([
        {grahaList[i]: digndouble.toList()}
      ]);
      digndouble.clear();
    }

    for (int z = 0; z < 9; z++) {
      if (double.parse(grahaDetails['deg']![z]) >= dign[z][grahaList[z]]![2] &&
          double.parse(grahaDetails['deg']![z]) <= dign[z][grahaList[z]]![3]) {
        _updateMap(grahaDetails, "dgn", 'Ex-P');
      } else if (double.parse(grahaDetails['deg']![z]) >=
              dign[z][grahaList[z]]![0] &&
          double.parse(grahaDetails['deg']![z]) <= dign[z][grahaList[z]]![1]) {
        _updateMap(grahaDetails, "dgn", 'Ex-R');
      } else if (double.parse(grahaDetails['deg']![z]) >=
              dign[z][grahaList[z]]![6] &&
          double.parse(grahaDetails['deg']![z]) <= dign[z][grahaList[z]]![7]) {
        _updateMap(grahaDetails, "dgn", 'Db-P');
      } else if (double.parse(grahaDetails['deg']![z]) >=
              dign[z][grahaList[z]]![4] &&
          double.parse(grahaDetails['deg']![z]) <= dign[z][grahaList[z]]![5]) {
        _updateMap(grahaDetails, "dgn", 'Db-R');
      } else if (double.parse(grahaDetails['deg']![z]) >=
              dign[z][grahaList[z]]![8] &&
          double.parse(grahaDetails['deg']![z]) <= dign[z][grahaList[z]]![9]) {
        _updateMap(grahaDetails, "dgn", 'Mool');
      } else if (double.parse(grahaDetails['deg']![z]) >=
              dign[z][grahaList[z]]![10] &&
          double.parse(grahaDetails['deg']![z]) <= dign[z][grahaList[z]]![11]) {
        _updateMap(grahaDetails, "dgn", 'Own');
      } else if (double.parse(grahaDetails['deg']![z]) >=
              dign[z][grahaList[z]]![12] &&
          double.parse(grahaDetails['deg']![z]) <= dign[z][grahaList[z]]![13]) {
        _updateMap(grahaDetails, "dgn", 'Own');
      } else {
        _updateMap(grahaDetails, "dgn", '---');
      }
    }

    return 1;
  }

  Future<int> _getAllRelation() async {
    List<String> fixedRel = [];
    int diff = 0;
    for (int i = 0; i < grahaList.length; i++) {
      for (int j = 0; j < grahaList.length; j++) {
        if (grahaList[i] == grahaList[j]) {
          fixedRel.add('--');
        } else {
          diff = int.parse(grahaDetails['ras']![j]) -
              int.parse(grahaDetails['ras']![i]) +
              1;
          if (diff < 0) {
            diff = diff + 12;
          }
          if (diff == 1 ||
              diff == 5 ||
              diff == 6 ||
              diff == 7 ||
              diff == 8 ||
              diff == 9) {
            fixedRel.add('En');
          } else {
            fixedRel.add('Fr');
          }
        }
      }
      fixedRelMap.addAll([
        {grahaList[i]: fixedRel.toList()}
      ]);

      fixedRel.clear();
    }
    //Calculate Compound Relationship
    String prel = '', trel = '';
    List<String> allrel = [];
    for (int a = 0; a < grahaList.length; a++) {
      for (int b = 0; b < grahaList.length; b++) {
        prel = dasagraha[a].relations!.split(',')[b];
        trel = fixedRelMap[a][grahaList[a]]![b];
        if (prel == 'Fr' && trel == 'Fr') {
          allrel.add('Am');
        } else if (prel == 'Fr' && trel == 'En') {
          allrel.add('Sm');
        } else if (prel == 'Nu' && trel == 'Fr') {
          allrel.add('Mi');
        } else if (prel == 'Nu' && trel == 'En') {
          allrel.add('St');
        } else if (prel == 'En' && trel == 'Fr') {
          allrel.add('Sm');
        } else if (prel == 'En' && trel == 'En') {
          allrel.add('As');
        } else {
          allrel.add('--');
        }
      }
      allRelMap.addAll([
        {grahaList[a]: allrel.toList()}
      ]);
      allrel.clear();
    }
    return 1;
  }

//Calculagte Aspects Argalas and Virodhargalas
  Future<int> _getAspects() async {
    List<int> allAspects = [6, 1, 3, 10, 2, 8, 9, 11, 3, 7, 4, 8, 2, 9];
    int rasi = 0, addaspno1 = 0, addaspno2 = 0;

    List<String> aspList = [];

    //Calculate Aspects
    for (int i = 0; i < 9; i++) {
      rasi = int.parse(grahaDetails['bhv']![i]);

      /*  if (i == 4) {
        addaspno1 = _reduceRasi((rasi + 3));
        addaspno2 = _reduceRasi((rasi + 7));
      } else if (i == 5) {
        addaspno1 = _reduceRasi((rasi + 4));
        addaspno2 = _reduceRasi((rasi + 8));
        print('$addaspno1 $addaspno2');
      } else if (i == 6) {
        addaspno1 = _reduceRasi((rasi + 2));
        addaspno2 = _reduceRasi((rasi + 9));
      } */
      for (int j = 0; j < 12; j++) {
        if (_reduceRasi(rasi + allAspects[0]) == j + 1) {
          aspList.add('D');
        } else {
          aspList.add('-');
        }
      }

      //Special Aspects of Kuja, Guru, Shani
      for (int j = 0; j < 12; j++) {
        if ((i == 4 && _reduceRasi(rasi + allAspects[8]) == j + 1) ||
            (i == 4 && _reduceRasi(rasi + allAspects[9]) == j + 1)) {
          aspList[j] = 'D';
        } else if ((i == 5 && _reduceRasi(rasi + allAspects[10]) == j + 1) ||
            (i == 5 && _reduceRasi(rasi + allAspects[11]) == j + 1)) {
          aspList[j] = 'D';
        } else if ((i == 6 && _reduceRasi(rasi + allAspects[12]) == j + 1) ||
            (i == 6 && _reduceRasi(rasi + allAspects[13]) == j + 1)) {
          aspList[j] = 'D';
        }
      }

      //Calculate Argalas
      for (int j = 0; j < 12; j++) {
        if ((_reduceRasi(rasi + allAspects[1]) == j + 1) ||
            (_reduceRasi(rasi + allAspects[2]) == j + 1) ||
            (_reduceRasi(rasi + allAspects[3]) == j + 1)) {
          if (aspList[j] != 'D') {
            aspList[j] = 'A';
          } else {
            aspList[j] = 'B';
          }
        }
      }

      //Calculate Virodhargala
      for (int j = 0; j < 12; j++) {
        if ((_reduceRasi(rasi + allAspects[4]) == j + 1) ||
            (_reduceRasi(rasi + allAspects[5]) == j + 1) ||
            (_reduceRasi(rasi + allAspects[6]) == j + 1) ||
            (_reduceRasi(rasi + allAspects[7]) == j + 1)) {
          if (aspList[j] == 'A') {
            aspList[j] = 'O';
          } else if (aspList[j] == 'E') {
            aspList[j] = 'P';
          } else if (aspList[j] == 'D') {
            aspList[j] = 'Q';
          } else {
            aspList[j] = 'V';
          }
        }
      }

      allAspMap.addAll([
        {grahaList[i]: aspList.toList()}
      ]);
      aspList.clear();
    }

    return 1;
  }

//Reduce Rasi if more than 12
  int _reduceRasi(int numb) {
    if (numb > 12) {
      numb = numb - 12;
    }
    return numb;
  }

  double _textStringToDouble() {
    double value = 0;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SingleChildScrollView(
        child: FutureBuilder(
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
                    padding: const EdgeInsets.all(10.0),
                    child: SafeArea(
                        child: Column(
                      children: [
                        Text(
                          'Raasi Chart',
                          style: titleStyle,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Graha Details - - Asc : ${(asc).toStringAsFixed(2)}',
                          style: subTitleStyle,
                        ),
                        const Divider(
                          thickness: 5,
                        ),
                        //Graha Details starts here=============================
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            width: 525,
                            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Column(children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'GRAHA         DEGREE   (R)      RAASI     OWNER      IN     DNT    NAKSHATRA        N-LORD       PADA  ',
                                  style: paraStyle,
                                ),
                              ),
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Divider(
                                  thickness: 2,
                                ),
                              ),
                              for (int i = 0; i < dasagraha.length; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    alignedText(
                                        65, '${grahaDetails['grh']![i]}', 0),
                                    alignedText(
                                        50, '${grahaDetails['deg']![i]}', 0),
                                    i == 7 || i == 8
                                        ? alignedText(20, ' ', 0)
                                        : planetSpeed[i] < 0
                                            ? alignedText(20, 'R', 0)
                                            : alignedText(20, ' ', 0),
                                    alignedText(
                                        20, '${grahaDetails['ras']![i]}', 0),
                                    alignedText(
                                        30, '${grahaDetails['rnm']![i]}', 0),
                                    alignedText(
                                        58, ' ${grahaDetails['rld']![i]}', 0),
                                    alignedText(
                                        23, '${grahaDetails['rlt']![i]}', 0),
                                    alignedText(
                                        35, '${grahaDetails['dgn']![i]}', 0),
                                    alignedText(
                                        105, ' ${grahaDetails['nnm']![i]}', 0),
                                    alignedText(
                                        63, ' ${grahaDetails['nld']![i]}', 0),
                                    alignedText(
                                        15, '${grahaDetails['pad']![i]}', 0),
                                    const SizedBox(
                                      width: 40,
                                    ),
                                  ],
                                ),
                            ]),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'IN: Friend/Enemy/Nuetral Houses',
                                style: paraStyle,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'DNT: Exalted/Debilitated/Moola/Own',
                                style: paraStyle,
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          thickness: 5,
                        ),
                        Text(
                          'Relationship, Drishti, Argala',
                          style: subTitleStyle,
                        ),
                        const Divider(
                          thickness: 5,
                        ),

                        //Relationship Grid starts here=============================
                        Column(
                          children: [
                            //Relationship Header
                            Row(
                              children: [
                                alignedText(33, 'Grh', 0),
                                for (int m = 0; m < 7; m++)
                                  Row(
                                    children: [
                                      alignedText(25, grahaList[m], 0),
                                    ],
                                  ),
                                const SizedBox(
                                  width: 35,
                                ),
                                //Drishti Header
                                for (int n = 0; n < 12; n++)
                                  Row(
                                    children: [
                                      alignedText(20, '${n + 1}', 0),
                                    ],
                                  ),
                              ],
                            ),
                            const Divider(
                              thickness: 2,
                            ),

                            //Relationship details=============================
                            for (int z = 0; z < 7; z++)
                              Row(
                                children: [
                                  alignedText(35, grahaList[z], 0),
                                  Row(
                                    children: [
                                      for (int u = 0; u < 7; u++)
                                        alignedText(
                                            25,
                                            allRelMap[z][grahaList[z]]![u]
                                                .toString(),
                                            0)
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),

                                  //Drishti details=============================
                                  Row(
                                    children: [
                                      for (int u = 0; u < 12; u++)
                                        alignedText(
                                            20,
                                            allAspMap[z][grahaList[z]]![u]
                                                .toString(),
                                            0)
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const Divider(
                          thickness: 2,
                        ),

                        //Bottom Line=============================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Mitra/Sama/Satru/AdhiMitra/AdhiSatru',
                              style: paraStyle,
                            ),
                            const SizedBox(
                              width: 35,
                            ),
                            Text(
                              'D: Drishti/ A: Argala/ V: Virodhargala',
                              style: paraStyle,
                            ),
                          ],
                        ),
                        Text(
                          'B: Dri+Arg / O: Arg+VArg / P: Dri+Arg+VArg / Q: Dri+VArg',
                          style: paraStyle,
                        ),
                        const Divider(
                          thickness: 5,
                        ),
                        //Bhava Analysis starts here=============================

                        Text(
                          'Bhava Details',
                          style: subTitleStyle,
                        ),
                        const Divider(
                          thickness: 5,
                        ),

                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'BVA ||     BHAVA LORD   ||    GRAHA     ||   STHANA  ||  RLT  ||    GD    ||    RD    ||',
                            style: paraStyle,
                          ),
                        ),
                        const Divider(
                          thickness: 2,
                        ),
                        for (int i = 0; i < bhavaDetails['bhv']!.length; i++)
                          Row(
                            children: [
                              alignedText(30, '${bhavaDetails['bhv']![i]},', 0),
                              alignedText(58, '${bhavaDetails['rld']![i]}', 0),
                              alignedText(45, '${bhavaDetails['bhv2']![i]}', 0),
                              alignedText(55, '${bhavaDetails['grh']![i]}', 0),
                              alignedText(15, '${bhavaDetails['spd']![i]}', 0),
                            ],
                          ),
                        /*  for (int i = 0; i < dasagraha.length; i++)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              alignedText(30, '${grahaDetails['bhv']![i]}'),
                              alignedText(53, '${grahaDetails['grh']![i]}'),
                              i == 7 || i == 8
                                  ? alignedText(20, ' ')
                                  : planetSpeed[i] < 0
                                      ? alignedText(20, 'R')
                                      : alignedText(20, ' '),
                              /* alignedText(34, 'M'),
                              alignedText(36, '${grahaDetails['cnd']![i]}  '),
                              alignedText(50, ' ${grahaDetails['rld']![i]}'),
                              alignedText(50, '${grahaDetails['bhv2']![i]}'),
                              alignedText(30, 'AM'), */
                            ],
                          ), */
                        const Divider(
                          thickness: 5,
                        ),
                        alignedText(
                            300,
                            'RLT: Relation / GD: Graha Drishti / RD: Rasi Drishti',
                            0),
                      ],
                    )),
                  );
                }
              }
              return Container();
            }),
      ),
    );
  }

  Widget alignedText(double wdt, String textin, int clr) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
      width: wdt,
      child: Text(
        textin,
        style: clr == 0 ? paraStyle : paraStyleRed,
      ),
    );
  }

  _updateMap(Map<String, List<dynamic>> map, String row, String newvalue) {
    map.update(row, (list) => list..add(newvalue), ifAbsent: () => [newvalue]);
  }
}
