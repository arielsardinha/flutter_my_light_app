import 'package:flutter_test/flutter_test.dart';
import 'package:my_light_app/infra/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Storage storage;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});

    storage = StorageSharedPreferences();
  });

  group('Storage | ', () {
    test('Deve salvar os dados com sucesso', () async {
      expect(storage.save(key: StorageEnum.data, value: []), completes);
    });

    test('Deve buscar os dados com sucesso', () async {
      await storage.save(key: StorageEnum.data, value: []);
      final response = await storage.get(StorageEnum.data);

      expect(response, equals([]));
      {
        await storage.save(key: StorageEnum.data, value: null);
        final response = await storage.get(StorageEnum.data);

        expect(response, null);
      }
    });

    test('Deve deletar os dados com sucesso', () async {
      await storage.save(key: StorageEnum.data, value: []);
      await storage.delete(StorageEnum.data);
      final response = await storage.get(StorageEnum.data);
      expect(response, null);
    });
  });
}
