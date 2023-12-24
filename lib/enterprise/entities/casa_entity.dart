enum CasaNivelDeAcessoEnum {
  MORADOR,
  ADM;

  static CasaNivelDeAcessoEnum fromJson(String nivelAcesso) {
    switch (nivelAcesso) {
      case 'ADM':
        return CasaNivelDeAcessoEnum.ADM;
      default:
        return CasaNivelDeAcessoEnum.MORADOR;
    }
  }
}

class CasaEntity {
  final String proprietario;
  final String id;
  final CasaNivelDeAcessoEnum nivelDeAcesso;
  CasaEntity({
    required this.nivelDeAcesso,
    required this.id,
    required this.proprietario,
  });
}
