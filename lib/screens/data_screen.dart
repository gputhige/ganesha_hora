import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parashara_hora/models/grahas.dart';
import 'package:parashara_hora/models/nakshatra.dart';
import 'package:parashara_hora/screens/chartview3.dart';
import 'package:parashara_hora/ui/theme.dart';
import 'package:parashara_hora/utils/myfunctions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/raasi.dart';
import '../models/users.dart';
import '../utils/databasehelper.dart';

/* Database Structure 
* grahaData[0]['Ind'] - [SNm]
* grahaData[1]['D01'] - [Deg][Spd][Prg][Rin][RNm][RLd][NkN][NkL]
* grahaData[2]['D02'] - [Deg][Rin] (from D02 to D60)
* grahaData[3]['Ard'] - [D01] to [D60]
*/

class DataScreen extends StatefulWidget {
  final Users user;
  const DataScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final dbHelper = DatabaseHelper.db;
  Future? future;
  double blockOne = 0, screenwd = 0, screenht = 0;

  List<Map<String, Map<String, List<dynamic>>>> grahaData = [];
  List<Map<String, Map<String, List<dynamic>>>> bhavaData = [];
  List<Grahas> grahas = [];
  List<Raasi> raasis = [];
  List<Nakshatra> nakshatras = [];

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
    grahas = await dbHelper.getGraha();
    raasis = await dbHelper.getRaasiList();
    nakshatras = await dbHelper.getNakList();

    var step1 = await _getRasiChartData();
    if (step1 == 0) {
      var step2 = await _getDivChartData();
      if (step2 == 0) {
        var step3 = await _getRIn();
        if (step3 == 0) {
          var step4 = await _getArudas(1, 'D01');
          if (step4 == 0) {
            var step5 = await _getArudas(2, 'D02');
            if (step5 == 0) {
              Get.to(() =>
                  ChartViewThree(user: widget.user, grahaData: grahaData));
            }
          }
        }
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                      child: Container(
                width: screenwd * .95,
                height: screenht * .9,
                decoration: BoxDecoration(
                    border: Border.all(width: 5), color: Colors.blue),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Please wait while the Data is being fetched',
                    style: contentStyle,
                  ),
                ),
              )));
            }
          }
          return Container();
        },
      ),
    );
  }

  Future<int> _getRasiChartData() async {
    List<double> pos = [], spd = [], prg = [];
    List<String> grahaname = [],
        rasiName = [],
        nakname = [],
        nakLord = [],
        rasiLord = [];
    List<int> rasiNo = [], pada = [];

    for (int i = 0; i < 10; i++) {
      if (i == 0) {
        grahaname.add("As");
      } else {
        grahaname.add(grahas[i - 1].shortname!);
      }
      pos.add(await listStrToDbl(widget.user.planetpos.toString(), ",", i));
      spd.add(await listStrToDbl(widget.user.planetspeed.toString(), ",", i));
      rasiNo.add(pos[i] ~/ 30.ceil());
      rasiName.add(raasis[rasiNo[i]].shortname!);
      nakname.add(nakshatras[(pos[i] ~/ 13.33)].name!);
      nakLord.add(nakshatras[(pos[i] ~/ 13.33)].lord!);
      rasiLord.add(raasis[rasiNo[i]].lord!);
      prg.add(pos[i].remainder(30));
      pada.add(await reduceRasi((pos[i] ~/ 3.3333), 4) + 1);
    }

    grahaData.addAll([
      {
        "Gen": {"Ind": List.generate(10, (index) => index)}
      }
    ]);
    grahaData[0]["Gen"]!.addAll({"SNm": grahaname});
    grahaData.addAll([
      {
        "D01": {"Deg": pos}
      }
    ]);
    grahaData[1]['D01']!.addAll({'Spd': spd});
    grahaData[1]['D01']!.addAll({'Rin': rasiNo});
    grahaData[1]['D01']!.addAll({'Rnm': rasiName});
    grahaData[1]['D01']!.addAll({'RLd': rasiLord});
    grahaData[1]['D01']!.addAll({'NkN': nakname});
    grahaData[1]['D01']!.addAll({'Prg': prg});
    grahaData[1]['D01']!.addAll({'NkL': nakLord});
    grahaData[1]['D01']!.addAll({'Pad': pada});

    return 0;
  }

//Calculate Rasi Number for Div Charts
  Future<int> _getRIn() async {
    List<int> rinlist = [];
    List<String> amsaList = grahaData[2].keys.toList();

    for (int i = 0; i < amsaList.length; i++) {
      //i = length of all Divisional Charts
      for (int j = 0; j < grahaData[2][amsaList[i]]!['Deg']!.length; j++) {
        //j = length of all degrees in each divisional chart
        rinlist.add(grahaData[2][amsaList[i]]!['Deg']![j] ~/ 30.ceil());
      }
      grahaData[2][amsaList[i]]!.addAll({
        'Rin': [...rinlist]
      });
      rinlist.clear();
    }

    return 0;
  }

//Get Aruda Data
  Future<int> _getArudas(int index, String chartno) async {
    List<double> newpos = [];
    int seq = 0, rin = 0, dist = 0, pos = 0;
    if (index == 1) {
      int ascIn = grahaData[index][chartno]!['Rin']![0];
      for (int i = 0; i < 12; i++) {
        seq = (raasis[await reduceRasi((i + ascIn), 12)].rasiorder! + 1);
        rin = grahaData[index][chartno]!['Rin']![seq];
        dist = roundUp(((rin + 1) - (i + ascIn)), 0);
        pos = await reduceRasi((dist + dist - 1), 12);

        if (pos == 7) {
          pos = await reduceRasi(pos + 9, 12);
        } else if (pos == 1) {
          pos = await reduceRasi(pos + 9, 12);
        }
        pos = await reduceRasi((pos + ascIn + i - 1), 12);
        newpos.add(pos * 30);
      }
      spreadValues(newpos);
      grahaData.addAll([
        {
          'Ard': {
            chartno: [...newpos]
          }
        }
      ]);
      newpos.clear();
    } else {
      List<String> divNo = grahaData[2].keys.toList();

      for (int j = 0; j < divNo.length; j++) {
        for (int k = 0; k < 12; k++) {
          int ascIn = grahaData[2][divNo[j]]!['Rin']![0];

          seq = (raasis[await reduceRasi((k + ascIn), 12)].rasiorder! + 1);
          rin = grahaData[index][divNo[j]]!['Rin']![seq];
          dist = roundUp(((rin + 1) - (k + ascIn)), 0);
          pos = await reduceRasi((dist + dist - 1), 12);

          if (pos == 7) {
            pos = await reduceRasi(pos + 9, 12);
          } else if (pos == 1) {
            pos = await reduceRasi(pos + 9, 12);
          }

          pos = await reduceRasi((pos + ascIn + k - 1), 12);
          newpos.add(pos * 30);
        }

        spreadValues(newpos);

        grahaData[3]['Ard']!.addAll({
          divNo[j]: [...newpos]
        });
        newpos.clear();
      }
    }

    return 0;
  }

//Get Divisional Chart Data
  Future<int> _getDivChartData() async {
    //Calculate D02 Chart ====================================
    double prg = 0;
    int rin = 0;
    List<double> divTemp = [];

    List<double> divList = List.generate(16, (index) => index * (30 / 16));
    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      if (prg <= 10) {
        divTemp.add(rin * 30);
      } else if (prg > 10 && prg <= 20) {
        divTemp.add(await reduceRasi((rin + 4), 12) * 30);
      } else if (prg > 20) {
        divTemp.add(await reduceRasi((rin + 8), 12) * 30);
      }
    }
    spreadValues(divTemp);
    grahaData.addAll([
      {
        'D02': {
          "Deg": [...divTemp]
        }
      }
    ]);

    divTemp.clear();

    //Calculate D03 Chart ====================================
    prg = 0;
    rin = 0;
    divTemp = [];
    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      if (prg <= 10) {
        divTemp.add(rin * 30);
      } else if (prg > 10 && prg <= 20) {
        divTemp.add(await reduceRasi((rin + 4), 12) * 30);
      } else if (prg > 20) {
        divTemp.add(await reduceRasi((rin + 8), 12) * 30);
      }
    }
    spreadValues(divTemp);
    grahaData[2].addAll({
      'D03': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D04 Chart ====================================
    prg = 0;
    rin = 0;
    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];

      if (prg <= 7.5) {
        divTemp.add(rin * 30);
      } else if (prg > 7.5 && prg <= 15) {
        divTemp.add(await reduceRasi((rin + 3), 12) * 30);
      } else if (prg > 15 && prg <= 22.5) {
        divTemp.add(await reduceRasi((rin + 6), 12) * 30);
      } else if (prg > 22.5) {
        divTemp.add(await reduceRasi((rin + 9), 12) * 30);
      }
    }
    spreadValues(divTemp);
    grahaData[2].addAll({
      'D04': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D07 Chart ====================================
    prg = 0;
    rin = 0;
    double divide = 30 / 7;
    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];

      for (int j = 0; j < 7; j++) {
        if (prg >= (j * divide) && prg <= ((j + 1) * divide)) {
          if ((rin + 1).isEven) {
            divTemp.add(await reduceRasi((rin + j + 6), 12) * 30);
          } else {
            divTemp.add(await reduceRasi((rin + j), 12) * 30);
          }
        }
      }
    }
    spreadValues(divTemp);
    grahaData[2].addAll({
      'D07': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D09 Chart ====================================
    prg = 0;
    rin = 0;
    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];

      if ((await everyNth(0, 10, 4, 0)).contains(rin)) {
        divTemp.add(await reduceRasi((((prg / 30 * 9)).floor() + 0), 12) * 30);
      } else if ((await everyNth(0, 10, 4, 1)).contains(rin)) {
        divTemp.add(await reduceRasi((((prg / 30 * 9)).floor() + 9), 12) * 30);
      } else if ((await everyNth(0, 10, 4, 2)).contains(rin)) {
        divTemp.add(await reduceRasi((((prg / 30 * 9)).floor() + 6), 12) * 30);
      } else if ((await everyNth(0, 10, 4, 3)).contains(rin)) {
        divTemp.add(await reduceRasi((((prg / 30 * 9)).floor() + 3), 12) * 30);
      }
    }
    spreadValues(divTemp);
    grahaData[2].addAll({
      'D09': {
        "Deg": [...divTemp]
      }
    });
    print('D09 Pos: ${grahaData[2]['D09']!['Deg']!.toList()}');

    divTemp.clear();

    //Calculate D10 Chart ====================================
    prg = 0;
    rin = 0;
    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      int newDeg = 0;
      if ((rin + 1).isEven) {
        newDeg = (prg ~/ 3);
        newDeg = await reduceRasi((newDeg + rin + 9 - 1), 12);
        divTemp.add(newDeg.toDouble() * 30);
      } else {
        newDeg = (prg ~/ 3);
        newDeg = await reduceRasi(newDeg + rin, 12);
        divTemp.add(newDeg.toDouble() * 30);
      }
    }
    spreadValues(divTemp);
    grahaData[2].addAll({
      'D10': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D12 Chart ====================================
    prg = 0;
    rin = 0;
    divide = 30 / 12;
    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];

      for (int j = 0; j < 12; j++) {
        if (prg >= (j * divide) && prg <= ((j + 1) * divide)) {
          divTemp.add(await reduceRasi((rin + j), 12) * 30);
        }
      }
    }
    spreadValues(divTemp);
    grahaData[2].addAll({
      'D12': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D16 Chart ====================================
    prg = 0;
    rin = 0;
    divList = List.generate(16, (index) => index * (30 / 16));
    int loc = 0;

    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      loc = divList.indexWhere((element) => prg <= element);

      if ((await everyNth(0, 12, 3, 0)).contains(rin)) {
        divTemp.add(await reduceRasi((loc - 1), 12) * 30);
      } else if (((await everyNth(0, 12, 3, 1)).contains(rin))) {
        divTemp.add(await reduceRasi(((loc - 1) + 4), 12) * 30);
      } else if (((await everyNth(0, 12, 3, 2)).contains(rin))) {
        divTemp.add(await reduceRasi((loc - 1 + 8), 12) * 30);
      }
    }

    spreadValues(divTemp);
    grahaData[2].addAll({
      'D16': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D20 Chart ====================================
    prg = 0;
    rin = 0;
    divList = List.generate(20, (index) => index * (30 / 20));

    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      loc = divList.indexWhere((element) => prg <= element);

      if ((await everyNth(0, 12, 3, 0)).contains(rin)) {
        divTemp.add(await reduceRasi((loc - 1), 12) * 30);
      } else if (((await everyNth(0, 12, 3, 1)).contains(rin))) {
        divTemp.add(await reduceRasi(((loc - 1) + 8), 12) * 30);
      } else if (((await everyNth(0, 12, 3, 2)).contains(rin))) {
        divTemp.add(await reduceRasi((loc - 1 + 4), 12) * 30);
      }
    }

    spreadValues(divTemp);
    grahaData[2].addAll({
      'D20': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D24 Chart ====================================
    prg = 0;
    rin = 0;
    divList = List.generate(25, (index) => index * (30 / 24));

    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      loc = divList.indexWhere((element) => prg <= element);
      if ((rin + 1).isOdd) {
        divTemp.add(await reduceRasi((loc - 1 + 4), 12) * 30);
      } else {
        divTemp.add(await reduceRasi((loc - 1 + 3), 12) * 30);
      }
    }

    spreadValues(divTemp);
    grahaData[2].addAll({
      'D24': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D27 Chart ====================================
    prg = 0;
    rin = 0;
    divList = List.generate(27, (index) => index * (30 / 27));

    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      loc = divList.indexWhere((element) => prg <= element);

      if ((await everyNth(0, 12, 4, 0)).contains(rin)) {
        divTemp.add(await reduceRasi((loc - 1), 12) * 30);
      } else if (((await everyNth(0, 12, 4, 1)).contains(rin))) {
        divTemp.add(await reduceRasi(((loc - 1) + 3), 12) * 30);
      } else if (((await everyNth(0, 12, 4, 2)).contains(rin))) {
        divTemp.add(await reduceRasi((loc - 1 + 6), 12) * 30);
      } else if (((await everyNth(0, 12, 4, 3)).contains(rin))) {
        divTemp.add(await reduceRasi((loc - 1 + 9), 12) * 30);
      }
    }

    spreadValues(divTemp);
    grahaData[2].addAll({
      'D27': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D30 Chart ====================================
    prg = 0;
    rin = 0;
    divList = [5, 10, 18, 25, 30];
    List<double> divList2 = [5, 12, 20, 25, 30];
    List<int> divCat1 = [0, 10, 8, 2, 6];
    List<int> divCat2 = [1, 5, 11, 9, 3];

    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];

      if ((rin + 1).isOdd) {
        loc = divList.indexWhere((element) => prg <= (element));
        divTemp.add(divCat1[loc] * 30);
      } else {
        loc = divList2.indexWhere((element) => prg <= (element));
        divTemp.add(divCat2[loc] * 30);
      }
    }

    spreadValues(divTemp);
    grahaData[2].addAll({
      'D30': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D40 Chart ====================================
    prg = 0;
    rin = 0;
    divList = List.generate(41, (index) => index * (30 / 40));

    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      loc = divList.indexWhere((element) => prg <= (element));
      if ((rin + 1).isOdd) {
        divTemp.add(await reduceRasi((loc - 1 + 0), 12) * 30);
      } else {
        divTemp.add(await reduceRasi((loc - 1 + 6), 12) * 30);
      }
    }

    spreadValues(divTemp);
    grahaData[2].addAll({
      'D40': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D45 Chart ====================================
    prg = 0;
    rin = 0;
    divList = List.generate(46, (index) => index * (30 / 45));

    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      loc = divList.indexWhere((element) => prg <= (element));
      if ((await everyNth(0, 12, 3, 0)).contains(rin)) {
        divTemp.add(await reduceRasi((loc - 1), 12) * 30);
      } else if (((await everyNth(0, 12, 3, 1)).contains(rin))) {
        divTemp.add(await reduceRasi(((loc - 1) + 4), 12) * 30);
      } else if (((await everyNth(0, 12, 3, 2)).contains(rin))) {
        divTemp.add(await reduceRasi((loc - 1 + 8), 12) * 30);
      }
    }

    spreadValues(divTemp);
    grahaData[2].addAll({
      'D45': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    //Calculate D60 Chart ====================================
    prg = 0;
    rin = 0;
    divList = List.generate(61, (index) => index * (30 / 60));

    for (int i = 0; i < 10; i++) {
      prg = grahaData[1]['D01']!['Prg']![i];
      rin = grahaData[1]['D01']!['Rin']![i];
      loc = divList.indexWhere((element) => prg <= (element));

      divTemp.add(await reduceRasi((loc + rin - 1), 12) * 30);
    }

    spreadValues(divTemp);
    grahaData[2].addAll({
      'D60': {
        "Deg": [...divTemp]
      }
    });

    divTemp.clear();

    return 0;
  }
}
