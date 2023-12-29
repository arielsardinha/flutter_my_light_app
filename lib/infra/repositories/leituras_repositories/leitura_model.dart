import 'dart:io';

import 'package:dio/dio.dart';

class LeiturasModel {
  final List<LeituraModel> leituras;
  final int totalContadorPorDaCasa;
  final String casaId;

  LeiturasModel({
    required this.leituras,
    required this.totalContadorPorDaCasa,
    required this.casaId,
  });

  factory LeiturasModel.fromJson(Map<String, dynamic> json) => LeiturasModel(
        leituras: List<LeituraModel>.from(
            json["leituras"].map((x) => LeituraModel.fromJson(x))),
        totalContadorPorDaCasa: json["totalContadorPorDaCasa"],
        casaId: json["casaId"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "leituras": List<dynamic>.from(leituras.map((x) => x.toJson())),
        "totalContadorPorDaCasa": totalContadorPorDaCasa,
        "casaId": casaId,
      };
}

class LeituraModel {
  final DateTime createAt;
  final String id;
  final int contador;
  final String? photo;

  LeituraModel({
    required this.createAt,
    required this.id,
    required this.contador,
    required this.photo,
  });

  factory LeituraModel.fromJson(Map<String, dynamic> json) => LeituraModel(
        createAt: DateTime.parse(json["createAt"]),
        id: json["id"].toString(),
        contador: json["contador"],
        photo: json["photo"],
      );

  Map<String, dynamic> toJson() => {
        "createAt": createAt.toIso8601String(),
        "id": id,
        "contador": contador,
        "photo": photo,
      };
}

class LeituraCreateParamns {
  final int contador;
  final File? photo;
  final String casaId;

  LeituraCreateParamns(
      {required this.casaId, required this.contador, required this.photo});

  Map<String, dynamic> toJson() => {
        "casaId": casaId,
        "contador": contador,
        "photo": photo,
      };

  Future<FormData> getFormData() async {
    final data = FormData.fromMap({
      "casaId": casaId,
      "contador": contador,
      if (photo != null) "photo": await MultipartFile.fromFile(photo!.path),
    });
    return data;
  }
}

class LeiturasResumoModel {
  final int totalLeitura;
  final int consumo;
  final DateTime dataLeitura;

  LeiturasResumoModel({
    required this.totalLeitura,
    required this.consumo,
    required this.dataLeitura,
  });

  factory LeiturasResumoModel.fromJson(Map<String, dynamic> json) =>
      LeiturasResumoModel(
        totalLeitura: json["total_leitura"],
        consumo: json["consumo"],
        dataLeitura: DateTime.parse(json["data_leitura"]),
      );

  Map<String, dynamic> toJson() => {
        "total_leitura": totalLeitura,
        "consumo": consumo,
        "data_leitura": dataLeitura.toIso8601String(),
      };
}
