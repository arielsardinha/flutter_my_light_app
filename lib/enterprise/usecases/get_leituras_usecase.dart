import 'package:my_light_app/enterprise/entities/leituras_entity.dart';

abstract interface class GetLeiturasUseCase {
  Future<LeiturasEntity> exec({DateTime? endDate, DateTime? startDate});
}
