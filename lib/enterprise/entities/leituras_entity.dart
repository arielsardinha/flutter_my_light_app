import 'package:my_light_app/enterprise/entities/leitura_entity.dart';

class LeiturasEntity {
  final List<LeituraEntity> leituras;

  LeiturasEntity({required this.leituras});

  ({int valorTotalKwh, double valorTotal}) calcularFaturaTotal() {
    double somaKwh = leituras.fold(
        0,
        (previousValue, element) =>
            previousValue + int.parse(element.contador));

    final valorTotalKwh = somaKwh.toInt();
    final valorTotalFatura = _calcularValorTotalFatura(somaKwh);

    return (
      valorTotalKwh: valorTotalKwh,
      valorTotal: valorTotalFatura,
    );
  }

  double _calcularValorTotalFatura(double somaKwh) {
    double valor = 0.0;

    if (somaKwh <= 30) {
      valor = somaKwh * 0.987;
    } else if (somaKwh <= 100) {
      valor = (30 * 0.987) + (somaKwh - 30) * 0.5527;
    } else if (somaKwh <= 220) {
      valor = (30 * 0.987) + (70 * 0.5527) + (somaKwh - 100) * 0.8749;
    } else {
      valor = (30 * 0.987) +
          (70 * 0.5527) +
          (120 * 0.8749) +
          (somaKwh - 220) * 0.94211;
    }

    return double.parse(valor.toStringAsFixed(2));
  }
}
