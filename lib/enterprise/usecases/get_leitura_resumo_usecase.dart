import 'package:my_light_app/enterprise/entities/leitura_resumo_entity.dart';

abstract interface class GetLeituraResumoUseCase {
  Future<List<LeiturasResumoEntity>> exec();
}
