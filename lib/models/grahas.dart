class Grahas {
  static const tblGrahas = 'grahas';
  static const colGrahaId = 'id';
  static const colGrahaName = 'name';
  static const colGrahaSName = 'shortname';
  static const colGrahaDasaYears = 'dasayears';
  static const colGrahaDasaOrder = 'dasaorder';
  static const colGrahaDosha = 'dosha';
  static const colGrahaAilment = 'ailment';
  static const colGrahaResults = 'graharesults';
  static const colGrahaRelations = 'relations';
  static const colGrahaDignity = 'grahadignity';
  static const colGrahaFillerOne = 'fillerone';
  static const colGrahaFillerTwo = 'fillertwo';

  Grahas(
      {this.id,
      this.name,
      this.shortname,
      this.dasayears,
      this.dasaorder,
      this.dosha,
      this.ailment,
      this.graharesults,
      this.relations,
      this.grahadignity,
      this.fillerone,
      this.fillertwo});

  int? id;
  String? name;
  String? shortname;
  int? dasayears;
  int? dasaorder;
  String? dosha;
  String? ailment;
  String? graharesults;
  String? relations;
  String? grahadignity;
  String? fillerone;
  String? fillertwo;

  Grahas.fromMap(Map<String, dynamic> map) {
    id = map[colGrahaId];
    name = map[colGrahaName];
    shortname = map[colGrahaSName];
    dasayears = map[colGrahaDasaYears];
    dasaorder = map[colGrahaDasaOrder];
    dosha = map[colGrahaDosha];
    ailment = map[colGrahaAilment];
    graharesults = map[colGrahaResults];
    relations = map[colGrahaRelations];
    grahadignity = map[colGrahaDignity];
    fillerone = map[colGrahaFillerOne];
    fillertwo = map[colGrahaFillerTwo];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colGrahaName: name,
      colGrahaSName: shortname,
      colGrahaDasaYears: dasayears,
      colGrahaDasaOrder: dasaorder,
      colGrahaDosha: dosha,
      colGrahaAilment: ailment,
      colGrahaResults: graharesults,
      colGrahaRelations: relations,
      colGrahaDignity: grahadignity,
      colGrahaFillerOne: fillerone,
      colGrahaFillerTwo: fillertwo
    };
    if (id != null) {
      map[colGrahaId] = id;
    }

    return map;
  }
}
