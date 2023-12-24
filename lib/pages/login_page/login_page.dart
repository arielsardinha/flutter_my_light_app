import 'package:flutter/material.dart';
import 'package:my_light_app/enterprise/usecases/get_casa_use_case.dart';
import 'package:my_light_app/infra/adapter/http_erro.dart';
import 'package:my_light_app/infra/storage/storage.dart';

class LoginPage extends StatefulWidget {
  final GetCasaUseCase getCasaUseCase;
  final Storage storage;

  const LoginPage({
    super.key,
    required this.getCasaUseCase,
    required this.storage,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController proprietarioCtl = TextEditingController();
  final TextEditingController hostCtl = TextEditingController();
  final host = ValueNotifier('');
  var hasHost = false;

  @override
  void initState() {
    widget.storage.get<String>(StorageEnum.host).then((value) {
      hasHost = value != null;
      host.value = value ?? '';
      // 'http://10.0.2.2:3000'
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
            valueListenable: host,
            builder: (context, _, child) {
              if (!hasHost && host.value.isNotEmpty) {
                return const Text('Por favor, reinicie o aplicativo');
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (host.value.isEmpty)
                    const Text('Peça ao responsável do APP o host do sistema'),
                  if (host.value.isEmpty)
                    TextFormField(
                      controller: hostCtl,
                      decoration: const InputDecoration(
                        labelText: 'host do sistema',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (host.value.isNotEmpty)
                    TextFormField(
                      controller: proprietarioCtl,
                      decoration: const InputDecoration(
                        labelText: 'Qual o nome do proprietário da casa',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        if (host.value.isNotEmpty) {
                          await widget.getCasaUseCase.exec(
                            nomeProprietario: proprietarioCtl.text,
                          );
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/home', (route) => false);
                          });
                          return;
                        }
                        await widget.storage.save(
                          key: StorageEnum.host,
                          value: hostCtl.text,
                        );
                        host.value = hostCtl.text;
                      } on HttpError catch (_) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Proprietário não encontrado'),
                            ),
                          );
                        });
                      }
                    },
                    child: const Text('Enviar'),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
