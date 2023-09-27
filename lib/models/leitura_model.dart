class LeituraModel {
  final String contador, photo;
  final int dataInMilisegundos;

  static const double precoPorKwh = 0.8095;

  LeituraModel({
    required this.contador,
    required this.dataInMilisegundos,
    required this.photo,
  });

  factory LeituraModel.fromJson(Map<String, dynamic> json) {
    return LeituraModel(
      contador: json['contador'],
      dataInMilisegundos: json['dataInMilisegundos'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo': photo,
      'contador': contador,
      'dataInMilisegundos': dataInMilisegundos,
    };
  }
}
