import 'package:bloc/bloc.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_event.dart';
import 'package:my_light_app/blocs/leitura_bloc/leitura_state.dart';
import 'package:my_light_app/enterprise/usecases/create_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/delete_leitura_usecase.dart';
import 'package:my_light_app/enterprise/usecases/get_leituras_usecase.dart';

class LeituraBloc extends Bloc<LeituraEvent, LeituraState> {
  final GetLeiturasUseCase _getLeiturasUseCase;
  final DeleteLeituraUseCase _deleteLeituraUseCase;
  final CreateLeituraUseCase _createLeituraUseCase;

  LeituraBloc({
    required GetLeiturasUseCase getLeiturasUseCase,
    required DeleteLeituraUseCase deleteLeituraUseCase,
    required CreateLeituraUseCase createLeituraUseCase,
  })  : _getLeiturasUseCase = getLeiturasUseCase,
        _deleteLeituraUseCase = deleteLeituraUseCase,
        _createLeituraUseCase = createLeituraUseCase,
        super(LeituraStateInitial()) {
    on<LeituraEventGetLeituras>((event, emit) async {
      try {
        emit(LeituraStateLoading());
        final leituras = await _getLeiturasUseCase.exec();
        emit(LeituraStateLoaded(leituras: leituras));
      } catch (e) {
        emit(LeituraStateError());
      }
    });

    on<LeituraEventDeleteLeitura>((event, emit) async {
      try {
        emit(LeituraStateLoading());
        await _deleteLeituraUseCase.exec(
          leituras: event.leituras,
          leitura: event.leitura,
        );
        add(LeituraEventGetLeituras());
      } catch (e) {
        emit(LeituraStateError());
      }
    });

    on<LeituraEventCreateLeitura>((event, emit) async {
      try {
        emit(LeituraStateLoading());
        await _createLeituraUseCase.exec(
          leituras: event.leituras,
          photo: event.photo,
          contador: event.contador,
        );
        add(LeituraEventGetLeituras());
      } catch (e) {
        emit(LeituraStateError());
      }
    });
  }
}
