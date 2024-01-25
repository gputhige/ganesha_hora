import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/screens/chartview2.dart';
import 'package:sweph/sweph.dart';

import '../models/users.dart';
import '../ui/text_input_widget.dart';
import '../ui/theme.dart';
import '../utils/databasehelper.dart';

class TransitScreen extends StatefulWidget {
  final List<double> sizes;
  final Users user;
  const TransitScreen({Key? key, required this.sizes, required this.user})
      : super(key: key);

  @override
  State<TransitScreen> createState() => _TransitScreenState();
}

class _TransitScreenState extends State<TransitScreen> {
  final dbHelper = DatabaseHelper.db;
  Future? future;
  DateTime selectedDate = DateTime.now();
  String selectedTime = DateFormat('hh:mm a').format(DateTime.now());
  double ascendant = 0;
  List<HeavenlyBody> planet = [
    HeavenlyBody.SE_SUN,
    HeavenlyBody.SE_MOON,
    HeavenlyBody.SE_MERCURY,
    HeavenlyBody.SE_VENUS,
    HeavenlyBody.SE_MARS,
    HeavenlyBody.SE_JUPITER,
    HeavenlyBody.SE_SATURN,
    HeavenlyBody.SE_MEAN_NODE
  ];
  List<String> transitPos = [];
  List<String> transitSpd = [];
  List<Users> singleUser = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = _future();
  }

  Future<int> _future() async {
    // userdblist = await dbHelper.getUserList();
    await Sweph.init(epheAssets: [
      "packages/sweph/assets/ephe/seas_18.se1", // For house calc
      "packages/sweph/assets/ephe/sefstars.txt", // For star name
      "packages/sweph/assets/ephe/seasnam.txt", // For asteriods
    ]);

    return 0;
  }

  getSwephData(DateTime birtdate, double latt, double long) {
    HouseCuspData houseData = HouseCuspData([0], [0]);
    HouseCuspData houseSystemAscmc = getHouseSystemAscmc(birtdate, latt, long);

    if (houseSystemAscmc.cusps[1] > 0) {
      ascendant = houseSystemAscmc.cusps[1];
      getPlanets(ascendant, selectedDate);
    }
  }

  static HouseCuspData getHouseSystemAscmc(
      DateTime birthdate, double birthlat, double birthlong) {
    final year = birthdate.year;
    final month = birthdate.month;
    final day = birthdate.day;
    final hour = (birthdate.hour + birthdate.minute / 60) - 5.5;
    final latitude = birthlat;
    final longitude = birthlong;
    final julday =
        Sweph.swe_julday(year, month, day, hour, CalendarType.SE_GREG_CAL);

    //print('$birthdate, $birthlat, $birthlong');
    return Sweph.swe_houses_ex2(
        julday, SwephFlag.SEFLG_SIDEREAL, latitude, longitude, Hsys.P);
  }

  _getDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1950),
        lastDate: DateTime.now());

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  _getTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 6, minute: 30),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (pickedTime != null) {
      setState(() {
        int min = 0;
        selectedTime = pickedTime.format(context);
        if (selectedTime.split(":")[1].split(" ")[1] == "PM") {
          min = ((int.parse(selectedTime.split(":")[0]) + 12) * 60) +
              int.parse(selectedTime.split(":")[1].split(" ")[0]);
        } else {
          min = (int.parse(selectedTime.split(":")[0]) * 60) +
              int.parse(selectedTime.split(":")[1].split(" ")[0]);
        }
        selectedDate = selectedDate.add(Duration(minutes: min));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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
                return SafeArea(
                    child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        border: Border.all(width: 2.0), color: Colors.blue),
                    width: MediaQuery.of(context).size.width * .35,
                    height: MediaQuery.of(context).size.height * .9,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        Text(
                          'Select Date for Transit Positions',
                          style: subHeadingStyle,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        MyTextInputField(
                            title: 'Transit Date',
                            hint: DateFormat('dd-MM-yyyy').format(selectedDate),
                            textStyle: paraBoldStyle,
                            textInputType: TextInputType.name,
                            textCapital: TextCapitalization.words,
                            containerWidth: 300,
                            widget: IconButton(
                              icon: const Icon(Icons.calendar_month),
                              onPressed: () {
                                _getDate();
                              },
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        MyTextInputField(
                            title: 'Transit Time',
                            hint: selectedTime,
                            textStyle: paraBoldStyle,
                            textInputType: TextInputType.name,
                            textCapital: TextCapitalization.words,
                            containerWidth: 300,
                            widget: IconButton(
                              icon: const Icon(Icons.alarm),
                              onPressed: () {
                                _getTime();
                              },
                            )),
                        const SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.red)),
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('Cancel')),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => Colors.green)),
                                onPressed: () {
                                  getSwephData(
                                      selectedDate,
                                      widget.user.birthlat!,
                                      widget.user.birthlong!);
                                },
                                child: const Text('Get Data')),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ));
              }
              return Container(child: Text('No DATA'));
            }));
  }

  getPlanets(double asc, DateTime birthdate) async {
    double counter = 0;
    final julday = Sweph.swe_julday(
        birthdate.year,
        birthdate.month,
        birthdate.day,
        (birthdate.hour + birthdate.minute / 60) - 3.5,
        CalendarType.SE_GREG_CAL);

    /* int ascMovement = 0;
    if (asc / 30 > 0) {
      ascMovement = (asc ~/ 30) + 1;
    } else {
      ascMovement = (asc ~/ 30);
    } */
    //Ascendant Calculation=======================
    transitPos.add("$asc");
    transitSpd.add("0");

    //get Planet Speeds==========================
    for (int i = 0; i < 8; i++) {
      double speed =
          (Sweph.swe_calc_ut(julday, planet[i], SwephFlag.SEFLG_SPEED)
              .speedInLongitude);

      transitSpd.add("$speed");
      if (i == 7) {
        counter = speed;
      }
    }
    //Ketu Speed=================================
    transitSpd.add("$counter");

    //Other Planet calculations===================
    counter = 0;
    for (int i = 0; i < 8; i++) {
      double degree =
          (Sweph.swe_calc_ut(julday, planet[i], SwephFlag.SEFLG_SIDEREAL)
              .longitude);

      transitPos.add("$degree");
      if (i == 7) {
        counter = degree;
      }
    }
    //Ketu Calculation==============================
    transitPos.add("${counter + 180}");

    var res = await dbHelper.updateUser(
        widget.user.id!,
        transitPos.toString().replaceAll('[', '').replaceAll(']', ''),
        transitSpd.toString().replaceAll('[', '').replaceAll(']', ''));
    if (res != 0) {
      singleUser = await dbHelper.getUser(widget.user.id!);
    }

    Get.to(() => ChartViewTwo(user: singleUser[0]));
  }
}
