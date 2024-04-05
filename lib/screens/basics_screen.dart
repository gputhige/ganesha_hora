import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/raasi.dart';
import '../models/userdata.dart';
import '../ui/theme.dart';
import '../utils/databasehelper.dart';

class BasicsScreen extends StatefulWidget {
  final Users user;
  final List<Map<String, Map<String, List<dynamic>>>> grahadata;
  const BasicsScreen({Key? key, required this.user, required this.grahadata})
      : super(key: key);

  @override
  State<BasicsScreen> createState() => _BasicsScreenState();
}

class _BasicsScreenState extends State<BasicsScreen>
    with SingleTickerProviderStateMixin {
  final dbHelper = DatabaseHelper.db;

  Future future = Future.delayed(const Duration(seconds: 2));
  late List<Raasi> raasi;
  TabController? tabController;
  double screenht = 0, screenwd = 0;
  List<Color> colors = [Colors.black, Colors.white, Colors.amber];
  List<Map<String, Map<String, List<dynamic>>>> grahaData = [];
  List<Map<String, dynamic>> sortedList = [];
  /* List<double> _planetPos = [], _planetSpeed = [];
  List<String> _planetData = []; */
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
    'AK',
    'AmK',
    'BK',
    'MK',
    'PiK',
    'PK',
    'GK',
    'DK',
    'NA',
    'NA'
  ];

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

    //_decimalToTime(widget.user.planetpos![0]);

    raasi = await dbHelper.getRaasiList();
    if (raasi.isNotEmpty) {
      for (int i = 0; i < raasi.length; i++) {}
    }
    var res = await _getAmsaRuler();
    if (res == 0) {
      return 0;
    }
    // var amsa = await _getAmsaRuler();
    return 0;
  }

  _decimalToTime(double value) {
    var hr = value.truncate();
    double res = ((value - value.truncate()) * 10000).truncate().toDouble();
    var min = (res / 10000 * 60).truncate();
    var res2 = (res / 100 * 60).truncate();
    var sec = (res2 - (((res2 / 100).truncate()) * 100));
  }

  Future<int> _getAmsaRuler() async {
    List<Map<String, dynamic>> sortList = [];

    for (int i = 0; i < 10; i++) {
      sortList.add({'_id': '$i', '_pos': (grahaData[1]['D01']!['Prg']![i])});
    }
    sortList.removeAt(0);
    sortList.removeAt(8);
    sortList.sort((a, b) => (b['_pos']).compareTo(a['_pos']));

    for (int j = 0; j < 8; j++) {
      sortedList.add({'_id': sortList[j]['_id'], '_kar': j});
    }
    sortedList.sort((a, b) => (a['_id']).compareTo(b['_id']));

    sortedList.add({'_id': 9, '_kar': 9});
    sortedList.add({'_id': 10, '_kar': 10});

    print(sortedList.toList());

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
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
              /* bottomNavigationBar: NavigationBar(
          selectedIndex: selectedPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedPageIndex = index;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.home), label: 'Basics'),
            NavigationDestination(icon: Icon(Icons.key), label: 'Key Info'),
            NavigationDestination(icon: Icon(Icons.sunny), label: 'Bhavas'),
          ],
        ), */
              body: TabBarView(
                controller: tabController,
                children: [
                  FutureBuilder(
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
                              color: Colors.blue,
                              width: screenwd * .4,
                              height: screenht,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      textBlock('Basic Details', 1),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              textBlock('Name:', 1),
                                              textBlock('Date of Birth:', 1),
                                              textBlock('Time of Birth:', 1),
                                              textBlock('Time Zone:', 1),
                                              textBlock('City:', 1),
                                              textBlock('Long/Lat:', 1),
                                              textBlock('Lunar Year/Month:', 1),
                                              textBlock('Thithi:', 1),
                                              textBlock('Vedic Weekday:', 1),
                                              textBlock('Nakshatra:', 1),
                                              textBlock('Yoga:', 1),
                                              textBlock('Karana:', 1),
                                              textBlock('Hora Lord:', 1),
                                              textBlock('Kaala Lord:', 1),
                                              textBlock('Gauri Panchami:', 1),
                                              textBlock('Sunrise:', 1),
                                              textBlock('Sunset:', 1),
                                              textBlock('Janma Ghatis:', 1),
                                              textBlock('Ayanamsa:', 1),
                                              textBlock('Sid Time:', 1),
                                              textBlock('Karaka Tithi:', 1),
                                              textBlock('Karaka Yoga:', 1),
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
                                              textBlock(widget.user.name!, 1),
                                              textBlock(
                                                  widget.user.birthdttm!
                                                      .characters
                                                      .take(10)
                                                      .toString(),
                                                  1),
                                              textBlock(
                                                  widget.user.birthdttm!
                                                      .substring(11, 16),
                                                  1),
                                              textBlock('IST', 1),
                                              textBlock('NA', 1),
                                              textBlock(
                                                  '${widget.user.birthlong.toString()} / ${widget.user.birthlat.toString()}',
                                                  1),
                                              textBlock(
                                                  grahaData[1]
                                                          ['D01']!['Deg']![0]
                                                      .toString(),
                                                  1),
                                              textBlock('NA', 1),
                                              textBlock('NA', 1),
                                              textBlock('NA', 1),
                                              textBlock('NA', 1),
                                              textBlock('NA', 1),
                                              textBlock('NA', 1),
                                              textBlock('NA', 1),
                                              textBlock('NA', 1),
                                              textBlock(
                                                  widget.user.birthsunrise!
                                                      .toString(),
                                                  1),
                                              textBlock(
                                                  widget.user.birthsunset!
                                                      .toString(),
                                                  1),
                                              textBlock('NA', 1),
                                              textBlock('23.29472°', 1),
                                              textBlock('NA', 1),
                                              textBlock('NA', 1),
                                              textBlock('NA', 1),
                                            ],
                                          ),

                                          /* Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (int i = 0; i < 22; i++)
                                  Text(
                                    'Hello + $i',
                                    style: TextStyle(fontSize: 20),
                                  )
                              ]), */
                                        ],
                                      ),
                                    ]),
                              ),
                            );
                          }
                        }
                        return Container();
                      }),
                  Container(
                      color: Colors.blue,
                      child: DataTable(
                        columnSpacing: 2,
                        dataRowHeight: 22,
                        columns: [
                          DataColumn(label: textBlock('Graha', 1)),
                          DataColumn(label: textBlock('R', 1)),
                          DataColumn(label: textBlock('Degree', 1)),
                          DataColumn(label: textBlock('Rasi', 1)),
                          DataColumn(label: textBlock('No', 1)),
                          DataColumn(label: textBlock('Nakshatra', 1)),
                          DataColumn(label: textBlock('Pada', 1)),
                          DataColumn(label: textBlock('Amsa', 1)),
                        ],
                        rows: [
                          for (int i = 0; i < 10; i++)
                            DataRow(cells: [
                              DataCell(_dataColumn(35, 20, grahas[i], 1)),
                              i < 8
                                  ? (grahaData[1]['D01']!['Spd']![i]) < 0
                                      ? DataCell(_dataColumn(5, 20, 'R', 1))
                                      : DataCell(_dataColumn(5, 20, '', 1))
                                  : DataCell(_dataColumn(5, 20, '', 1)),
                              DataCell(_dataColumn(
                                  38,
                                  20,
                                  grahaData[1]['D01']!['Deg']![i]
                                      .toStringAsFixed(2),
                                  1)),
                              DataCell(_dataColumn(
                                  18, 20, grahaData[1]['D01']!['Rnm']![i], 1)),
                              DataCell(_dataColumn(
                                  15,
                                  20,
                                  (grahaData[1]['D01']!['Rin']![i] + 1)
                                      .toString(),
                                  1)),
                              DataCell(textBlock(
                                  grahaData[1]['D01']!['NkN']![i], 1)),
                              DataCell(textBlock(
                                  (grahaData[1]['D01']!['Pad']![i]).toString(),
                                  1)),
                              DataCell(textBlock(
                                  (sortedList[8]['_kar']).toString(), 1)),
                            ])
                        ],
                      )),
                  const Text('Tab3')
                ],
              )),
        ));
  }

  Widget textBlock(String text, int txtstyle) {
    return Text(
      text,
      style: paraStyle,
    );
  }

  String _dateToString(DateTime indate) {
    var outdate = DateFormat('dd-MM-yyyy').format(indate);
    return outdate;
  }

  DateTime _stringToDate(String indate) {
    var outdate = DateFormat('yyyy-MM-dd').parse(indate);
    return outdate;
  }

  Widget _dataColumn(double wdth, double hgt, String txt, int txtstyl) {
    return Container(
      width: wdth,
      height: hgt,
      child: textBlock(txt, txtstyl),
    );
  }
}
