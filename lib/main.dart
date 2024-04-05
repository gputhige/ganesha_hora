import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parashara_hora/screens/input_screen2.dart';
import 'package:parashara_hora/screens/sunrisetest.dart';
import 'package:parashara_hora/screens/userlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<double> sizes = [];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    sizes.add(MediaQuery.of(context).size.width);
    sizes.add(MediaQuery.of(context).size.height);
    sizes.add(MediaQuery.of(context).viewPadding.top);
    return GetMaterialApp(
      title: 'Parashara Hora',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            titleLarge: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            titleMedium: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            titleSmall: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 11,
            ),
            labelSmall: GoogleFonts.lato(color: Colors.black, fontSize: 13),
            bodyMedium: GoogleFonts.lato(color: Colors.white, fontSize: 14),
            bodySmall: GoogleFonts.lato(color: Colors.white, fontSize: 13),
            headlineLarge: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          )),
      debugShowCheckedModeBanner: false,
      home: InputScreen2(
        sizes: sizes,
      ),
      //home: UserList(sizes: sizes),
      //home: SunRiseTest()
    );
  }
}
