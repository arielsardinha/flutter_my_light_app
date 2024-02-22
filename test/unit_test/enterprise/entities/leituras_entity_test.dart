import 'package:flutter_test/flutter_test.dart';
import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';

void main() {
  final dataInMilisegundos = DateTime.now().millisecondsSinceEpoch;
  final leituras = List<LeituraEntity>.generate(3, (index) {
    return LeituraEntity(
      id: '',
      contador: (index * 10).toInt(),
      dataInMilisegundos: dataInMilisegundos,
      photo: '',
    );
  });

  test('Deve ter uma lista de leituras', () {
    final leiturasEntity = LeiturasEntity(leituras: leituras);

    expect(leiturasEntity.leituras.length, 3);
  });

  test('Deve calcular corretamente o total de kwh e o valor total de consumo',
      () {
    final leituras = <LeituraEntity>[
      LeituraEntity(
        id: '',
        contador: 0,
        dataInMilisegundos: dataInMilisegundos,
        photo: '',
      ),
      LeituraEntity(
        id: '',
        contador: 20,
        dataInMilisegundos: dataInMilisegundos,
        photo: '',
      ),
    ];
    final leiturasEntity = LeiturasEntity(leituras: leituras);

    final (valorTotal: vTotal, valorTotalKwh: vTotalKwh) =
        leiturasEntity.calcularFaturaTotal();

    expect(vTotalKwh, 20);
    expect(vTotal, 19.74);

    {
      final leituras = <LeituraEntity>[
        LeituraEntity(
          id: '',
          contador: 100,
          dataInMilisegundos: dataInMilisegundos,
          photo: '',
        ),
        LeituraEntity(
          id: '',
          contador: 100,
          dataInMilisegundos: dataInMilisegundos,
          photo: '',
        ),
      ];
      final leiturasEntity = LeiturasEntity(leituras: leituras);

      final (valorTotal: vTotal, valorTotalKwh: vTotalKwh) =
          leiturasEntity.calcularFaturaTotal();
      expect(vTotalKwh, 200);
      expect(vTotal, 155.79);
    }

    {
      final leituras = <LeituraEntity>[
        LeituraEntity(
          id: '',
          contador: 200,
          dataInMilisegundos: dataInMilisegundos,
          photo: '',
        ),
      ];
      final leiturasEntity = LeiturasEntity(leituras: leituras);

      final (valorTotal: vTotal, valorTotalKwh: vTotalKwh) =
          leiturasEntity.calcularFaturaTotal();
      expect(vTotalKwh, 200);
      expect(vTotal, 155.79);
    }

    {
      final leituras = <LeituraEntity>[
        LeituraEntity(
          id: '',
          contador: 20,
          dataInMilisegundos: dataInMilisegundos,
          photo: '',
        ),
      ];
      final leiturasEntity = LeiturasEntity(leituras: leituras);

      final (valorTotal: vTotal, valorTotalKwh: vTotalKwh) =
          leiturasEntity.calcularFaturaTotal();
      expect(vTotalKwh, 20);
      expect(vTotal, 19.74);
    }

    {
      final leituras = <LeituraEntity>[
        LeituraEntity(
          id: '',
          contador: 100,
          dataInMilisegundos: dataInMilisegundos,
          photo: '',
        ),
      ];
      final leiturasEntity = LeiturasEntity(leituras: leituras);

      final (valorTotal: vTotal, valorTotalKwh: vTotalKwh) =
          leiturasEntity.calcularFaturaTotal();
      expect(vTotalKwh, 100);
      expect(vTotal, 68.30);
    }

    {
      final leituras = <LeituraEntity>[
        LeituraEntity(
          id: '',
          contador: 210,
          dataInMilisegundos: dataInMilisegundos,
          photo: '',
        ),
      ];
      final leiturasEntity = LeiturasEntity(leituras: leituras);

      final (valorTotal: vTotal, valorTotalKwh: vTotalKwh) =
          leiturasEntity.calcularFaturaTotal();
      expect(vTotalKwh, 210);
      expect(vTotal, 164.54);
    }
    {
      final leituras = <LeituraEntity>[
        LeituraEntity(
          id: '',
          contador: 300,
          dataInMilisegundos: dataInMilisegundos,
          photo: '',
        ),
      ];
      final leiturasEntity = LeiturasEntity(leituras: leituras);

      final (valorTotal: vTotal, valorTotalKwh: vTotalKwh) =
          leiturasEntity.calcularFaturaTotal();
      expect(vTotalKwh, 300);
      expect(vTotal, 248.66);
    }
    {
      final leituras = <LeituraEntity>[
        LeituraEntity(
          id: '',
          contador: 500,
          dataInMilisegundos: dataInMilisegundos,
          photo: '',
        ),
      ];
      final leiturasEntity = LeiturasEntity(leituras: leituras);

      final (valorTotal: vTotal, valorTotalKwh: vTotalKwh) =
          leiturasEntity.calcularFaturaTotal();
      expect(vTotalKwh, 500);
      expect(vTotal, 437.08);
    }
  });

  test('Deve calcular a diferença do kwh baseado no dia anterior corretamente',
      () {
    final leituraAtual = LeituraEntity(
      id: '',
      contador: 20,
      dataInMilisegundos: dataInMilisegundos,
      photo: '',
    );
    {
      final leituraAnterior = LeituraEntity(
        id: '',
        contador: 10,
        dataInMilisegundos: dataInMilisegundos,
        photo: '',
      );

      expect(leituraAtual.calcularValorKWH(leituraAnterior: leituraAnterior),
          10.0);
    }

    {
      final leituraAnterior = LeituraEntity(
        id: '',
        contador: 20,
        dataInMilisegundos: dataInMilisegundos,
        photo: '',
      );

      expect(
          leituraAtual.calcularValorKWH(leituraAnterior: leituraAnterior), 0);
    }

    {
      final leituraAnterior = LeituraEntity(
        id: '',
        contador: 30,
        dataInMilisegundos: dataInMilisegundos,
        photo: '',
      );

      expect(leituraAtual.calcularValorKWH(leituraAnterior: leituraAnterior),
          -10.0);
    }
  });
}
