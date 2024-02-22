import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:my_light_app/application/usecases/remote_create_leitura.dart';
import 'package:my_light_app/application/usecases/remote_delete_leitura.dart';
import 'package:my_light_app/application/usecases/remote_get_leituras.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_bloc.dart';
import 'package:my_light_app/enterprise/usecases/create_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/delete_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/get_leituras_usecase.dart';
import 'package:my_light_app/infra/adapter/response_adapter.dart';
import 'package:my_light_app/infra/client_http/client_http.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository.dart';
import 'package:my_light_app/infra/repositories/leituras_repositories/leitura_repository_impl.dart';
import 'package:my_light_app/infra/storage/storage.dart';
import 'package:my_light_app/pages/home_page/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mocs/mocs.mocks.dart';
import 'package:image/image.dart' as img;

void main() {
  late Storage storage;
  late LeituraBloc leituraBloc;
  late GetLeiturasUseCase getLeiturasUseCase;
  late DeleteLeituraUseCase deleteLeituraUseCase;
  late CreateLeituraUseCase createLeituraUseCase;
  late File file;
  late LeituraRepository leituraRepository;
  late ClientHttp clientHttp;
  setUpAll(() {
    file = File('temp_image.png');
    clientHttp = MockClientHttp();
    leituraRepository = LeituraRepositoryImpl(
      clientHttp: clientHttp,
    );
    storage = StorageSharedPreferences();
    deleteLeituraUseCase = RemoteDeleteLeitura(
      leituraRepository: leituraRepository,
      storage: storage,
    );
    getLeiturasUseCase = RemoteGetLeituras(
      leituraRepository: leituraRepository,
      storage: storage,
    );
    createLeituraUseCase = RemoteCreateLeitura(
      leituraRepository: leituraRepository,
      storage: storage,
    );
    leituraBloc = LeituraBloc(
      getLeiturasUseCase: getLeiturasUseCase,
      deleteLeituraUseCase: deleteLeituraUseCase,
      createLeituraUseCase: createLeituraUseCase,
    );
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() async {
    final IOSink ioSink = file.openWrite();
    await ioSink.close();
    file.deleteSync();
  });

  testWidgets('Deve carregar inicial tela', (tester) async {
    await storage.save(
        key: StorageEnum.proprietario,
        value: {"id": 2, "nome_proprietario": "ADRIANA"});

    provideDummy<Response<Map<String, dynamic>>>(Response(
      data: {
        "leituras": [
          {
            "createAt": "2023-12-23T23:24:54.000Z",
            "id": 3,
            "contador": 400,
            "photo": null
          }
        ],
        "totalContador": 600,
        "totalContadorPorDaCasa": 400,
        "casaId": 2
      },
      status: 200,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          storage: storage,
          leituraBloc: leituraBloc,
          picker: ImagePicker(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('title')), findsOneWidget);
    expect(find.text('Registre sua energia elétrica'), findsOneWidget);

    expect(find.byKey(const Key('valor_total')), findsOneWidget);
    expect(find.text('Valor Total: R\$ 0,00'), findsOneWidget);

    expect(find.byKey(const Key('valor_total_kwh')), findsOneWidget);
    expect(find.text('Total Kwh: 0'), findsOneWidget);

    final textFormFieldFinder = find.byType(TextFormField);
    expect(textFormFieldFinder, findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'valor total de kwh'),
      findsOneWidget,
    );

    final inputDecorator = tester.widget<InputDecorator>(find.descendant(
        of: textFormFieldFinder, matching: find.byType(InputDecorator)));
    expect(inputDecorator.decoration.hintText,
        'Adicione o valor total de kwh do relógio');

    final elevatedButtonFinder = find.byType(ElevatedButton);
    expect(elevatedButtonFinder, findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Salvar informações'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FilledButton, 'Tirar foto'),
      findsOneWidget,
    );
  });

  testWidgets('Deve salvar uma leitura', (tester) async {
    final mockImagePicker = MockImagePicker();
    img.Image image = img.Image(height: 100, width: 100);

    List<int> png = img.encodePng(image);
    file.writeAsBytesSync(png);

    final xFile = XFile(file.path);

    await tester.pumpWidget(
      MaterialApp(
        home: HomePage(
          storage: storage,
          leituraBloc: leituraBloc,
          picker: mockImagePicker,
        ),
      ),
    );

    final textFormField =
        tester.widget<TextFormField>(find.byType(TextFormField));

    textFormField.controller!.text = '100';

    expect(textFormField.controller!.text, '100');

    final filledButton = find.byType(FilledButton);

    expect(filledButton, findsOneWidget);

    when(mockImagePicker.pickImage(source: ImageSource.camera))
        .thenAnswer((_) async => xFile);

    await tester.tap(filledButton);
    await tester.pump();
    await tester.pumpAndSettle();

    verify(mockImagePicker.pickImage(source: ImageSource.camera)).called(1);
    expect(find.byKey(const Key('image_photo')), findsOneWidget);

    final elevatedButton = find.byType(ElevatedButton);

    expect(elevatedButton, findsOneWidget);

    await tester.tap(elevatedButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Os dados foram salvos com sucesso'), findsOneWidget);
    expect(textFormField.controller!.text, '');
    expect(find.byKey(const Key('image_photo')), findsNothing);
  });
}
