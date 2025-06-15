class Confeitaria {
  final int id;
  final String nome;
  final String cnpj;
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String uf;
  final double latitude;
  final double longitude;
  final String horaAbertura;
  final String horaFechamento;
  final int usuarioId;

  Confeitaria({
    required this.id,
    required this.nome,
    required this.cnpj,
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.latitude,
    required this.longitude,
    required this.horaAbertura,
    required this.horaFechamento,
    required this.usuarioId,
  });

  factory Confeitaria.fromJson(Map<String, dynamic> json) {
    return Confeitaria(
      id: json['id_confeitaria'],
      nome: json['nome_confeitaria'],
      cnpj: json['cnpj_confeitaria'],
      cep: json['cep_confeitaria'],
      logradouro: json['log_confeitaria'],
      numero: json['num_local'],
      complemento: json['complemento'],
      bairro: json['bairro_confeitaria'],
      cidade: json['cidade_confeitaria'],
      uf: json['uf_confeitaria'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      horaAbertura: json['hora_entrada'],
      horaFechamento: json['hora_saida'],
      usuarioId: json['id_usuario'],
    );
  }
}