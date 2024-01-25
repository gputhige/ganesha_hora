class UserData {
  static const tblUsers = 'usersdata';
  static const colUserId = 'id';
  static const colUserName = 'name';
  static const colUserSex = 'sex';
  static const colUserLong = 'birthlong';
  static const colUserLat = 'birthlat';
  static const colUserBSRise = 'birthsunrise';
  static const colUserBSSet = 'birthsunset';
  static const colUserDesc = 'description';
  static const colUserDateTime = 'birthdttm';
  static const colUserBPos = 'planetpos';
  static const colUserBSpeed = 'planetspeed';
  static const colUserTPos = 'transitpos';
  static const colUserTSpeed = 'transitspeed';

  UserData(
      {this.id,
      this.name,
      this.sex,
      this.birthlong,
      this.birthlat,
      this.birthsunrise,
      this.birthsunset,
      this.description,
      this.birthdttm,
      this.planetpos,
      this.planetspeed,
      this.transitpos,
      this.transitspeed});

  int? id;
  String? name;
  String? sex;
  double? birthlong;
  double? birthlat;
  String? birthsunrise;
  String? birthsunset;
  String? description;
  String? birthdttm;
  List<double>? planetpos;
  List<double>? planetspeed;
  List<double>? transitpos;
  List<double>? transitspeed;

  UserData.fromMap(Map<String, dynamic> map) {
    id = map[colUserId];
    name = map[colUserName];
    sex = map[colUserSex];
    birthlong = map[colUserLong];
    birthlat = map[colUserLat];
    birthsunrise = map[colUserBSRise];
    birthsunset = map[colUserBSSet];
    description = map[colUserDesc];
    birthdttm = map[colUserDateTime];
    planetpos = map[colUserBPos];
    planetspeed = map[colUserBSpeed];
    transitpos = map[colUserTPos];
    transitspeed = map[colUserTSpeed];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colUserName: name,
      colUserSex: sex,
      colUserLong: birthlong,
      colUserLat: birthlat,
      colUserBSRise: birthsunrise,
      colUserBSSet: birthsunset,
      colUserDesc: description,
      colUserDateTime: birthdttm,
      colUserBPos: planetpos,
      colUserBSpeed: planetspeed,
      colUserTPos: transitpos,
      colUserTSpeed: transitspeed
    };
    if (id != null) {
      map[colUserId] = id;
    }

    return map;
  }
}
