/// Generates short, human-readable correlation IDs for tracing
/// related log events across a single operation lifecycle.
///
/// Format: PREFIX-HEX_TIMESTAMP
/// Example: OCR-018F4A2B3C1
abstract final class SessionManager {
  static String generate(String prefix) {
    final ts = DateTime.now().millisecondsSinceEpoch
        .toRadixString(16)
        .toUpperCase();
    final micro = (DateTime.now().microsecond % 4096)
        .toRadixString(16)
        .toUpperCase();
    return '$prefix-$ts$micro';
  }

  static String ocr() => generate('OCR');
  static String ifood() => generate('IFOOD');
  static String db() => generate('DB');
  static String maps() => generate('MAPS');
  static String history() => generate('HIST');
  static String delivery() => generate('DLV');
}
