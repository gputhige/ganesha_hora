import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/models/users.dart';
import 'package:parashara_hora/ui/text_input_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweph/sweph.dart';
import 'package:http/http.dart' as http;

import '../ui/theme.dart';
import '../utils/databasehelper.dart';
import '../utils/myfunctions.dart';

enum Sex { male, female, other }

enum Crdn { minutes, decimal }

class InputScreen extends StatefulWidget {
  const InputScreen({election, Key? key}) : super(key: key);

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final dbHelper = DatabaseHelper.db;

  Future? future;
  DateTime selectedDate = DateTime.now();
  double ascendant = 0;
  String selectedTime = DateFormat('hh:mm a').format(DateTime.now());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController longController = TextEditingController();
  final TextEditingController lattController = TextEditingController();
  double screenwd = 0, screenht = 0;
  Sex _sex = Sex.other;
  Crdn _crdn = Crdn.minutes;
  String tzonevalue = 'OTH';
  var items = ['UTC', 'IST', 'OTH'];
  String sex = '', sunR = '', sunS = '', crdn = '';
  /*  final List<double> planetDegree = [];
  final List<double> planetSpeed = []; */
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = _future();
  }

  Future<int> _future() async {
    // userdblist = await dbHelper.getUserList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    screenwd = prefs.get('Width') as double;
    screenht = prefs.get('Height') as double;
    await Sweph.init(epheAssets: [
      "packages/sweph/assets/ephe/seas_18.se1", // For house calc
      "packages/sweph/assets/ephe/sefstars.txt", // For star name
      "packages/sweph/assets/ephe/seasnam.txt", // For asteriods
    ]);

    return 0;
  }

  _getDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
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

        //selectedTime = DateFormat('h:mm a').format(pickedTime );
        if (selectedTime.length == 5) {
          min = int.parse((selectedTime.split(":")[0])) * 60 +
              int.parse(selectedTime.split(":")[1]);
        } else {
          if (selectedTime.split(":")[1].split(" ")[1] == "PM") {
            min = ((int.parse(selectedTime.split(":")[0]) + 12) * 60) +
                int.parse(selectedTime.split(":")[1].split(" ")[0]);
          } else {
            min = (int.parse(selectedTime.split(":")[0]) * 60) +
                int.parse(selectedTime.split(":")[1].split(" ")[0]);
          }
        }

        selectedDate = selectedDate.add(Duration(minutes: min));
      });
    }
  }

  getSwephData(DateTime birtdate, double latt, double long) {
    getAyanamsa();
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
                    width: screenwd * .8,
                    height: screenht * .9,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        Text(
                          'Enter Details',
                          style: subHeadingStyle,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        MyTextInputField(
                          title: 'Name',
                          hint: 'Enter Name ',
                          textStyle: paraBoldStyle,
                          controller: nameController,
                          textInputType: TextInputType.name,
                          textCapital: TextCapitalization.words,
                          containerWidth: 300,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyTextInputField(
                              title: 'Sex',
                              hint: 'Male ',
                              textStyle: paraBoldStyle,
                              textInputType: TextInputType.name,
                              textCapital: TextCapitalization.words,
                              containerWidth: 150,
                              widget: Radio<Sex>(
                                  value: Sex.male,
                                  groupValue: _sex,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      (states) => Colors.amber),
                                  onChanged: (val) {
                                    setState(() {
                                      _sex = Sex.male;
                                      sex = 'Male';
                                    });
                                  }),
                            ),
                            MyTextInputField(
                              title: '',
                              hint: 'Female ',
                              textStyle: paraBoldStyle,
                              textInputType: TextInputType.name,
                              textCapital: TextCapitalization.words,
                              containerWidth: 150,
                              widget: Radio<Sex>(
                                  value: Sex.female,
                                  groupValue: _sex,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      (states) => Colors.red),
                                  onChanged: (val) {
                                    setState(() {
                                      _sex = Sex.female;
                                      sex = 'Female';
                                    });
                                  }),
                            ),
                          ],
                        ),
                        MyTextInputField(
                            title: 'Birth Date',
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
                        MyTextInputField(
                            title: 'Birth Time',
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
                        MyTextInputField(
                          title: 'Time Zone',
                          hint: tzonevalue,
                          textStyle: paraBoldStyle,
                          textInputType: TextInputType.name,
                          textCapital: TextCapitalization.words,
                          containerWidth: 300,
                          widget: DropdownButton(
                              value: tzonevalue,
                              dropdownColor: Colors.black,
                              icon: const Icon(Icons.arrow_downward),
                              items: items.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  tzonevalue = value!;
                                });
                              }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyTextInputField(
                              title: 'Coordinates',
                              hint: 'Minutes ',
                              textStyle: paraBoldStyle,
                              textInputType: TextInputType.name,
                              textCapital: TextCapitalization.words,
                              containerWidth: 150,
                              widget: Radio<Crdn>(
                                  value: Crdn.minutes,
                                  groupValue: _crdn,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      (states) => Colors.amber),
                                  onChanged: (val) {
                                    setState(() {
                                      _crdn = Crdn.minutes;
                                      crdn = 'Minutes';
                                    });
                                  }),
                            ),
                            MyTextInputField(
                              title: '',
                              hint: 'Decimal ',
                              textStyle: paraBoldStyle,
                              textInputType: TextInputType.name,
                              textCapital: TextCapitalization.words,
                              containerWidth: 150,
                              widget: Radio<Crdn>(
                                  value: Crdn.decimal,
                                  groupValue: _crdn,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      (states) => Colors.red),
                                  onChanged: (val) {
                                    setState(() {
                                      _crdn = Crdn.decimal;
                                      crdn = 'Decimal';
                                    });
                                  }),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyTextInputField(
                              title: 'Latitude: N + : S -',
                              hint: 'Enter Latitude ',
                              textStyle: paraBoldStyle,
                              textInputType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textCapital: TextCapitalization.none,
                              controller: lattController,
                              containerWidth: 150,
                            ),
                            MyTextInputField(
                              title: 'Longitude: E + : W -',
                              hint: 'Enter Longitude ',
                              textStyle: paraBoldStyle,
                              textInputType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              textCapital: TextCapitalization.none,
                              controller: longController,
                              containerWidth: 150,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
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
                                  if (nameController.text.isEmpty ||
                                      longController.text.isEmpty ||
                                      lattController.text.isEmpty) {
                                    Get.snackbar(
                                        'Enter full details', 'Data not saved',
                                        snackPosition: SnackPosition.BOTTOM);
                                  } else if (double.parse(lattController.text) >
                                          90 ||
                                      double.parse(lattController.text) < -90) {
                                    Get.snackbar(
                                        'Incorrect Latitude', 'Data not saved',
                                        snackPosition: SnackPosition.BOTTOM);
                                  } else if (double.parse(longController.text) >
                                          180 ||
                                      double.parse(longController.text) <
                                          -180) {
                                    Get.snackbar(
                                        'Incorrect Longitude', 'Data not saved',
                                        snackPosition: SnackPosition.BOTTOM);
                                  } else {
                                    setState(() {
                                      nameController.text = capitalizeAllWord(
                                          nameController.text);
                                    });

                                    getSwephData(
                                        selectedDate,
                                        double.parse(lattController.text),
                                        double.parse(longController.text));
                                  }
                                },
                                child: const Text('Save'))
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

  Widget textHead(String textin, double fontSize) {
    return Text(
      textin,
      style: TextStyle(
          fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  getPlanets(double asc, DateTime birthdate) async {
    double counter = 0;
    final julday = Sweph.swe_julday(
        birthdate.year,
        birthdate.month,
        birthdate.day,
        (birthdate.hour + birthdate.minute / 60) - 5.5,
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

    //Convert Decimal to Degree Min Sec
    /* for (int i = 0; i < planetPos.length; i++) {
      List<String> pbodies = [
        'Asc',
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

      double planetdouble = double.parse(planetPos[i]);
      int deg = planetdouble.ceil() - 1;
      planetdouble = (planetdouble - (planetdouble.ceil() - 1)) * 10000;
      int min = ((planetdouble.ceil() - 1) / 10000 * 60).ceil() - 1;
      planetdouble = (planetdouble / 10 * 60);
      planetdouble =
          ((planetdouble / 1000) - ((planetdouble / 1000).ceil() - 1));
      int sec = ((planetdouble * 60).ceil()) - 1;
      //print('${pbodies[i]} ${planetPos[i]} $deg $min $sec');
    } */

    //Get SunRise SunSet============================
    //var res = await _fetchSunRise();
    var res = await _getSunTimes(lattController.text, longController.text,
        selectedDate.toString(), tzonevalue);

    //Convert Data to
    // Model===================
    if (res != 0) {
      Users user = (Users(
          name: nameController.text,
          sex: sex,
          birthlong: double.parse(longController.text),
          birthlat: double.parse(lattController.text),
          birthsunrise: sunR,
          birthsunset: sunS,
          description: "",
          birthdttm: birthdate.toString(),
          planetpos:
              planetPos.toString().replaceAll('[', '').replaceAll(']', ''),
          planetspeed:
              planetSpd.toString().replaceAll('[', '').replaceAll(']', ''),
          transitpos: "",
          transitspeed: ""));

      var res = await dbHelper.insertUsers(user);
      if (res != 0) {
        Get.back(result: 'Hello');
      }
    }

    //save Prefs data
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  /*  Future<int> _fetchSunRise() async {
    String lat = lattController.text,
        lng = longController.text,
        dte = selectedDate.toString(),
        tzone = tzonevalue;

    var url = Uri.parse(
        'https://api.sunrisesunset.io/json?lat=$lat&lng=$lng&timezone=$tzone&date=$dte');
    var response = await http.read(url);
    Map<String, dynamic> sunrise = json.decode(response);

    if (sunrise.isNotEmpty) {
      
      sunR = (sunrise['results']['sunrise']).toString();
      sunS = (sunrise['results']['sunset']).toString();
    }
    double hrmnse =
        await timeToSecs((selectedDate.toString().substring(11, 18)));
    double sunris = await timeToSecs('0${sunR.substring(0, 8)}');
    if (hrmnse > sunris) {
      dte = (selectedDate.subtract(Duration(days: 1))).toString();
      url = Uri.parse(
          'https://api.sunrisesunset.io/json?lat=$lat&lng=$lng&timezone=$tzone&date=$dte');
      var response = await http.read(url);
    } else {
      print('Past');
    }

    print('Birth: $hrmnse $sunris');
    //Get 3 datapoints of SunRise to SunRise

    return 1;
  } */

  Future<List<int>> _getSunTimes(
      String lat, String lng, String dte, String tzone) async {
    List<int> sunTimesInt = [];
    List<String> sunTimesStr = [];
    int hrmnse = await timeToSecs((selectedDate.toString().substring(11, 18)));
    Map<String, dynamic> sunrise = await _sunTimeAPI(lattController.text,
        longController.text, selectedDate.toString(), tzonevalue);

    if (sunrise.isNotEmpty) {
      int sunRinSecs = await timeToSecs(
          '0${((sunrise['results']['sunrise']).toString()).substring(0, 7)}');
      int sunSetSecs = await timeToSecs(
              '0${((sunrise['results']['sunset']).toString()).substring(0, 7)}') +
          (3600 * 12);
      if (hrmnse > sunRinSecs) {
        sunTimesInt.add(sunRinSecs);
        sunTimesInt.add(sunSetSecs);
        sunTimesStr.add((sunrise['results']['sunrise']).substring(0, 7));
        sunTimesStr.add((sunrise['results']['sunset'].substring(0, 7)));

        sunrise = await _sunTimeAPI(lattController.text, longController.text,
            (selectedDate.add(const Duration(days: 1))).toString(), tzonevalue);
        sunRinSecs = await timeToSecs(
            '0${((sunrise['results']['sunrise']).toString()).substring(0, 7)}');
        sunTimesInt.add(sunRinSecs);
        sunTimesStr.add((sunrise['results']['sunrise'].substring(0, 7)));
      } else {
        sunrise = await _sunTimeAPI(
            lattController.text,
            longController.text,
            (selectedDate.subtract(const Duration(days: 1))).toString(),
            tzonevalue);
        sunRinSecs = await timeToSecs(
            '0${((sunrise['results']['sunrise']).toString()).substring(0, 7)}');
        sunSetSecs = await timeToSecs(
            '0${((sunrise['results']['sunset']).toString()).substring(0, 7)}');
        sunTimesInt.add(sunRinSecs);
        sunTimesInt.add(sunSetSecs);
      }
    }
    print(
        'Birth / Sun Times: $hrmnse ${sunTimesInt.toList()} ${sunTimesStr.toList()}');

    return sunTimesInt;
  }

  Future<Map<String, dynamic>> _sunTimeAPI(
      String lat, String lng, String dte, String tzone) async {
    Map<String, dynamic> suntime;
    var url = Uri.parse(
        'https://api.sunrisesunset.io/json?lat=$lat&lng=$lng&timezone=$tzone&date=$dte');
    var response = await http.read(url);
    suntime = json.decode(response);

    return suntime;
  }

  //fetch SunRise to SunRise
//Get Sunrise datapoints
  /* double hrmnse =
        await (timeToSecs(widget.user.birthdttm!.substring(11, 19)));
    print(hrmnse);
    print(
        '${widget.user.birthlong} ${widget.user.birthlat} ${widget.user.birthdttm}');
    double lng = widget.user.birthlong!;
    double lat = widget.user.birthlat!;
    String dte = widget.user.birthdttm!.substring(0, 10);
    String tzone = "5:30";
    var url = Uri.parse(
        'https://api.sunrisesunset.io/json?lat=$lat&lng=$lng&timezone=$tzone&date=$dte');
    var response = await http.read(url);
    Map<String, dynamic> sunrise = json.decode(response);
    if (sunrise.isNotEmpty) {
      /* String sunR = sunrise['results']['sunrise'];
      String sunS = sunrise['results']['suneet']; */
      double sunR = await timeToSecs(
          '0${((sunrise['results']['sunrise']).toString()).substring(0, 8)}');
      double sunS = await timeToSecs(
          '0${((sunrise['results']['sunset']).toString()).substring(0, 8)}');
      sunS = sunS + (3600 * 12);
      if (sunR > hrmnse) {
        print('Previous');
      } else {
        print('Next');
      }
      print('Sunrise $sunR $sunS');
    } */

  //Convert Text to UpperCase
  String capitalizeAllWord(String value) {
    var result = value[0].toUpperCase();
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " ") {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i];
      }
    }
    return result;
  }
}
