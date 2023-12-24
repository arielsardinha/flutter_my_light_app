import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_bloc.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_event.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_state.dart';
import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/storage/storage.dart';
import 'package:my_light_app/utils/mixins/convert_currency.dart';
import 'package:my_light_app/utils/mixins/convert_file.dart';
import 'package:my_light_app/utils/mixins/date_formate.dart';
import 'package:validatorless/validatorless.dart';

class HomePage extends StatefulWidget {
  final Storage storage;
  final LeituraBloc leituraBloc;
  final ImagePicker picker;
  const HomePage({
    super.key,
    required this.storage,
    required this.leituraBloc,
    required this.picker,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with FormatFileMixin, FormatCurrencyMixin, DateFormatMixin {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isADM = ValueNotifier(false);
  late final size = MediaQuery.sizeOf(context);
  late final textTheme = Theme.of(context).textTheme;

  final imageInUint8List = ValueNotifier(Uint8List(0));
  File? imageInFile;
  final valorTotal = ValueNotifier(0.0);
  final valorTotalKwh = ValueNotifier(0);

  LeiturasEntity leituras = LeiturasEntity();
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

    widget.leituraBloc.add(
      LeituraEventCreateLeitura(
        contador: controller.text,
        leituras: leituras,
        photo: imageInFile!,
      ),
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

  Future<void> deletarLeitura({
    required LeiturasEntity leituras,
    required LeituraEntity leitura,
  }) async {
    widget.leituraBloc.add(
      LeituraEventDeleteLeitura(leitura: leitura, leituras: leituras),
    );
  }

  @override
  void initState() {
    widget.leituraBloc.add(LeituraEventGetLeituras());
    widget.storage
        .get<Map<String, dynamic>>(StorageEnum.proprietario)
        .then((value) {
      final ProprietarioResponseModel proprietario =
          ProprietarioResponseModel.fromJson(value!);
      isADM.value = proprietario.nivelAcesso == "ADM";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        widget.leituraBloc.add(LeituraEventGetLeituras());
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ValueListenableBuilder(
                valueListenable: isADM,
                builder: (context, isADM, snapshot) {
                  if (isADM) {
                    return IconButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/config",
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.settings),
                    );
                  }
                  return const SizedBox();
                })
          ],
        ),
        body: SafeArea(
          child: BlocListener<LeituraBloc, LeituraState>(
            bloc: widget.leituraBloc,
            listener: (context, state) {
              if (state is LeituraStateLoaded) {
                final leituras = state.leituras;
                // ignore: no_leading_underscores_for_local_identifiers
                final (valorTotal: _valorTotal, valorTotalKwh: _valorTotalKwh) =
                    leituras.calcularFaturaTotal();

                this.leituras = leituras;

                valorTotal.value = _valorTotal;
                valorTotalKwh.value = _valorTotalKwh;
              }
            },
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
                              key: const Key('title'),
                              style: textTheme.titleMedium,
                            ),
                            Text(
                              'Valor Total: ${formatCurrencyEuro(valorTotal.value)}',
                              key: const Key('valor_total'),
                              style: textTheme.labelMedium,
                            ),
                            Text(
                              'Total Kwh: ${valorTotalKwh.value}',
                              key: const Key('valor_total_kwh'),
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
                          final XFile? image = await widget.picker
                              .pickImage(source: ImageSource.camera);
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
                        child: Image.memory(
                          img,
                          key: const Key('image_photo'),
                        ),
                      );
                    },
                  ),
                  BlocBuilder<LeituraBloc, LeituraState>(
                    bloc: widget.leituraBloc,
                    builder: (context, state) {
                      if (state is LeituraStateLoading) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (state is LeituraStateLoaded) {
                        final leituras = state.leituras;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...leituras.leituras.asMap().entries.map(
                              (entry) {
                                final index = entry.key;
                                final leitura = entry.value;
                                final previousleitura = index > 0
                                    ? leituras.leituras[index - 1]
                                    : null;

                                final value = leitura.calcularValorKWH(
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                          clipBehavior:
                                                              Clip.none,
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
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .error_outline_rounded,
                                                                ),
                                                                itemBuilder:
                                                                    (context) {
                                                                  return [
                                                                    PopupMenuItem(
                                                                      child:
                                                                          Text(
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
                                                                  size.width *
                                                                      0.9,
                                                              width:
                                                                  size.width *
                                                                      0.9,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            24),
                                                                image:
                                                                    DecorationImage(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  image:
                                                                      MemoryImage(
                                                                    extractDecodeBitAndConvertToUint8List(
                                                                      leitura
                                                                          .photo,
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
                                                            BorderRadius
                                                                .circular(16),
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(
                                                            leitura.photo,
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
                                                      deletarLeitura(
                                                        leitura: leitura,
                                                        leituras: leituras,
                                                      );
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
                      }

                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
