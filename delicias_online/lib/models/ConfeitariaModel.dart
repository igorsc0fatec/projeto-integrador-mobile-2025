// ConfeitariaModel.dart
class ConfeitariaModel {
  final int? id;
  final String nome;
  final String cnpj;
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String uf;
  final String horaAbertura;
  final String horaFechamento;
  final int? idUsuario;
  final String? latitude;
  final String? longitude;

  ConfeitariaModel({
    this.id,
    required this.nome,
    required this.cnpj,
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.horaAbertura,
    required this.horaFechamento,
    this.idUsuario,
    this.latitude,
    this.longitude,
  });

  factory ConfeitariaModel.fromMap(Map<String, dynamic> map) {
    return ConfeitariaModel(
      id: map['id_confeitaria'],
      nome: map['nome_confeitaria'] ?? '',
      cnpj: map['cnpj_confeitaria'] ?? '',
      cep: map['cep_confeitaria'] ?? '',
      logradouro: map['log_confeitaria'] ?? '',
      numero: map['num_local'] ?? '',
      complemento: map['complemento'],
      bairro: map['bairro_confeitaria'] ?? '',
      cidade: map['cidade_confeitaria'] ?? '',
      uf: map['uf_confeitaria'] ?? '',
      horaAbertura: map['hora_entrada'] ?? '',
      horaFechamento: map['hora_saida'] ?? '',
      idUsuario: map['id_usuario'],
      latitude: map['latitude']?.toString(),
      longitude: map['longitude']?.toString(),
    );
  }

  ConfeitariaModel copyWith({
    int? id,
    String? nome,
    String? cnpj,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? uf,
    String? horaAbertura,
    String? horaFechamento,
    int? idUsuario,
    String? latitude,
    String? longitude,
  }) {
    return ConfeitariaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      horaAbertura: horaAbertura ?? this.horaAbertura,
      horaFechamento: horaFechamento ?? this.horaFechamento,
      idUsuario: idUsuario ?? this.idUsuario,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_confeitaria': id,
      'nome_confeitaria': nome,
      'cnpj_confeitaria': cnpj,
      'cep_confeitaria': cep,
      'log_confeitaria': logradouro,
      'num_local': numero,
      'complemento': complemento,
      'bairro_confeitaria': bairro,
      'cidade_confeitaria': cidade,
      'uf_confeitaria': uf,
      'hora_entrada': horaAbertura,
      'hora_saida': horaFechamento,
      'id_usuario': idUsuario,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}