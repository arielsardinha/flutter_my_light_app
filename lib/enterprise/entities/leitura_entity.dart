class LeituraEntity {
  final String contador, photo;
  final int dataInMilisegundos;

  LeituraEntity({
    required this.contador,
    required this.dataInMilisegundos,
    required this.photo,
  });

  double calcularValorKWH({
    required LeituraEntity? leituraAnterior,
  }) {
    if (leituraAnterior == null) {
      return 0.0;
    }

    final int diferencaKwh =
        int.parse(contador) - int.parse(leituraAnterior.contador);
    return diferencaKwh.toDouble();
  }
}
