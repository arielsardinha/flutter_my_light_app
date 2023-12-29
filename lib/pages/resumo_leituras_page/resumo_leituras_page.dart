import 'package:flutter/material.dart';
import 'package:my_light_app/enterprise/usecases/get_leitura_resumo_usecase.dart';
import 'package:my_light_app/utils/mixins/date_formate.dart';

class ResumoLeiturasPage extends StatelessWidget with DateFormatMixin {
  final GetLeituraResumoUseCase getLeituraResumoUseCase;
  const ResumoLeiturasPage({super.key, required this.getLeituraResumoUseCase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo anual'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download),
          )
        ],
      ),
      body: FutureBuilder(
        future: getLeituraResumoUseCase.exec(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final resumo = snapshot.data!;

            return SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Leitura')),
                  DataColumn(label: Text('Consumo')),
                  DataColumn(label: Text('Data da Leitura')),
                ],
                rows: resumo
                    .map(
                      (leitura) => DataRow(
                        cells: [
                          DataCell(Text("${leitura.totalLeitura} kw")),
                          DataCell(Text("${leitura.consumo} kwh")),
                          DataCell(
                            Text(
                              dateFormatStringMMYYYY(leitura.dataLeitura),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }
}
