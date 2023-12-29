import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_light_app/application/usecases/remote_create_leitura.dart';
import 'package:my_light_app/application/usecases/remote_delete_leitura.dart';
import 'package:my_light_app/application/usecases/remote_get_casa.dart';
import 'package:my_light_app/application/usecases/remote_get_casas.dart';
import 'package:my_light_app/application/usecases/remote_get_leituras.dart';
import 'package:my_light_app/application/usecases/remote_get_leiura_resumo.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_bloc.dart';
import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/infra/client_http/client_http_dio.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_repository_impl.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository_impl.dart';
import 'package:my_light_app/infra/storage/storage.dart';
import 'package:my_light_app/pages/config_page/config_page.dart';
import 'package:my_light_app/pages/detalhes_leitura_page/detalhes_leitura_page.dart';
import 'package:my_light_app/pages/home_page/home_page.dart';
import 'package:my_light_app/pages/login_page/login_page.dart';
import 'package:my_light_app/pages/resumo_leituras_page/resumo_leituras_page.dart';
import 'package:my_light_app/pages/splash_page/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageSharedPreferences();
    final clientHttp = ClientHttpDio();
    final casaRepository = CasaRepositoryImpl(
      clientHttp: clientHttp,
    );
    final leituraRepository = LeituraRepositoryImpl(clientHttp: clientHttp);
    final leituraBloc = LeituraBloc(
      getLeiturasUseCase: RemoteGetLeituras(
        leituraRepository: leituraRepository,
        storage: storage,
      ),
      deleteLeituraUseCase: RemoteDeleteLeitura(
        leituraRepository: leituraRepository,
        storage: storage,
      ),
      createLeituraUseCase: RemoteCreateLeitura(
        storage: storage,
        leituraRepository: leituraRepository,
      ),
    );
    final getLeituraResumoUseCase = RemoteGetLeituraResumo(
      storage: storage,
      leituraRepository: leituraRepository,
    );
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        "/home": (context) => HomePage(
              storage: storage,
              picker: ImagePicker(),
              leituraBloc: leituraBloc,
            ),
        "/login_page": (context) => LoginPage(
              storage: storage,
              getCasaUseCase: RemoteGetCasa(
                storage: storage,
                casaRepository: casaRepository,
              ),
            ),
        "/splash": (context) => SplashPage(
              storage: storage,
            ),
        "/config": (context) => ConfigPage(
              storage: storage,
              getCasasUseCase: RemoteGetCasas(
                casaRepository: casaRepository,
              ),
            ),
        "/detalhes_leitura": (context) {
          final arguments = ModalRoute.of(context)!.settings.arguments as ({
            double currency,
            String currentDate,
            LeituraEntity leitura
          });
          return DetalhesLeituraPage(
            leitura: arguments.leitura,
            currency: arguments.currency,
            currentDate: arguments.currentDate,
          );
        },
        "/resumo_leituras": (context) => ResumoLeiturasPage(
              getLeituraResumoUseCase: getLeituraResumoUseCase,
            ),
      },
      initialRoute: '/splash',
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
