import 'dart:io';

import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';

abstract class LeituraEvent {}

class LeituraEventGetLeituras extends LeituraEvent {}

class LeituraEventDeleteLeitura extends LeituraEvent {
  final LeiturasEntity leituras;
  final LeituraEntity leitura;

  LeituraEventDeleteLeitura({required this.leitura, required this.leituras});
}

class LeituraEventCreateLeitura extends LeituraEvent {
  final LeiturasEntity leituras;
  final File photo;
  final String contador;

  LeituraEventCreateLeitura({
    required this.contador,
    required this.leituras,
    required this.photo,
  });
}
