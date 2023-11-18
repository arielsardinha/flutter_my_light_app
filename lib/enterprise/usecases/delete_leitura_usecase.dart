import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';

abstract interface class DeleteLeituraUseCase {
  Future<void> exec({
    required LeiturasEntity leituras,
    required LeituraEntity leitura,
  });
}
