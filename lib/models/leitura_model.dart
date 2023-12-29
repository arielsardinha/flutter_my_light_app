class LeituraModel {
  final int contador;
  final String? photo;
  final int dataInMilisegundos;

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
