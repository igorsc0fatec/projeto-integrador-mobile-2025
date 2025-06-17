// UsuarioModel.dart
class UsuarioModel {
  final int? id;
  final String email;
  final bool emailVerificado;
  final bool contaAtiva;
  final String tipoUsuario;
  final DateTime dataCriacao;

  UsuarioModel({
    this.id,
    required this.email,
    required this.emailVerificado,
    required this.contaAtiva,
    required this.tipoUsuario,
    required this.dataCriacao,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id_usuario'],
      email: map['email_usuario'] ?? '',
      emailVerificado: map['email_verificado'] == 1,
      contaAtiva: map['conta_ativa'] == 1,
      tipoUsuario: map['tipo_usuario'] ?? '',
      dataCriacao: DateTime.parse(map['data_criacao']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_usuario': id,
      'email_usuario': email,
      'email_verificado': emailVerificado ? 1 : 0,
      'conta_ativa': contaAtiva ? 1 : 0,
      'tipo_usuario': tipoUsuario,
      'data_criacao': dataCriacao.toIso8601String(),
    };
  }
}