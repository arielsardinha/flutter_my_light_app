import 'package:flutter/material.dart';
import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/utils/mixins/convert_currency.dart';

class DetalhesLeituraPage extends StatelessWidget with FormatCurrencyMixin {
  final LeituraEntity leitura;
  final double currency;
  final String currentDate;
  const DetalhesLeituraPage({
    super.key,
    required this.leitura,
    required this.currency,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes de leitura'),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentDate,
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              "Data da leitura",
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              "Contador: ${leitura.contador} kW",
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              "Quantidade total de consumo do dia",
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Valor: ${formatCurrencyEuro(currency)}',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              "Valor referente a última leitura",
              style: theme.textTheme.labelSmall,
            ),
            if (leitura.photo != null && leitura.photo!.isNotEmpty)
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: Container(
                          height: size.width * 0.9,
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(leitura.photo!),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Text('Abrir imagem'),
              )
          ],
        ),
      ),
    );
  }
}
