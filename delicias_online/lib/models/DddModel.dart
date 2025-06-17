class DddModel {
  final int id;
  final String ddd;
  final String uf;

  DddModel({
    required this.id,
    required this.ddd,
    required this.uf,
  });

  factory DddModel.fromMap(Map<String, dynamic> map) {
    return DddModel(
      id: int.parse(map['id_ddd'].toString()), // Conversão explícita para int
      ddd: map['ddd'].toString(),
      uf: map['uf_ddd'].toString(),
    );
  }
}