class CasaModel {
  final String nomeProprietario;

  CasaModel({
    required this.nomeProprietario,
  });

  Map<String, dynamic> toJson() => {
        "nome_proprietario": nomeProprietario,
      };
}

class CasaResponseModel extends CasaModel {
  final String id;
  CasaResponseModel({
    required this.id,
    required super.nomeProprietario,
  });

  factory CasaResponseModel.fromJson(Map<String, dynamic> json) =>
      CasaResponseModel(
        id: json["id"].toString(),
        nomeProprietario: json["nomeProprietario"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "nome_proprietario": nomeProprietario,
      };
}
