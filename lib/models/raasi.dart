class Raasi {
  static const tblRaasi = 'raasi';
  static const colRaasiId = 'id';
  static const colRaasiName = 'name';
  static const colRaasiDeg = 'degend';
  static const colRaasiLord = 'lord';
  static const colRaasiShortName = 'shortname';
  static const colRaasiOrder = 'rasiorder';

  Raasi(
      {this.id,
      this.name,
      this.degend,
      this.lord,
      this.shortname,
      this.rasiorder});

  int? id;
  String? name;
  int? degend;
  String? lord;
  String? shortname;
  int? rasiorder;

  Raasi.fromMap(Map<String, dynamic> map) {
    id = map[colRaasiId];
    name = map[colRaasiName];
    degend = map[colRaasiDeg];
    lord = map[colRaasiLord];
    shortname = map[colRaasiShortName];
    rasiorder = map[colRaasiOrder];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colRaasiName: name,
      colRaasiDeg: degend,
      colRaasiLord: lord,
      colRaasiShortName: shortname,
      colRaasiOrder: rasiorder
    };
    if (id != null) {
      map[colRaasiId] = id;
    }
    return map;
  }
}
