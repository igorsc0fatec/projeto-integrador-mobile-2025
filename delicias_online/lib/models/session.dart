class Session {
  static final Session _instance = Session._internal();

  factory Session() => _instance;

  Session._internal();

  String? confeitariaCodigo;
  int? idConfeitaria;
  int? idUsuario; // Adicionado para armazenar o ID do usuário diretamente

  void clear() {
    confeitariaCodigo = null;
    idConfeitaria = null;
    idUsuario = null;
  }
}