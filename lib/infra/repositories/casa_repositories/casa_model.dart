class ProprietarioModel {
  final String nomeProprietario;

  const ProprietarioModel({
    required this.nomeProprietario,
  });

  Map<String, dynamic> toJson() => {
        "nomeProprietario": nomeProprietario,
      };
}

class ProprietarioResponseModel {
  final String id;
  final String nivelAcesso;
  final String nomeProprietario;

  ProprietarioResponseModel({
    required this.id,
    required this.nivelAcesso,
    required this.nomeProprietario,
  });

  factory ProprietarioResponseModel.fromJson(Map<String, dynamic> json) =>
      ProprietarioResponseModel(
        id: json["id"]?.toString() ?? json['casaId'].toString(),
        nivelAcesso: json["nivelAcesso"],
        nomeProprietario: json["nomeProprietario"],
      );

  Map<String, dynamic> toJson() => {
        "casaId": id,
        "nivelAcesso": nivelAcesso,
        "nomeProprietario": nomeProprietario,
      };
}
