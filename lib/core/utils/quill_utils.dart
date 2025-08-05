import 'dart:convert';

class QuillUtils {
  /// Extracts plain text from Quill JSON content.
  static String extractPlainText(String quillJson, {int maxLength = 150}) {
    try {
      final List<dynamic> ops = jsonDecode(quillJson);
      final StringBuffer buffer = StringBuffer();

      for (var op in ops) {
        if (op is Map && op.containsKey('insert')) {
          final insertValue = op['insert'];
          if (insertValue is String) {
            buffer.write(insertValue);
          }
        }
        if (buffer.length >= maxLength) break;
      }

      String plainText = buffer.toString().trim().replaceAll('\n', ' ');
      return plainText.length > maxLength
          ? '${plainText.substring(0, maxLength)}...'
          : plainText;
    } catch (e) {
      return 'No Content'; // Fallback if parsing fails
    }
  }
}
