class Session {
  static final Session _instance = Session._internal();

  factory Session() => _instance;

  Session._internal();

  String? confeitariaCodigo;
  int? idConfeitaria; // Adicione esta linha

  void clear() {
    confeitariaCodigo = null;
    idConfeitaria = null; // Limpa também o ID
  }
}