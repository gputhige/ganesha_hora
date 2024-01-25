import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:parashara_hora/screens/chartview.dart';
import 'package:parashara_hora/screens/inputscreen.dart';
import 'package:parashara_hora/screens/test1.dart';
import 'package:parashara_hora/screens/transit_screen.dart';
import 'package:parashara_hora/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweph/sweph.dart';

import '../models/users.dart';
import '../utils/databasehelper.dart';

class UserList extends StatefulWidget {
  final List<double> sizes;
  const UserList({Key? key, required this.sizes}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final dbHelper = DatabaseHelper.db;
  late List<Users> userdblist = [];
  Future? future;
  List<double> sizes = [];
  int selectedIndex = -1;
  int userId = 0;
  bool selected = false;

  DateTime birthdatetime = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    future = _future();
  }

  Future<int> _future() async {
    userdblist = await dbHelper.getUserList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("Width", widget.sizes[0]);
    prefs.setDouble("Height", widget.sizes[1] - widget.sizes[2]);

    return 0;
  }

  onTapped(int input) async {
    if (input == 1) {
      final result = await Get.to(() => const InputScreen());
      if (result != null) {
        userdblist = await dbHelper.getUserList();
        setState(() {});
      }
    }
    if (input == 2) {
      /*  final result = await Get.to(() => const Test(
            selection: 2,
          )); */
    } else if (input == 3) {
      if (selectedIndex == 0) {
        selected = false;
        selectedIndex = -1;
        // userdblist = await dbHelper.getUserList();
        setState(() {});
      } else {
        var res = await dbHelper.deleteUser(userId);
        if (res != 0) {
          selected = false;
          selectedIndex = -1;
          userdblist = await dbHelper.getUserList();
          setState(() {});
        }
      }
    } else if (input == 4) {
      selected = false;
      userId = selectedIndex;
      selectedIndex = -1;
      setState(() {});
      Get.to(
          () => TransitScreen(sizes: widget.sizes, user: userdblist[userId]));
    } else if (input == 5) {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: widget.sizes[0] * .95,
                            height: (widget.sizes[1] - widget.sizes[2]) * .9,
                            decoration: BoxDecoration(
                                border: Border.all(width: 5.0),
                                color: Colors.blue),
                            child: Column(children: [
                              textBlock('User List', headingStyle),
                              textBlock(
                                  'Sizes: ${widget.sizes[0]}', titleStyleBlack),
                              const SizedBox(
                                height: 20,
                              ),
                              DataTable(
                                columnSpacing: 90,
                                columns: [
                                  DataColumn(
                                      label:
                                          textBlock('Name', subHeadingStyle)),
                                  DataColumn(
                                      label: textBlock('Date  & Time of Birth',
                                          subHeadingStyle)),
                                  DataColumn(
                                      label: Text(
                                    'Sex',
                                    style: subHeadingStyle,
                                  )),
                                  DataColumn(
                                      label: textBlock(
                                          'Latitude', subHeadingStyle)),
                                  DataColumn(
                                      label: textBlock(
                                          'Longitude', subHeadingStyle)),
                                ],
                                rows: [
                                  for (int i = 0; i < userdblist.length; i++)
                                    DataRow(
                                        selected: i == selectedIndex,
                                        cells: [
                                          DataCell(textBlock(
                                              userdblist[i].name!, titleStyle)),
                                          DataCell(textBlock(
                                              DateFormat('dd-MM-yyyy hh:mm:ss')
                                                  .format(DateTime.parse(
                                                      userdblist[i]
                                                          .birthdttm!)),
                                              titleStyle)),
                                          DataCell(textBlock(
                                            userdblist[i].sex!,
                                            titleStyle,
                                          )),
                                          DataCell(textBlock(
                                              userdblist[i]
                                                  .birthlat!
                                                  .toString(),
                                              titleStyle)),
                                          DataCell(textBlock(
                                              userdblist[i]
                                                  .birthlong!
                                                  .toString(),
                                              titleStyle)),
                                        ],
                                        onSelectChanged: (value) {
                                          setState(() {
                                            selected = true;
                                            selectedIndex = i;
                                            userId = userdblist[i].id!;
                                          });
                                        }),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  selected
                                      ? const Text('')
                                      : elevatedButton(
                                          'Add User', Colors.black, 1),
                                  selected
                                      ? elevatedButton(
                                          'Edit User', Colors.amber, 2)
                                      : const Text(''),
                                  selected
                                      ? elevatedButton(
                                          'Delete User', Colors.red, 3)
                                      : const Text(''),
                                  selected
                                      ? elevatedButton(
                                          'View Chart', Colors.amber, 4)
                                      : const Text(''),
                                  elevatedButton('Exit', Colors.green, 5),
                                ],
                              )
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return Container();
          }),
    );
  }

  Widget textBlock(String text, TextStyle textstyle) {
    return Text(
      text,
      style: textstyle,
    );
  }

  Widget elevatedButton(String text, Color color, int version) {
    return ElevatedButton(
        onPressed: () {
          onTapped(version);
        },
        style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll<Color>(color)),
        child: textBlock(text, subTitleStyle));
  }
}
