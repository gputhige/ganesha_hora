import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/models/users.dart';
import 'package:parashara_hora/screens/sunrisetest.dart';
import 'package:parashara_hora/screens/userlist.dart';
import 'package:parashara_hora/ui/text_input_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweph/sweph.dart';
import 'package:http/http.dart' as http;

import '../ui/theme.dart';
import '../utils/databasehelper.dart';
import '../utils/myfunctions.dart';

class SwephData extends StatefulWidget {
  final List<double> sizes;
  final DateTime birthdate;
  final double latt;
  final double long;
  final double timezone;
  const SwephData(
      {Key? key,
      required this.sizes,
      required this.birthdate,
      required this.latt,
      required this.long,
      required this.timezone})
      : super(key: key);

  @override
  State<SwephData> createState() => _SwephDataState();
}

class _SwephDataState extends State<SwephData> {
  final dbHelper = DatabaseHelper.db;

  Future? future;
  DateTime selectedDate = DateTime.now();
  DateTime? birthdate;
  double latitude = 0, longitude = 0, timeZone = 0;
  double ascendant = 0;
  double screenwd = 0, screenht = 0;
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
  List<String> planetPos = [];
  List<String> planetSpd = [];
  double tmeZone = 0;
  List<int> sunTimes = [];
  List<double> ascTimes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = _future();
  }

  Future<int> _future() async {
    // userdblist = await dbHelper.getUserList();
    /* SharedPreferences prefs = await SharedPreferences.getInstance();
    screenwd = prefs.get('Width') as double;
    screenht = prefs.get('Height') as double; */
    birthdate = widget.birthdate;
    latitude = widget.latt;
    longitude = widget.long;
    timeZone = widget.timezone;
    if (longitude > 0) {
      timeZone = timeZone * -1;
      tmeZone = timeZone;
    }
    await Sweph.init(epheAssets: [
      "packages/sweph/assets/ephe/seas_18.se1", // For house calc
      "packages/sweph/assets/ephe/sefstars.txt", // For star name
      "packages/sweph/assets/ephe/seasnam.txt", // For asteriods
    ]);
    getSwephData(widget.birthdate, widget.latt, widget.long, tmeZone);

    return 0;
  }

  getSwephData(DateTime birtdate, double latt, double long, double timezone) {
    getAyanamsa();
    HouseCuspData houseData = HouseCuspData([0], [0]);
    HouseCuspData houseSystemAscmc =
        getHouseSystemAscmc(birtdate, latt, long, timezone);

    if (houseSystemAscmc.cusps[1] > 0) {
      ascendant = houseSystemAscmc.cusps[1];
      getPlanets(ascendant, birtdate, timezone);
    }
  }

  static HouseCuspData getHouseSystemAscmc(
      DateTime birthdate, double birthlat, double birthlong, double timezone) {
    final year = birthdate.year;
    final month = birthdate.month;
    final day = birthdate.day;
    final hour = (birthdate.hour + birthdate.minute / 60) + timezone;
    final latitude = birthlat;
    final longitude = birthlong;
    final julday =
        Sweph.swe_julday(year, month, day, hour, CalendarType.SE_GREG_CAL);

    return Sweph.swe_houses_ex2(
        julday, SwephFlag.SEFLG_SIDEREAL, latitude, longitude, Hsys.P);
  }

  getAyanamsa() {
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI_1940,
        SiderealModeFlag.SE_SIDBIT_NONE, 0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueAccent,
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
                        border: Border.all(width: 2.0), color: Colors.amber),
                    width: widget.sizes[0] * .2,
                    height: widget.sizes[1] * .15,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        Text(
                          'Getting Sweph Data\nPlease Wait...',
                          style: titleStyleBlack,
                          textAlign: TextAlign.center,
                        )
                      ]),
                    ),
                  ),
                ));
              }
              return Container(child: Text('No DATA'));
            }));
  }

  getPlanets(double asc, DateTime birthdate, double timezone) async {
    double counter = 0;
    final julday = Sweph.swe_julday(
        birthdate.year,
        birthdate.month,
        birthdate.day,
        (birthdate.hour + birthdate.minute / 60) + timezone,
        CalendarType.SE_GREG_CAL);

    int ascMovement = 0;
    if (asc / 30 > 0) {
      ascMovement = (asc ~/ 30) + 1;
    } else {
      ascMovement = (asc ~/ 30);
    }
    //Ascendant Calculation=======================
    planetPos.add("$asc");
    planetSpd.add("0");

    //get Planet Speeds==========================
    for (int i = 0; i < 8; i++) {
      double speed =
          (Sweph.swe_calc_ut(julday, planet[i], SwephFlag.SEFLG_SPEED)
              .speedInLongitude);

      planetSpd.add("$speed");
      if (i == 7) {
        counter = speed;
      }
    }
    //Ketu Speed=================================
    planetSpd.add("$counter");

    //Other Planet calculations===================
    counter = 0;
    for (int i = 0; i < 8; i++) {
      double degree = (Sweph.swe_calc_ut(
        julday,
        planet[i],
        SwephFlag.SEFLG_SIDEREAL,
      ).longitude);

      planetPos.add("$degree");
      if (i == 7) {
        counter = degree;
      }
    }
    //Ketu Calculation==============================
    if ((counter + 180) > 360) {
      counter = counter - 360;
    }
    planetPos.add("${counter + 180}");

    //Get SunRise SunSet============================
    var res = await _getSunTimes();
    if (res != 0) {
      //Convert Data to Model===================
      if (res != 0) {
        Users user = (Users(
            name: 'name',
            sex: 'sex',
            location: 'location',
            birthlong: longitude,
            birthlat: latitude,
            suntimes:
                sunTimes.toString().replaceAll('[', '').replaceAll(']', ''),
            asctimes:
                ascTimes.toString().replaceAll('[', '').replaceAll(']', ''),
            description: "",
            birthdttm: birthdate.toString(),
            planetpos:
                planetPos.toString().replaceAll('[', '').replaceAll(']', ''),
            planetspeed:
                planetSpd.toString().replaceAll('[', '').replaceAll(']', ''),
            transitpos: "",
            transitspeed: "",
            timestamp: DateTime.now().toString()));

        var res = await dbHelper.insertUsers(user);
        if (res != 0) {
          Get.to(() => UserList(sizes: widget.sizes));
        }
      }
    }
    //save Prefs data
    // SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  Future<int> _getSunTimes() async {
    //Get SunRise Data
    dynamic prevSunRise =
        await _getSwephSunTimes(-1, 0, CalendarType.SE_GREG_CAL, true);
    //Get SunSet Data
    dynamic prevSunSet =
        await _getSwephSunTimes(-1, 0, CalendarType.SE_GREG_CAL, false);
    //Get SunRise Data
    dynamic currSunRise =
        await _getSwephSunTimes(0, 0, CalendarType.SE_GREG_CAL, true);
    dynamic currSunSet =
        await _getSwephSunTimes(0, 0, CalendarType.SE_GREG_CAL, false);
    dynamic nextSunRise =
        await _getSwephSunTimes(1, 0, CalendarType.SE_GREG_CAL, true);

    int prevSR =
        await timeToSecs(prevSunRise['cd'].toString().substring(11, 19));
    int prevSS =
        await timeToSecs(prevSunSet['cd'].toString().substring(11, 19));
    int currSR =
        await timeToSecs(currSunRise['cd'].toString().substring(11, 19));
    int currSS =
        await timeToSecs(currSunSet['cd'].toString().substring(11, 19));
    int nextSR =
        await timeToSecs(nextSunRise['cd'].toString().substring(11, 19));
    int finalbirth = await timeToSecs(
        '${widget.birthdate.hour.toString()}:${widget.birthdate.minute.toString()}:${widget.birthdate.second.toString()}');

    int finalZone = await timeToSecs(await decimalToTime(timeZone));
    finalZone = finalZone * -1;

    if ((currSR + finalZone) > (finalbirth)) {
      prevSR = prevSR + finalZone;
      if (prevSR < 0) {
        prevSR = prevSR + 86400;
      }
      HouseCuspData asc1 = await getAscendant(0, prevSR);
      prevSS = prevSS + finalZone;
      if (prevSS < 0) {
        prevSS = prevSS + 86400;
      }
      HouseCuspData asc2 = await getAscendant(0, prevSS);
      currSR = currSR + finalZone;
      if (currSR < 0) {
        currSR = currSR + 86400;
      }
      HouseCuspData asc3 = await getAscendant(0, currSR);
      sunTimes.add(0);
      sunTimes.add(prevSR);
      sunTimes.add(prevSS);
      sunTimes.add(currSR);
      print(sunTimes.toList());

      ascTimes.add(0);
      ascTimes.add(asc1.cusps[1]);
      ascTimes.add(asc2.cusps[1]);
      ascTimes.add(asc3.cusps[1]);
    } else {
      currSR = currSR + finalZone;
      if (currSR < 0) {
        currSR = currSR + 86400;
      }
      HouseCuspData asc1 = await getAscendant(0, currSR);
      currSS = currSS + finalZone;
      if (currSS < 0) {
        currSS = currSS + 86400;
      }
      HouseCuspData asc2 = await getAscendant(0, currSS);
      nextSR = nextSR + finalZone;
      if (nextSR < 0) {
        nextSR = nextSR + 86400;
      }
      HouseCuspData asc3 = await getAscendant(1, currSR);
      if (finalbirth > (currSS)) {
        sunTimes.add(2);
        ascTimes.add(2);
      } else {
        sunTimes.add(1);
        ascTimes.add(1);
      }
      sunTimes.add(currSR);
      sunTimes.add(currSS);
      sunTimes.add(nextSR);

      ascTimes.add(asc1.cusps[1]);
      ascTimes.add(asc2.cusps[1]);
      ascTimes.add(asc3.cusps[1]);
    }

    return 1;
  }

  Future<dynamic> _getSwephSunTimes(
      int dayChange, double hour, CalendarType seType, bool riseSet) async {
    dynamic sunRiseSet = '';
    final year = birthdate!.year;
    final month = birthdate!.month;
    final day = birthdate!.day + dayChange;
    final long = longitude;

    var tjd = Sweph.swe_julday(year, month, day, hour, seType);

    var dt = long / 360;
    tjd = tjd - dt;

    //SunRise calculations with NASA interpolation
    if (riseSet == true) {
      var sunRise = Sweph.swe_rise_trans(
        tjd,
        HeavenlyBody.SE_SUN,
        '',
        SwephFlag.SEFLG_SWIEPH,
        RiseSetTransitFlag.SE_CALC_RISE |
            RiseSetTransitFlag.SE_BIT_HINDU_RISING,
        GeoPosition(widget.long, widget.latt),
        0,
        0,
      );
      var url =
          Uri.parse('https://ssd-api.jpl.nasa.gov/jd_cal.api?jd=$sunRise');
      var response = await http.read(url);
      sunRiseSet = json.decode(response);
    } else {
      var sunSet = Sweph.swe_rise_trans(
        tjd,
        HeavenlyBody.SE_SUN,
        '',
        SwephFlag.SEFLG_SWIEPH,
        RiseSetTransitFlag.SE_CALC_SET | RiseSetTransitFlag.SE_BIT_HINDU_RISING,
        GeoPosition(widget.long, widget.latt),
        0,
        0,
      );
      var url = Uri.parse('https://ssd-api.jpl.nasa.gov/jd_cal.api?jd=$sunSet');
      var response = await http.read(url);
      sunRiseSet = json.decode(response);
    }

    return sunRiseSet;
  }

  Future<HouseCuspData> getAscendant(int day, int time) async {
    final date = birthdate!.day + day;
    double hour = (time / 3600) + tmeZone;

    final julday = Sweph.swe_julday(birthdate!.year, birthdate!.month, date,
        hour, CalendarType.SE_GREG_CAL);

    return Sweph.swe_houses_ex2(
        julday, SwephFlag.SEFLG_SIDEREAL, latitude, longitude, Hsys.P);
  }
}
