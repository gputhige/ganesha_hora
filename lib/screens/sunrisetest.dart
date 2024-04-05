import 'package:flutter/material.dart';
import 'package:sweph/sweph.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SunRiseTest extends StatefulWidget {
  SunRiseTest({Key? key}) : super(key: key);

  @override
  State<SunRiseTest> createState() => _SunRiseTestState();
}

class _SunRiseTestState extends State<SunRiseTest> {
  Future? future;

/* String  serr[AS_MAXCH];
double epheflag = SEFLG_SWIEPH;
int gregflag = SE_GREG_CAL; */
  int year = 1960;
  int month = 3;
  int day = 5;

  @override
  void initState() {
    // TODO: implement initState
    future = _future();

    super.initState();
  }

  Future<int> _future() async {
    // userdblist = await dbHelper.getUserList();

    await Sweph.init(epheAssets: [
      "packages/sweph/assets/ephe/seas_18.se1", // For house calc
      "packages/sweph/assets/ephe/sefstars.txt", // For star name
      "packages/sweph/assets/ephe/seasnam.txt", // For asteriods
    ]);
    var tjd = Sweph.swe_julday(year, month, day, 0, CalendarType.SE_GREG_CAL);
    var dt = 80.6166 / 360;
    tjd = tjd - dt;
    var sunRise = Sweph.swe_rise_trans(
      tjd,
      HeavenlyBody.SE_SUN,
      '',
      SwephFlag.SEFLG_SWIEPH,
      RiseSetTransitFlag.SE_CALC_RISE | RiseSetTransitFlag.SE_BIT_HINDU_RISING,
      GeoPosition(80.6166, 16.5166),
      0,
      0,
    );
    var url = Uri.parse('https://ssd-api.jpl.nasa.gov/jd_cal.api?jd=$sunRise');
    var response = await http.read(url);
    var sunRiseDouble = json.decode(response);
    //var dte = Sweph.swe_revjul(tjd, CalendarType.SE_GREG_CAL);

    var sunSet = Sweph.swe_rise_trans(
      tjd,
      HeavenlyBody.SE_SUN,
      '',
      SwephFlag.SEFLG_SWIEPH,
      RiseSetTransitFlag.SE_CALC_SET | RiseSetTransitFlag.SE_BIT_HINDU_RISING,
      GeoPosition(80.6166, 16.5166),
      0,
      0,
    );
    url = Uri.parse('https://ssd-api.jpl.nasa.gov/jd_cal.api?jd=$sunSet');
    response = await http.read(url);
    var sunSetDouble = json.decode(response);

    print((sunRiseDouble['cd'].toString()).substring(11, 19));
    print(sunSetDouble['cd']);
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
