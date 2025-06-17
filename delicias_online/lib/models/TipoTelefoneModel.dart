
class TipoTelefoneModel {
  final int id;
  final String tipo;

  TipoTelefoneModel({
    required this.id,
    required this.tipo,
  });

  factory TipoTelefoneModel.fromMap(Map<String, dynamic> map) {
    return TipoTelefoneModel(
      id: int.parse(map['id_tipo_telefone'].toString()),
      tipo: map['tipo_telefone'].toString(),
    );
  }
}