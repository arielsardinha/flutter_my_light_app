import 'package:my_light_app/enterprise/entities/casa_entity.dart';

abstract interface class GetCasasUseCase {
  Future<List<CasaEntity>> exec();
}
