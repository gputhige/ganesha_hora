Future<double> listStrToDbl(String inputString, String comma, int index) async {
  double res = double.parse(inputString.split(comma)[index]);
  return res;
}

updateMap(Map<String, List<dynamic>> map, String row, String newvalue) {
  map.update(row, (list) => list..add(newvalue), ifAbsent: () => [newvalue]);
}

updateDblMap(
    Map<String, List<dynamic>> map, String row, List<double> newvalue) {
  map.update(row, (list) => list..add(newvalue), ifAbsent: () => [newvalue]);
}

//Reudce the value if exceeds the value of count
Future<int> reduceRasi(int rasi, int count) async {
  while (rasi >= count) {
    rasi = rasi - count;
  }
  return rasi;
}

//Create a List of Int with step values
Future<List<int>> everyNth(int start, int end, int step, int addon) async {
  // print('Nth details: $start, $end, $step');
  List<int> listNth = [];
  int count = 0;
  listNth.add(start + addon);
  for (int i = 0; i < end; i++) {
    if (step + count == i) {
      listNth.add(i + addon);
      count = count + step;
    }
  }
  return listNth;
}

//Convert String to Double
double textStringToDouble() {
  double value = 0;
  return value;
}

//Spread the Grahas within the Bhava
Future<List<double>> spreadValues(List<double> divPos) async {
  var counts = divPos.fold<Map<dynamic, int>>({}, (map, element) {
    map[element] = (map[element] ?? 0) + 1;
    return map;
  });

  var entries = counts.entries.toList();
  for (int i = 0; i < entries.length; i++) {
    int counter = 1;
    for (int p = 0; p < entries[i].value; p++) {
      for (int j = 0; j < divPos.length; j++) {
        if (divPos[j] == entries[i].key) {
          divPos[j] = divPos[j] + (30 / ((entries[i].value + 1)) * counter);
          //print('Spread Values: $j -  ${divPos[j]}');

          counter = counter + 1;
        }
      }
    }
    counter = 1;
  }
  return divPos;
}

int roundUp(value, roundup) {
  if (value <= roundup) {
    value = value + 12;
  }
  return value;
}

Future<String> decimalToTime(double value) async {
  String tme = '';
  var hr = value.truncate();
  double res = ((value - value.truncate()) * 10000).truncate().toDouble();
  var min = (res / 10000 * 60).truncate();
  var res2 = (res / 100 * 60).truncate();
  var sec = (res2 - (((res2 / 100).truncate()) * 100));
  sec = (sec / 100 * 60).truncate();
  tme = '$hr:$min:$sec';
  return tme;
}

Future<int> timeToSecs(String tme) async {
  List<int> times = [];
  times.add((int.parse(tme.split(':')[0])) * 3600);
  times.add((int.parse(tme.split(':')[1])) * 60);
  times.add((int.parse(tme.split(':')[2])));
  int hrmnse = times[0] + times[1] + times[2];

  return hrmnse;
}
