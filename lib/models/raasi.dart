class Raasi {
  static const tblRaasi = 'raasi';
  static const colRaasiId = 'id';
  static const colRaasiName = 'name';
  static const colRaasiDeg = 'degend';
  static const colRaasiLord = 'lord';
  static const colRaasiShortName = 'shortname';
  static const colRaasiOrder = 'rasiorder';
  static const colRaasiLSName = 'lshortname';

  Raasi(
      {this.id,
      this.name,
      this.degend,
      this.lord,
      this.shortname,
      this.rasiorder,
      this.lshortname});

  int? id;
  String? name;
  int? degend;
  String? lord;
  String? shortname;
  int? rasiorder;
  String? lshortname;

  Raasi.fromMap(Map<String, dynamic> map) {
    id = map[colRaasiId];
    name = map[colRaasiName];
    degend = map[colRaasiDeg];
    lord = map[colRaasiLord];
    shortname = map[colRaasiShortName];
    rasiorder = map[colRaasiOrder];
    lshortname = map[colRaasiLSName];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colRaasiName: name,
      colRaasiDeg: degend,
      colRaasiLord: lord,
      colRaasiShortName: shortname,
      colRaasiOrder: rasiorder,
      colRaasiLSName: lshortname
    };
    if (id != null) {
      map[colRaasiId] = id;
    }
    return map;
  }
}
