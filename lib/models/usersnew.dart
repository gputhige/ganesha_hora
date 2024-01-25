class UsersNew {
  static const tblUsersNew = 'usersnew';
  static const colUserNewId = 'id';
  static const colUserNewName = 'name';
  static const colUserNewDateTime = 'birthdttm';
  static const colUserNewLong = 'birthlong';
  static const colUserNewLat = 'birthlat';
  static const colUserNewDesc = 'description';
  static const colUserNewPos = 'position';
  static const colUserNewSpeed = 'speed';

  UsersNew(
      {this.id,
      this.name,
      this.birthlong,
      this.birthlat,
      this.description,
      this.birthdttm,
      this.position,
      this.speed});

  int? id;
  String? name;
  double? birthlong;
  double? birthlat;
  String? description;
  String? birthdttm;
  String? position;
  String? speed;

  UsersNew.fromMap(Map<String, dynamic> map) {
    id = map[colUserNewId];
    name = map[colUserNewName];
    birthlong = map[colUserNewLong];
    birthlat = map[colUserNewLat];
    description = map[colUserNewDesc];
    birthdttm = map[colUserNewDateTime];
    position = map[colUserNewPos];
    speed = map[colUserNewSpeed];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colUserNewName: name,
      colUserNewLong: birthlong,
      colUserNewLat: birthlat,
      colUserNewDesc: description,
      colUserNewDateTime: birthdttm,
      colUserNewPos: position,
      colUserNewSpeed: speed
    };
    if (id != null) {
      map[colUserNewId] = id;
    }

    return map;
  }
}
