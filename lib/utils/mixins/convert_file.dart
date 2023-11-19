import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

mixin FormatFileMixin {
  String convertImageFileToBase64String(File file) {
    try {
      final type = p.extension(file.path).replaceAll('.', '');
      final bytes = file.readAsBytesSync();
      final encodeBit = base64Encode(bytes);
      return "data:image/$type;base64,$encodeBit";
    } catch (e) {
      throw Exception('Erro ao converter imagem: $e');
    }
  }

  Uint8List extractDecodeBitAndConvertToUint8List(String base64Image) {
    final commaIndex = base64Image.indexOf(',');
    final base64EncodedData = base64Image.substring(commaIndex + 1);
    return base64Decode(base64EncodedData);
  }
}
