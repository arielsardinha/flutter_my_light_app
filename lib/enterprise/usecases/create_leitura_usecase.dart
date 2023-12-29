import 'dart:io';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';

abstract interface class CreateLeituraUseCase {
  Future<void> exec({
    required LeiturasEntity leituras,
    required File? photo,
    required int contador,
  });
}
