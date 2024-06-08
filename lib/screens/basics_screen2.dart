import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/raasi.dart';
import '../models/userdata.dart';
import '../ui/theme.dart';
import '../utils/databasehelper.dart';
import '../utils/myfunctions.dart';
import '../models/upagrahas.dart';

class BasicsScreen2 extends StatefulWidget {
  final Users user;
  final List<Map<String, Map<String, List<dynamic>>>> grahadata;
  const BasicsScreen2({Key? key, required this.user, required this.grahadata})
      : super(key: key);

  @override
  State<BasicsScreen2> createState() => _BasicsScreen2State();
}

class _BasicsScreen2State extends State<BasicsScreen2>
    with SingleTickerProviderStateMixin {
  final dbHelper = DatabaseHelper.db;

  Future future = Future.delayed(const Duration(seconds: 2));
  late List<Raasi> raasi;
  TabController? tabController;
  double screenht = 0, screenwd = 0;
  List<Color> colors = [Colors.black, Colors.white, Colors.amber];
  List<Map<String, Map<String, List<dynamic>>>> grahaData = [];
  List<Upagrahas> upas = [];
  List<Map<String, dynamic>> sortList = [];
  List<String> degMinSec = [];
  List<String> grahas = [
    'Lagna',
    'Ravi',
    'Chandra',
    'Budha',
    'Shukra',
    'Kuja',
    'Guru',
    'Shani',
    'Rahu',
    'Ketu'
  ];
  List<String> karakas = [
    'Atma',
    'Amatya',
    'Bhratri',
    'Matri',
    'Pitri',
    'Putra',
    'Jnaati',
    'Dara',
    'NA',
    'NA'
  ];
  List<String> sKaraka = [
    'NA',
    'Pitri',
    'Matri',
    'Relatives',
    'Dara',
    'Siblings',
    'Dara,Putra',
    'Bhratri',
    'NA',
    'NA'
  ];
  List<String> sunTimes = [];
  String dayOfWeek = '';
  int wkday = 0;
  List<Upagrahas> upalist = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    grahaData.addAll(widget.grahadata);
    future = _future();
  }

  Future<int> _future() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    screenht = prefs.get('Height') as double;
    screenwd = prefs.get('Width') as double;
    // upalist = await dbHelper.getUpaList();
    raasi = await dbHelper.getRaasiList();
    if (raasi.isNotEmpty) {
      for (int i = 0; i < raasi.length; i++) {}
    }
    var res = await _getAmsaRuler();
    if (res == 0) {
      var res1 = await _getOtherDetails();
      if (res1 == 0) {
        return 0;
      }
    }
    return 0;
  }

//Get Amsa Ruler details
  Future<int> _getAmsaRuler() async {
    double prg = 0;

    for (int i = 0; i < grahaData[1]['D01']!['Prg']!.length; i++) {
      if (i == 0 || i == 9) {
        sortList.add({'_id': i, '_prg': 0});
      } else if (i == 8) {
        prg = 30.0 - (grahaData[1]['D01']!['Prg']![i]);
        prg = double.parse(prg.toStringAsFixed(2));
        sortList.add({'_id': i, '_prg': prg});
      } else {
        prg = (grahaData[1]['D01']!['Prg']![i]);
        prg = double.parse(prg.toStringAsFixed(2));
        sortList.add({'_id': i, '_prg': prg});
      }
    }

    sortList.sort((a, b) => (b['_prg']).compareTo(a['_prg']));

    for (int j = 0; j < sortList.length; j++) {
      sortList[j].addAll({'_kar': karakas[j]});
    }
    sortList.sort((a, b) => (a['_id']).compareTo(b['_id']));
    String balDeg = '';
    for (int k = 0; k < 10; k++) {
      String res = await decimalToTime(grahaData[1]['D01']!['Deg']![k]);
      balDeg = ((grahaData[1]['D01']!['Prg']![k]).truncate()).toString();
      degMinSec.add(
          (' $balDeg ${grahaData[1]['D01']!['Rnm']![k]} ${res.split(':')[1]}\':${res.split(':')[2]}"'));
    }

    return 0;
  }

//Convert Upagraha details to hr:mn:ss
  Future<int> _getOtherDetails() async {
    sunTimes.add(
        await secToTimeStr(int.parse(widget.user.suntimes!.split(',')[1])));
    sunTimes.add(
        await secToTimeStr(int.parse(widget.user.suntimes!.split(',')[2])));
    sunTimes.add(
        await secToTimeStr(int.parse(widget.user.suntimes!.split(',')[3])));

    List<String> upa = [];

    for (int i = 0; i < 6; i++) {
      double upaPos = (double.parse(widget.user.upapos!.split(',')[i]));
      int minsec = ((upaPos - upaPos.truncate()) * 3600).round();
      String rsi = raasi[((upaPos ~/ 30)).ceil()].shortname!;
      String minSecs = await secToTimeStr(minsec);

      upa.add(
          '${(upaPos.remainder(30)).truncate()} $rsi ${minSecs.substring(3, 8)}');
    }

    //Day of Week
    if (widget.user.suntimes![0] == '0') {
      dayOfWeek = DateFormat('EEEE').format(
          DateTime.parse(widget.user.birthdttm!)
              .subtract(const Duration(days: 1)));
    } else {
      dayOfWeek =
          DateFormat('EEEE').format(DateTime.parse(widget.user.birthdttm!));
    }

    print(widget.user.suntimes);

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DefaultTabController(
                length: 3,
                child: Scaffold(
                  backgroundColor: Colors.blue,
                  bottomSheet: TabBar(
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.amber,
                    tabs: const [
                      Tab(
                        child: Icon(Icons.table_bar_outlined),
                      ),
                      Tab(
                        child: Icon(Icons.key),
                      ),
                      Tab(
                        child: Icon(Icons.sunny),
                      )
                    ],
                    controller: tabController,
                  ),
                  body: TabBarView(controller: tabController, children: [
                    Container(
                      color: Colors.blue,
                      width: screenwd * .4,
                      height: screenht,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              textBlock('Basic Details', 2),
                              const SizedBox(
                                height: 10,
                              ),
                              const Divider(
                                height: 2,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      textBlock('Name:', 0),
                                      textBlock('Date of Birth:', 0),
                                      textBlock('Time of Birth:', 0),
                                      textBlock('Time Zone:', 0),
                                      textBlock('City:', 0),
                                      textBlock('Long/Lat:', 0),
                                      textBlock('Lunar Year/Month:', 0),
                                      textBlock('Thithi:', 0),
                                      textBlock('Vedic Weekday:', 0),
                                      textBlock('Nakshatra:', 0),
                                      textBlock('Yoga:', 0),
                                      textBlock('Karana:', 0),
                                      textBlock('Hora Lord:', 0),
                                      textBlock('Kaala Lord:', 0),
                                      textBlock('Gauri Panchami:', 0),
                                      textBlock('Sunrise:', 0),
                                      textBlock('Sunset:', 0),
                                      textBlock('Janma Ghatis:', 0),
                                      textBlock('Ayanamsa:', 0),
                                      textBlock('Sid Time:', 0),
                                      textBlock('Karaka Tithi:', 0),
                                      textBlock('Karaka Yoga:', 0),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  //const Spacer(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      textBlock(widget.user.name!, 0),
                                      textBlock(
                                          widget.user.birthdttm!.characters
                                              .take(10)
                                              .toString(),
                                          0),
                                      textBlock(
                                          '${widget.user.birthdttm!.substring(11, 16)} Hrs',
                                          0),
                                      textBlock('IST', 0),
                                      textBlock('NA', 0),
                                      textBlock(
                                          '${widget.user.birthlong!.toStringAsFixed(2)} / ${widget.user.birthlat!.toStringAsFixed(2)}',
                                          0),
                                      textBlock(
                                          grahaData[1]['D01']!['Deg']![0]
                                              .toString(),
                                          0),
                                      textBlock('NA', 0),
                                      textBlock(dayOfWeek, 0),
                                      textBlock(
                                          '${grahaData[1]['D01']!['NkN']![2]} - ${grahaData[1]['D01']!['NkL']![2]}',
                                          0),
                                      textBlock('NA', 0),
                                      textBlock('NA', 0),
                                      textBlock('NA', 0),
                                      textBlock('NA', 0),
                                      textBlock('NA', 0),
                                      textBlock(sunTimes[0], 0),
                                      textBlock(sunTimes[1], 0),
                                      textBlock('NA', 0),
                                      textBlock('23.29472°', 0),
                                      textBlock(
                                          widget.user.upapos!.split(',')[0], 0),
                                      textBlock('NA', 0),
                                      textBlock('NA', 0),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [textBlock('Second Row', 0)],
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    ),
                    Container(
                      color: Colors.blue,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          textBlock('Graha Details', 2),
                          const Divider(
                            height: 5,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DataTable(
                            columnSpacing: 0.5,
                            dataRowHeight: 22,
                            columns: [
                              DataColumn(label: textBlock('Graha', 1)),
                              DataColumn(label: textBlock('R', 1)),
                              DataColumn(label: textBlock('Degree    ', 1)),
                              DataColumn(label: textBlock('     Rasi', 1)),
                              DataColumn(label: textBlock('No   ', 1)),
                              DataColumn(label: textBlock(' Rasi-Lord', 1)),
                              DataColumn(label: textBlock(' Nakshatra', 1)),
                              DataColumn(label: textBlock('Pada  ', 1)),
                              DataColumn(label: textBlock(' Nak-Lord', 1)),
                            ],
                            rows: [
                              for (int i = 0; i < 10; i++)
                                DataRow(cells: [
                                  DataCell(_dataColumn(50, 20, grahas[i], 1)),
                                  i < 8
                                      ? (grahaData[1]['D01']!['Spd']![i]) < 0
                                          ? DataCell(
                                              _dataColumn(10, 20, 'R', 1))
                                          : DataCell(_dataColumn(10, 20, '', 1))
                                      : DataCell(_dataColumn(10, 20, '', 1)),
                                  DataCell(_dataColumn(
                                      38,
                                      20,
                                      grahaData[1]['D01']!['Deg']![i]
                                          .toStringAsFixed(2),
                                      1)),
                                  DataCell(
                                      _dataColumn(85, 20, (degMinSec[i]), 1)),
                                  DataCell(_dataColumn(
                                      15,
                                      20,
                                      (grahaData[1]['D01']!['Rin']![i] + 1)
                                          .toString(),
                                      1)),
                                  DataCell(_dataColumn(60, 20,
                                      grahaData[1]['D01']!['RLd']![i], 1)),
                                  DataCell(_dataColumn(80, 20,
                                      grahaData[1]['D01']!['NkN']![i], 1)),
                                  DataCell(_dataColumn(
                                      10,
                                      20,
                                      (grahaData[1]['D01']!['Pad']![i])
                                          .toString(),
                                      1)),
                                  DataCell(_dataColumn(60, 20,
                                      grahaData[1]['D01']!['NkL']![i], 1)),
                                ])
                            ],
                          ),
                          const Divider(
                            height: 5,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          textBlock('Karakas', 2),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            height: 5,
                          ),
                          DataTable(
                            columnSpacing: 1,
                            dataRowHeight: 22,
                            columns: [
                              DataColumn(label: textBlock('Graha', 1)),
                              DataColumn(label: textBlock('Progress', 1)),
                              DataColumn(label: textBlock('Chara ', 1)),
                              DataColumn(label: textBlock('Sthira ', 1)),
                              DataColumn(label: textBlock('Nisargika ', 1)),
                            ],
                            rows: [
                              for (int i = 0; i < 10; i++)
                                DataRow(cells: [
                                  DataCell(_dataColumn(60, 20, grahas[i], 1)),
                                  DataCell(_dataColumn(72, 20,
                                      sortList[i]['_prg'].toString(), 1)),
                                  DataCell(_dataColumn(
                                      80, 20, sortList[i]['_kar'], 1)),
                                  DataCell(_dataColumn(80, 20, sKaraka[i], 1)),
                                  DataCell(_dataColumn(
                                      80, 20, sortList[i]['_kar'], 1)),
                                ])
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(),
                  ]),
                ));
          }

          return Container();
        });

    /*  */
  }

  Widget textBlock(String text, int txtstyle) {
    return txtstyle == 0
        ? Text(
            text,
            style: paraBoldStyle,
          )
        : txtstyle == 1
            ? Text(
                text,
                style: paraStyle,
              )
            : Text(
                text,
                style: titleStyle,
              );
  }

  Widget _dataColumn(double wdth, double hgt, String txt, int txtstyl) {
    return Container(
      width: wdth,
      height: hgt,
      child: textBlock(txt, txtstyl),
    );
  }
}
