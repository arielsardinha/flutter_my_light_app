import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:my_light_app/enterprise/entities/leitura_resumo_entity.dart';
import 'package:my_light_app/enterprise/usecases/get_leitura_resumo_usecase.dart';
import 'package:my_light_app/utils/mixins/date_formate.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_extend/share_extend.dart';

//OpenFile.open("/sdcard/example.txt", type: "text/plain", uti: "public.plain-text");
class ResumoLeiturasPage extends StatefulWidget with DateFormatMixin {
  final GetLeituraResumoUseCase getLeituraResumoUseCase;
  const ResumoLeiturasPage({super.key, required this.getLeituraResumoUseCase});

  @override
  State<ResumoLeiturasPage> createState() => _ResumoLeiturasPageState();
}

class _ResumoLeiturasPageState extends State<ResumoLeiturasPage> {
  final resumoLeituras = ValueNotifier(<LeiturasResumoEntity>[]);
  late Future<List<LeiturasResumoEntity>> leiturasLoading;
  Future<void> gerarEPdf(List<LeiturasResumoEntity> leituras) async {
    final pdf = pw.Document(deflate: zlib.encode);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.TableHelper.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Total de Leituras', 'Consumo', 'Data da Leitura'],
                ...leituras.map((item) => [
                      item.totalLeitura.toString(),
                      item.consumo.toString(),
                      widget.dateFormatStringMMYYYY(item.dataLeitura)
                    ]),
              ],
            ),
          ];
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final directoryPath = output.path;

    final file = File("$directoryPath/leituras_resumo.pdf");
    await file.writeAsBytes(await pdf.save());

    log(file.path);
    try {
      if (await file.exists()) {
        await ShareExtend.share(file.path, 'file', extraText: 'Enviar PDF');
      } else {
        log('File not found');
      }
    } catch (e) {
      log('Erro ao abrir o arquivo: $e');
    }
  }

  @override
  void initState() {
    final loading = widget.getLeituraResumoUseCase.exec();
    leiturasLoading = loading;
    loading.then((value) => resumoLeituras.value = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo anual'),
        actions: [
          ValueListenableBuilder(
            valueListenable: resumoLeituras,
            builder: (context, resumo, snapshot) {
              if (resumo.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    gerarEPdf(resumo);
                  },
                  icon: const Icon(Icons.share),
                );
              }
              return const SizedBox();
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: leiturasLoading,
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
                              widget
                                  .dateFormatStringMMYYYY(leitura.dataLeitura),
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
