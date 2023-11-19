import 'package:mockito/annotations.dart';
import 'package:my_light_app/enterprise/usecases/create_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/delete_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/get_leituras_usecase.dart';
import 'package:my_light_app/infra/storage/storage.dart';

@GenerateNiceMocks([
  MockSpec<Storage>(),
  MockSpec<GetLeiturasUseCase>(),
  MockSpec<DeleteLeituraUseCase>(),
  MockSpec<CreateLeituraUseCase>()
])
void main() {}
