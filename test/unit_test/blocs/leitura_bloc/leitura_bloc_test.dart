import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_bloc.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_event.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_state.dart';
import 'package:my_light_app/enterprise/entities/leitura_entity.dart';
import 'package:my_light_app/enterprise/entities/leituras_entity.dart';
import 'package:my_light_app/enterprise/usecases/create_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/delete_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/get_leituras_usecase.dart';

import '../../../mocs/mocs.mocks.dart';

void main() {
  late LeituraBloc leituraBloc;
  late GetLeiturasUseCase getLeiturasUseCase;
  late DeleteLeituraUseCase deleteLeituraUseCase;
  late CreateLeituraUseCase createLeituraUseCase;
  setUpAll(() {
    getLeiturasUseCase = MockGetLeiturasUseCase();
    deleteLeituraUseCase = MockDeleteLeituraUseCase();
    createLeituraUseCase = MockCreateLeituraUseCase();
    leituraBloc = LeituraBloc(
      getLeiturasUseCase: getLeiturasUseCase,
      deleteLeituraUseCase: deleteLeituraUseCase,
      createLeituraUseCase: createLeituraUseCase,
    );
  });

  test('Deve executar os estados de [loading, loaded]', () async {
    leituraBloc.add(LeituraEventGetLeituras());

    await expectLater(
      leituraBloc.stream,
      emitsInOrder([
        isA<LeituraStateLoading>(),
        isA<LeituraStateLoaded>(),
      ]),
    );
  });

  test(
      'Deve executar o estado de [loading loading loaded] para garantir que além de uma leitura ser deletada ele busque os dados',
      () async {
    leituraBloc.add(LeituraEventDeleteLeitura(
      onLoaded: () {},
      leitura: LeituraEntity(
        id: '',
        contador: 100,
        dataInMilisegundos: DateTime.now().millisecondsSinceEpoch,
        photo: '',
      ),
      leituras: LeiturasEntity(
        leituras: [],
      ),
    ));

    await expectLater(
      leituraBloc.stream,
      emitsInOrder([
        isA<LeituraStateLoading>(),
        isA<LeituraStateLoading>(),
        isA<LeituraStateLoaded>(),
      ]),
    );
  });

  test(
      'Deve executar o estado de [loading loading loaded] para garantir que além de uma leitura ser deletada ele busque os dados',
      () async {
    leituraBloc.add(
      LeituraEventCreateLeitura(
        onLoaded: () {},
        contador: 100,
        photo: File(''),
        leituras: LeiturasEntity(
          leituras: [],
        ),
      ),
    );

    await expectLater(
      leituraBloc.stream,
      emitsInOrder([
        isA<LeituraStateLoading>(),
        isA<LeituraStateLoading>(),
        isA<LeituraStateLoaded>(),
      ]),
    );
  });
}
