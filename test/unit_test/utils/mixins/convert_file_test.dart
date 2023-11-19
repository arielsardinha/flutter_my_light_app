import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_light_app/utils/mixins/convert_file.dart';

class _TestFormatFileMixin with FormatFileMixin {}

void main() {
  late File file;
  late IOSink ioSink;
  late _TestFormatFileMixin formatFileMixin;
  setUpAll(() {
    formatFileMixin = _TestFormatFileMixin();
    file = File('image.png');
    ioSink = file.openWrite();
  });

  tearDownAll(() async {
    await ioSink.close();
    file.deleteSync();
  });

  test('Deve converter o arquivo em base64 corretamente', () {
    final imagemInBase64 = formatFileMixin.convertImageFileToBase64String(file);

    expect(imagemInBase64, 'data:image/png;base64,');
  });

  test('Deve executar uma exception quando o arquivo for inválido', () {
    final file = File('');

    expect(() => formatFileMixin.convertImageFileToBase64String(file),
        throwsException);
  });

  test('Deve converter a imagem em base64 em uma Uint8List corretamente',
      () async {
    await file.writeAsString('a');
    final imagemInBase64 = formatFileMixin.convertImageFileToBase64String(file);
    final imagemInUint8List =
        formatFileMixin.extractDecodeBitAndConvertToUint8List(imagemInBase64);

    expect(imagemInUint8List, [97]);
    await file.writeAsString('');
  });
}
