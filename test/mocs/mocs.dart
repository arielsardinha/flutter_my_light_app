import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:my_light_app/enterprise/usecases/create_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/delete_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/get_leituras_usecase.dart';
import 'package:my_light_app/infra/client_http/client_http.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository.dart';
import 'package:my_light_app/infra/storage/storage.dart';

@GenerateNiceMocks([
  MockSpec<Storage>(),
  MockSpec<GetLeiturasUseCase>(),
  MockSpec<DeleteLeituraUseCase>(),
  MockSpec<CreateLeituraUseCase>(),
  MockSpec<ImagePicker>(),
  MockSpec<ClientHttp>(),
  MockSpec<LeituraRepository>()
])
void main() {}
