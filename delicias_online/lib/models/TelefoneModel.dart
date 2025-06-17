class TelefoneModel {
  final int id;
  final String numero;
  final int idDdd;
  final String ddd; // <- Adicione este campo (ex: "11", "21")
  final int idTipoTelefone;
  final String ufDdd;
  final String tipoTelefone;

  TelefoneModel({
    required this.id,
    required this.numero,
    required this.idDdd,
    required this.ddd, // <- Novo campo
    required this.idTipoTelefone,
    required this.ufDdd,
    required this.tipoTelefone,
  });

  factory TelefoneModel.fromMap(Map<String, dynamic> map) {
  return TelefoneModel(
    id: map['id_telefone'],
    numero: map['num_telefone'],
    idDdd: map['id_ddd'],
    ddd: map['ddd'], // <- Agora virá da API
    idTipoTelefone: map['id_tipo_telefone'],
    ufDdd: map['uf_ddd'] ?? '',
    tipoTelefone: map['tipo_telefone'] ?? '',
  );
}
  Map<String, dynamic> toMap() {
    return {
      'num_telefone': numero,
      'id_ddd': idDdd,
      'id_tipo_telefone': idTipoTelefone,
    };
  }
  String get numeroFormatado {
  final numeroLimpo = numero.replaceAll(RegExp(r'[^0-9]'), '');
  if (numeroLimpo.length == 9) {
    return '${numeroLimpo.substring(0, 5)}-${numeroLimpo.substring(5)}';
  }
  return numero;
}

}