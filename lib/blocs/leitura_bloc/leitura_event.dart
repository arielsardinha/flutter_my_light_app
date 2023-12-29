import 'dart:io';

import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';

abstract class LeituraEvent {}

class LeituraEventGetLeituras extends LeituraEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  LeituraEventGetLeituras({this.endDate, this.startDate});
}

class LeituraEventDeleteLeitura extends LeituraEvent {
  final LeiturasEntity leituras;
  final LeituraEntity leitura;
  final void Function() onLoaded;

  LeituraEventDeleteLeitura({
    required this.leitura,
    required this.leituras,
    required this.onLoaded,
  });
}

class LeituraEventCreateLeitura extends LeituraEvent {
  final LeiturasEntity leituras;
  final File? photo;
  final int contador;
  final void Function() onLoaded;

  LeituraEventCreateLeitura({
    required this.contador,
    required this.leituras,
    required this.photo,
    required this.onLoaded,
  });
}
