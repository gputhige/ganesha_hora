class Nakshatra {
  static const tblNakshatra = 'nakshatras';
  static const colNakId = 'id';
  static const colNakName = 'name';
  static const colNakDegEnd = 'degend';
  static const colNakLord = 'lord';
  static const colNakDeity = 'deity';

  Nakshatra({this.id, this.name, this.degend, this.lord, this.deity});

  int? id;
  String? name;
  double? degend;
  String? lord;
  String? deity;

  Nakshatra.fromMap(Map<String, dynamic> map) {
    id = map[colNakId];
    name = map[colNakName];
    degend = map[colNakDegEnd];
    lord = map[colNakLord];
    deity = map[colNakDeity];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colNakName: name,
      colNakDegEnd: degend,
      colNakLord: lord,
      colNakDeity: deity
    };
    if (id != null) {
      map[colNakId] = id;
    }

    return map;
  }
}
