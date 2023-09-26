import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_light_app/core/storage/storage.dart';
import 'package:my_light_app/utils/mixins/convert_file.dart';
import 'package:validatorless/validatorless.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Storage();
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(storage: storage),
    );
  }
}

class HomePage extends StatelessWidget with FormatFileMixin {
  final Storage storage;
  const HomePage({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final picker = ImagePicker();
    final imageInUint8List = ValueNotifier(Uint8List(0));
    final formKey = GlobalKey<FormState>();
    final textTheme = Theme.of(context).textTheme;
    File? imageInFile;
    Future<void> saveData() async {
      final isValid = formKey.currentState?.validate() ?? false;

      if (imageInFile == null || !isValid) {
        if (imageInFile == null && isValid) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'A imagem é um campo obrigatório',
              ),
            ),
          );
        }
        return;
      }
      final imageInBase64 =
          convertImageFileToBase64String(File(imageInFile!.path));
      final data = await storage.get<List>(StorageEnum.data);

      final newDate = [
        ...?data,
        {
          'photo': imageInBase64,
          'contador': controller.text,
          'dataInMilisegundos': DateTime.now().millisecondsSinceEpoch,
        },
      ];
      await storage.save<List>(
        key: StorageEnum.data,
        value: newDate,
      );
      controller.clear();
      imageInUint8List.value = Uint8List(0);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Os dados foram salvos com sucesso',
            ),
          ),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Registre sua energia elétrica',
                  style: textTheme.titleMedium,
                ),
              ),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                validator: Validatorless.required('Campo obrigatório'),
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: saveData,
                    child: const Text('Salvar informações'),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  FilledButton(
                    onPressed: () async {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image == null) return;
                      imageInFile = File(image.path);
                      final imageInBase64 =
                          convertImageFileToBase64String(File(image.path));

                      imageInUint8List.value =
                          extractDecodeBitAndConvertToUint8List(imageInBase64);
                    },
                    child: const Text('Tirar foto'),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              ValueListenableBuilder(
                valueListenable: imageInUint8List,
                builder: (context, img, snapshot) {
                  return Visibility(
                    visible: img.isNotEmpty,
                    child: Image.memory(img),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
