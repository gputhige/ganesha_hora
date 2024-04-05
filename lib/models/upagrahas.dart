class Upagrahas {
  static const tblUpa = 'upagraha';
  static const colUpaId = 'id';
  static const colUpaKaala = 'kaala';
  static const colUpaMrityu = 'mrityu';
  static const colUpaArtha = 'artha';
  static const colUpaYama = 'yama';
  static const colUpaGulika = 'gulika';
  static const colUpaMaandi = 'maandi';

  Upagrahas(
      {this.id,
      this.kaala,
      this.mrityu,
      this.artha,
      this.yama,
      this.gulika,
      this.maandi});

  int? id;
  String? kaala;
  String? mrityu;
  String? artha;
  String? yama;
  String? gulika;
  String? maandi;

  Upagrahas.fromMap(Map<String, dynamic> map) {
    id = map[colUpaId];
    kaala = map[colUpaKaala];
    mrityu = map[colUpaMrityu];
    artha = map[colUpaArtha];
    yama = map[colUpaYama];
    gulika = map[colUpaGulika];
    maandi = map[colUpaMaandi];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colUpaKaala: kaala,
      colUpaMrityu: mrityu,
      colUpaArtha: artha,
      colUpaYama: yama,
      colUpaGulika: gulika,
      colUpaMaandi: maandi
    };
    if (id != null) {
      map[colUpaId] = id;
    }
    return map;
  }
}
