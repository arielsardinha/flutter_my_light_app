import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_light_app/core/storage/storage.dart';
import 'package:my_light_app/models/leitura_model.dart';
import 'package:my_light_app/utils/mixins/convert_currency.dart';
import 'package:my_light_app/utils/mixins/convert_file.dart';
import 'package:my_light_app/utils/mixins/date_formate.dart';
import 'package:validatorless/validatorless.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Storage();
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: HomePage(storage: storage),
    );
  }
}

class HomePage extends StatefulWidget {
  final Storage storage;
  const HomePage({super.key, required this.storage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with FormatFileMixin, FormatCurrencyMixin, DateFormatMixin {
  final controller = TextEditingController();
  final picker = ImagePicker();
  final imageInUint8List = ValueNotifier(Uint8List(0));
  final formKey = GlobalKey<FormState>();
  late final textTheme = Theme.of(context).textTheme;
  File? imageInFile;
  final valorTotal = ValueNotifier(0.0);
  final valorTotalKwh = ValueNotifier(0);
  late final size = MediaQuery.sizeOf(context);

  final leituras = ValueNotifier(<LeituraModel>[]);
  Future<void> saveData() async {
    final isValid = formKey.currentState?.validate() ?? false;

    if (imageInFile == null || !isValid) {
      if (imageInFile == null && isValid) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'A imagem é um campo obrigatório',
            ),
          ),
        );
      }
      return;
    }
    final imageInBase64 =
        convertImageFileToBase64String(File(imageInFile!.path));
    final data = await widget.storage.get<List>(StorageEnum.data);
    final leitura = LeituraModel(
      contador: controller.text,
      dataInMilisegundos: DateTime.now().millisecondsSinceEpoch,
      photo: imageInBase64,
    );
    final newDate = [
      ...?data,
      leitura.toJson(),
    ];
    await widget.storage.save<List>(
      key: StorageEnum.data,
      value: newDate,
    );
    controller.clear();
    imageInUint8List.value = Uint8List(0);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Os dados foram salvos com sucesso',
          ),
        ),
      );
    });
  }

  void calcularFaturaTotal() {
    final leiturasEntries = [...leituras.value].asMap().entries.toList();

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
    valorTotalKwh.value = somaKwh.toInt();
    final valorTotalFatura = calcularValorTotalFatura(somaKwh);

    valorTotal.value = valorTotalFatura;
  }

  double calcularValorTotalFatura(double somaKwh) {
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

  Future<void> getAllData() async {
    final data = await widget.storage.get<List>(StorageEnum.data);
    if (data == null) return;
    final leituras = data.map((e) => LeituraModel.fromJson(e));

    this.leituras.value = leituras.toList();
  }

  double calcularValorKWH({
    required LeituraModel leituraAtual,
    LeituraModel? leituraAnterior,
  }) {
    if (leituraAnterior == null) {
      return 0.0;
    }

    final int diferencaKwh =
        (int.parse(leituraAtual.contador) - int.parse(leituraAnterior.contador))
            .abs();
    return diferencaKwh.toDouble();
  }

  Future<void> deletarLeitura(LeituraModel leitura) async {
    final data = await widget.storage.get<List>(StorageEnum.data);

    if (data == null) return;
    final leituras = data.map((e) => LeituraModel.fromJson(e)).toList();
    final leituraParaSelecionar = leituras
        .firstWhere((l) => l.dataInMilisegundos == leitura.dataInMilisegundos);
    leituras.remove(leituraParaSelecionar);

    final List<Map<String, dynamic>> leiturasInJson = [];

    for (LeituraModel leitura in leituras) {
      leiturasInJson.add(leitura.toJson());
    }
    await widget.storage.save<List<Map<String, dynamic>>>(
      key: StorageEnum.data,
      value: leiturasInJson,
    );
    await getAllData();
    calcularFaturaTotal();
  }

  @override
  void initState() {
    (() async {
      await getAllData();
      calcularFaturaTotal();
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await getAllData();
        calcularFaturaTotal();
      },
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([valorTotal, valorTotalKwh]),
                    builder: (context, snapshot) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registre sua energia elétrica',
                            style: textTheme.titleMedium,
                          ),
                          Text(
                            'Valor Total: ${formatCurrencyEuro(valorTotal.value)}',
                            style: textTheme.labelMedium,
                          ),
                          Text(
                            'Total Kwh: ${valorTotalKwh.value}',
                            style: textTheme.labelMedium,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  validator: Validatorless.required('Campo obrigatório'),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    label: Text('valor total de kwh'),
                    hintText: 'Adicione o valor total de kwh do relógio',
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: saveData,
                      child: const Text('Salvar informações'),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    FilledButton(
                      onPressed: () async {
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image == null) return;
                        imageInFile = File(image.path);
                        final imageInBase64 =
                            convertImageFileToBase64String(File(image.path));

                        imageInUint8List.value =
                            extractDecodeBitAndConvertToUint8List(
                                imageInBase64);
                      },
                      child: const Text('Tirar foto'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                ValueListenableBuilder(
                  valueListenable: imageInUint8List,
                  builder: (context, img, snapshot) {
                    return Visibility(
                      visible: img.isNotEmpty,
                      child: Image.memory(img),
                    );
                  },
                ),
                ValueListenableBuilder(
                  valueListenable: leituras,
                  builder: (context, leituras, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...leituras.asMap().entries.map(
                          (entry) {
                            final index = entry.key;
                            final leitura = entry.value;
                            final previousleitura =
                                index > 0 ? leituras[index - 1] : null;

                            final value = calcularValorKWH(
                                leituraAtual: leitura,
                                leituraAnterior: previousleitura);

                            final currentDate =
                                dateFormatDateTimeInStringFullTime(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        leitura.dataInMilisegundos));

                            final previusDate = previousleitura != null
                                ? dateFormatDateTimeInStringFullTime(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        previousleitura.dataInMilisegundos))
                                : "'Nenhuma data anterior'";

                            return Stack(
                              children: [
                                Container(
                                  width: double.maxFinite,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Card(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    currentDate,
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    "Contador: ${leitura.contador} kW",
                                                  ),
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  SizedBox(
                                                    width: 120,
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Text(
                                                          'Valor: ${formatCurrencyEuro(value)}',
                                                        ),
                                                        Positioned(
                                                          right: -15,
                                                          bottom: -14,
                                                          child:
                                                              PopupMenuButton(
                                                            iconSize: 15,
                                                            icon: const Icon(
                                                              Icons
                                                                  .error_outline_rounded,
                                                            ),
                                                            itemBuilder:
                                                                (context) {
                                                              return [
                                                                PopupMenuItem(
                                                                  child: Text(
                                                                    'Esse valor é referente a $previusDate',
                                                                  ),
                                                                ),
                                                              ];
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        child: Container(
                                                          height:
                                                              size.width * 0.9,
                                                          width:
                                                              size.width * 0.9,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        24),
                                                            image:
                                                                DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image:
                                                                  MemoryImage(
                                                                extractDecodeBitAndConvertToUint8List(
                                                                  leitura.photo,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Container(
                                                  height: 100,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: MemoryImage(
                                                        extractDecodeBitAndConvertToUint8List(
                                                          leitura.photo,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -10,
                                  top: -10,
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog.adaptive(
                                            contentTextStyle: theme
                                                .textTheme.labelMedium
                                                ?.copyWith(
                                                    color: theme
                                                        .colorScheme.error),
                                            title: const Text(
                                                'Tem certeza que deseja excluir ?'),
                                            content: const Text(
                                                'Isso não poderá ser desfeito!'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Não'),
                                              ),
                                              FilledButton(
                                                onPressed: () {
                                                  deletarLeitura(leitura);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Sim'),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
