import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_light_app/components/dropdownbutton.dart';
import 'package:my_light_app/enterprise/usecases/get_casas_usecase.dart';
import 'package:my_light_app/infra/repositories/casa_repositories/casa_model.dart';
import 'package:my_light_app/infra/storage/storage.dart';

class ConfigPage extends StatelessWidget {
  final GetCasasUseCase getCasasUseCase;
  final Storage storage;
  const ConfigPage({
    super.key,
    required this.getCasasUseCase,
    required this.storage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: FutureBuilder(
        future: getCasasUseCase.exec(),
        builder: (context, snapshot) {
          log(snapshot.data.toString());
          if (snapshot.data != null) {
            final proprietarios = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  LigthSelect(
                    forceShowKeyboard: true,
                    onTapItem: (value) {
                      final casa = value?.value;
                      if (casa != null) {
                        final model = ProprietarioResponseModel(
                          id: casa.id,
                          nivelAcesso: "ADM",
                          nomeProprietario: casa.proprietario,
                        );
                        storage.save(
                          key: StorageEnum.proprietario,
                          value: model.toJson(),
                        );
                      }
                    },
                    items: ValueNotifier(
                      proprietarios
                          .map((e) =>
                              LigthSelectItem(title: e.proprietario, value: e))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }
}
