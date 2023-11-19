import 'package:my_light_app/enterprise/entities/leituras_entity.dart';

abstract class LeituraState {}

class LeituraStateInitial extends LeituraState {}

class LeituraStateLoading extends LeituraState {}

class LeituraStateLoaded extends LeituraState {
  final LeiturasEntity leituras;

  LeituraStateLoaded({required this.leituras});
}
