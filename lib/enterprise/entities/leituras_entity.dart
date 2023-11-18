import 'package:my_light_app/enterprise/entities/leitura_entity.dart';

class LeiturasEntity {
  final List<LeituraEntity> leituras;

  LeiturasEntity({required this.leituras});

  ({int valorTotalKwh, double valorTotal}) calcularFaturaTotal() {
    final leiturasEntries = [...leituras].asMap().entries.toList();

    double somaKwh = 0;

    for (var i = 0; i < leiturasEntries.length; i++) {
      final index = leiturasEntries[i].key;
      final leitura = leiturasEntries[i].value;
      final previousleitura =
          index > 0 ? leiturasEntries[index - 1].value : null;
      final currentValue = calcularValorKWH(
          leituraAtual: leitura, leituraAnterior: previousleitura);
      somaKwh += currentValue;
    }
    final valorTotalKwh = somaKwh.toInt();
    final valorTotalFatura = _calcularValorTotalFatura(somaKwh);

    final valorTotal = valorTotalFatura;

    return (
      valorTotalKwh: valorTotalKwh,
      valorTotal: valorTotal,
    );
  }

  double calcularValorKWH({
    required LeituraEntity leituraAtual,
    LeituraEntity? leituraAnterior,
  }) {
    if (leituraAnterior == null) {
      return 0.0;
    }

    final int diferencaKwh =
        (int.parse(leituraAtual.contador) - int.parse(leituraAnterior.contador))
            .abs();
    return diferencaKwh.toDouble();
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

    return valor;
  }
}
