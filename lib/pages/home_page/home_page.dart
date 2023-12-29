import 'dart:developer';
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

class _DateFilterWidget extends StatefulWidget with DateFormatMixin {
  static DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  static DateTime endDate = DateTime.now();
  final void Function(({DateTime? startDate, DateTime endDate})) onChange;
  const _DateFilterWidget({required this.onChange});

  @override
  State<_DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<_DateFilterWidget> {
  @override
  void initState() {
    _DateFilterWidget.startDate =
        DateTime.now().subtract(const Duration(days: 30));
    _DateFilterWidget.endDate = DateTime.now();
    super.initState();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStart ? _DateFilterWidget.startDate : _DateFilterWidget.endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null &&
        picked !=
            (isStart
                ? _DateFilterWidget.startDate
                : _DateFilterWidget.endDate)) {
      setState(() {
        if (isStart) {
          _DateFilterWidget.startDate = picked;
        } else {
          _DateFilterWidget.endDate = picked;
        }
      });
      widget.onChange((
        startDate: _DateFilterWidget.startDate,
        endDate: _DateFilterWidget.endDate
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione o Período de Data',
          style: theme.textTheme.labelMedium,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Chip(
                onDeleted: _DateFilterWidget.startDate.day !=
                        DateTime.now().subtract(const Duration(days: 30)).day
                    ? () {
                        setState(() {
                          _DateFilterWidget.startDate =
                              DateTime.now().subtract(const Duration(days: 30));
                        });
                        widget.onChange((
                          startDate: _DateFilterWidget.startDate,
                          endDate: _DateFilterWidget.endDate
                        ));
                      }
                    : null,
                labelStyle: theme.textTheme.bodySmall,
                visualDensity: VisualDensity.compact,
                label: Text(
                  'Início: ${widget.dateFormatDateTimeInStringFullTime(_DateFilterWidget.startDate).split('-')[0].trim()}',
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Chip(
                onDeleted: _DateFilterWidget.endDate.day != DateTime.now().day
                    ? () {
                        setState(() {
                          _DateFilterWidget.endDate = DateTime.now();
                        });
                        widget.onChange((
                          startDate: _DateFilterWidget.startDate,
                          endDate: _DateFilterWidget.endDate
                        ));
                      }
                    : null,
                labelStyle: theme.textTheme.bodySmall,
                visualDensity: VisualDensity.compact,
                label: Text(
                  'Fim: ${widget.dateFormatDateTimeInStringFullTime(_DateFilterWidget.endDate).split('-')[0].trim()}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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

    if (!isValid) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'A imagem é um campo obrigatório',
          ),
        ),
      );
      return;
    }

    widget.leituraBloc.add(
      LeituraEventCreateLeitura(
        contador: int.parse(controller.text),
        leituras: leituras,
        photo: imageInFile,
        onLoaded: getLeituras,
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
      LeituraEventDeleteLeitura(
          leitura: leitura, leituras: leituras, onLoaded: getLeituras),
    );
  }

  @override
  void initState() {
    getLeituras();
    widget.storage
        .get<Map<String, dynamic>>(StorageEnum.proprietario)
        .then((value) {
      final ProprietarioResponseModel proprietario =
          ProprietarioResponseModel.fromJson(value!);
      isADM.value = proprietario.nivelAcesso == "ADM";
    });
    super.initState();
  }

  Future<void> getLeituras() async {
    widget.leituraBloc.add(LeituraEventGetLeituras(
        endDate: _DateFilterWidget.endDate,
        startDate: _DateFilterWidget.startDate));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        getLeituras();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registre sua energia elétrica'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/resumo_leituras');
              },
              icon: const Icon(Icons.file_open),
            ),
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
              },
            )
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _DateFilterWidget(
                        onChange: (value) {
                          widget.leituraBloc.add(LeituraEventGetLeituras(
                            endDate: value.endDate,
                            startDate: value.startDate,
                          ));
                          log("start: ${value.startDate?.toIso8601String()} final: ${value.endDate.toIso8601String()}");
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AnimatedBuilder(
                          animation:
                              Listenable.merge([valorTotal, valorTotalKwh]),
                          builder: (context, snapshot) {
                            return SizedBox(
                              width: double.maxFinite,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Valor Total: ${formatCurrencyEuro(valorTotal.value)}',
                                    key: const Key('valor_total'),
                                    style: textTheme.labelMedium,
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    'Total Kwh: ${valorTotalKwh.value}',
                                    key: const Key('valor_total_kwh'),
                                    style: textTheme.labelMedium,
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
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
                                  convertImageFileToBase64String(
                                      File(image.path));

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
                                                previousleitura
                                                    .dataInMilisegundos))
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
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
                                                  Row(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator
                                                                  .pushNamed(
                                                                context,
                                                                "/detalhes_leitura",
                                                                arguments: (
                                                                  leitura:
                                                                      leitura,
                                                                  currency:
                                                                      value,
                                                                  currentDate:
                                                                      currentDate
                                                                ),
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .open_in_full,
                                                              color: theme
                                                                  .colorScheme
                                                                  .primary,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Detalhes',
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 16,
                                                      ),
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog
                                                                      .adaptive(
                                                                    contentTextStyle: theme
                                                                        .textTheme
                                                                        .labelMedium
                                                                        ?.copyWith(
                                                                            color:
                                                                                theme.colorScheme.error),
                                                                    title: const Text(
                                                                        'Tem certeza que deseja excluir ?'),
                                                                    content:
                                                                        const Text(
                                                                            'Isso não poderá ser desfeito!'),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                            'Não'),
                                                                      ),
                                                                      FilledButton(
                                                                        onPressed:
                                                                            () {
                                                                          deletarLeitura(
                                                                            leitura:
                                                                                leitura,
                                                                            leituras:
                                                                                leituras,
                                                                          );
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                            'Sim'),
                                                                      )
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons.delete,
                                                              color: theme
                                                                  .colorScheme
                                                                  .error,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Deletar',
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                    color: theme
                                                                        .colorScheme
                                                                        .error),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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
        ),
      ),
    );
  }
}
