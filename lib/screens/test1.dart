import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/ui/text_input_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweph/sweph.dart';
import 'package:http/http.dart' as http;

import '../ui/theme.dart';
import '../utils/databasehelper.dart';

enum Sex { male, female, other }

class Test extends StatefulWidget {
  final int selection;
  const Test({required this.selection, Key? key}) : super(key: key);

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
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
  String tzonevalue = 'IST';
  var items = ['UTC', 'IST', 'OTH'];
  String sex = '', sunR = '', sunS = '';
  /*  final List<double> planetDegree = [];
  final List<double> planetSpeed = []; */
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
    nameController.text = 'Giridhar';
    lattController.text = '16.31';
    longController.text = '80.37';

    selectedDate =
        DateFormat('yyyy-MM-dd hh:mm:ss').parse('1960-12-05 18:30:00.000');
    print(selectedDate);
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

        selectedDate =
            DateFormat('yyyy-mm-dd').parse('1960-12-05 18:30:00.000');
        print(selectedDate);
      });
    }
  }

  getSwephData(DateTime birtdate, double latt, double long) {
    getAyanamsa(birtdate, latt, long);
    HouseCuspData houseData = HouseCuspData([0], [0]);
    HouseCuspData houseSystemAscmc = getHouseSystemAscmc(birtdate, latt, long);

    if (houseSystemAscmc.cusps[1] > 0) {
      ascendant = houseSystemAscmc.cusps[1];
      print('Asc : $ascendant');
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
    print('Ayanamsa');
    print(Sweph.swe_get_ayanamsa_ex_ut(julday, SwephFlag.SEFLG_SIDEREAL));
    print(Sweph.swe_get_ayanamsa_name(SiderealMode.SE_SIDM_LAHIRI));

    return Sweph.swe_houses_ex2(
        julday, SwephFlag.SEFLG_SIDEREAL, latitude, longitude, Hsys.P);
  }

  getAyanamsa(DateTime birthdate, double birthlat, double birthlong) {
    Sweph.swe_set_sid_mode(SiderealMode.SE_SIDM_LAHIRI_1940,
        SiderealModeFlag.SE_SIDBIT_NONE, 0.0, 0.0);
  }

  void validateAndSave() {}

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
                    width: screenwd * .35,
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
                                child: const Text('Save')),
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
    planetPos.add("${counter + 180}");

    for (int i = 0; i < planetPos.length; i++) {
      double planetdouble = double.parse(planetPos[i]);
      int deg = planetdouble.ceil() - 1;
      planetdouble = (planetdouble - (planetdouble.ceil() - 1)) * 10000;
      int min = ((planetdouble.ceil() - 1) / 10000 * 60).ceil() - 1;
      planetdouble = (planetdouble / 10 * 60);
      planetdouble =
          ((planetdouble / 1000) - ((planetdouble / 1000).ceil() - 1));
      int sec = ((planetdouble * 60).ceil()) - 1;
      print('${pbodies[i]} ${planetPos[i]} $deg $min $sec');
    }

    //Get SunRise SunSet============================

    var res = await _fetchSunRise();
    if (res != 0) {
      /* Users user = (Users(
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

      var res = await dbHelper.insertUsers(user); */
      if (res != 0) {
        // Get.back(result: 'Hello');
      }
    }

    //Convert Data to User Model===================

    //save Prefs data
    SharedPreferences prefs = await SharedPreferences.getInstance();

    /*  prefs.setString(
        'BirthDate', DateFormat('yyyy-MM-dd HH:mm').format(birthdate));
    prefs.setStringList("User", [
      userdblist[0].name!,
      userdblist[0].birthdttm!,
      userdblist[0].birthlat!.toString(),
      userdblist[0].birthlong!.toString()
    ]); */

    /* Get.to(() => ChartView(
          housedata: planetDegree,
          ascendant: ascMovement,
        )); */
  }

  Future<int> _fetchSunRise() async {
    String lat = lattController.text,
        lng = longController.text,
        dte = selectedDate.toString(),
        tzone = tzonevalue;

    var url = Uri.parse(
        'https://api.sunrisesunset.io/json?lat=$lat&lng=$lng&timezone=$tzone&date=$dte');
    var response = await http.read(url);
    Map<String, dynamic> sunrise = json.decode(response);

    if (sunrise.isNotEmpty) {
      /* String sunR = sunrise['results']['sunrise'];
      String sunS = sunrise['results']['suneet']; */
      sunR = (sunrise['results']['sunrise']).toString();
      sunS = (sunrise['results']['sunset']).toString();
    }

    return 1;
  }

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
