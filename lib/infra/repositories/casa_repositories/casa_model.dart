import 'package:equatable/equatable.dart';

class ProprietarioModel {
  final String nomeProprietario;

  const ProprietarioModel({
    required this.nomeProprietario,
  });

  Map<String, dynamic> toJson() => {
        "nome_proprietario": nomeProprietario,
      };
}

class ProprietarioResponseModel extends ProprietarioModel {
  final String id;
  const ProprietarioResponseModel({
    required this.id,
    required super.nomeProprietario,
  });

  factory ProprietarioResponseModel.fromJson(Map<String, dynamic> json) =>
      ProprietarioResponseModel(
        id: json["id"].toString(),
        nomeProprietario: json["nome_proprietario"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "casaId": id,
        "nome_proprietario": nomeProprietario,
      };
}