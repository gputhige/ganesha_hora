class Users {
  static const tblUsers = 'users';
  static const colUserId = 'id';
  static const colUserName = 'name';
  static const colUserSex = 'sex';
  static const colUserLoc = 'location';
  static const colUserLong = 'birthlong';
  static const colUserLat = 'birthlat';
  static const colUserSunTimes = 'suntimes';
  static const colUserAscTimes = 'asctimes';
  static const colUserDesc = 'description';
  static const colUserDateTime = 'birthdttm';
  static const colUserBPos = 'planetpos';
  static const colUserBSpeed = 'planetspeed';
  static const colUserTPos = 'transitpos';
  static const colUserTSpeed = 'transitspeed';
  static const colUserUPos = 'upapos';
  static const colUserStamp = 'timestamp';

  Users(
      {this.id,
      this.name,
      this.sex,
      this.location,
      this.birthlong,
      this.birthlat,
      this.suntimes,
      this.asctimes,
      this.description,
      this.birthdttm,
      this.planetpos,
      this.planetspeed,
      this.transitpos,
      this.transitspeed,
      this.upapos,
      this.timestamp});

  int? id;
  String? name;
  String? sex;
  String? location;
  double? birthlong;
  double? birthlat;
  String? suntimes;
  String? asctimes;
  String? description;
  String? birthdttm;
  String? planetpos;
  String? planetspeed;
  String? transitpos;
  String? transitspeed;
  String? upapos;
  String? timestamp;

  Users.fromMap(Map<String, dynamic> map) {
    id = map[colUserId];
    name = map[colUserName];
    sex = map[colUserSex];
    location = map[colUserLoc];
    birthlong = map[colUserLong];
    birthlat = map[colUserLat];
    suntimes = map[colUserSunTimes];
    asctimes = map[colUserAscTimes];
    description = map[colUserDesc];
    birthdttm = map[colUserDateTime];
    planetpos = map[colUserBPos];
    planetspeed = map[colUserBSpeed];
    transitpos = map[colUserTPos];
    transitspeed = map[colUserTSpeed];
    upapos = map[colUserUPos];
    timestamp = map[colUserStamp];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colUserName: name,
      colUserSex: sex,
      colUserLoc: location,
      colUserLong: birthlong,
      colUserLat: birthlat,
      colUserSunTimes: suntimes,
      colUserAscTimes: asctimes,
      colUserDesc: description,
      colUserDateTime: birthdttm,
      colUserBPos: planetpos,
      colUserBSpeed: planetspeed,
      colUserTPos: transitpos,
      colUserTSpeed: transitspeed,
      colUserUPos: upapos,
      colUserStamp: timestamp
    };
    if (id != null) {
      map[colUserId] = id;
    }

    return map;
  }
}
