import 'dart:io';

import 'package:controle_entregas/core/constants.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  final String rawText;
  final String? customerName;
  final String? addressText;
  final String? neighborhood;
  final String? city;
  final String? orderNumber;
  final String? deliveryIdentifier;
  final String? partnerCollectionCode;
  final bool needsIfoodConfirmation;
  final bool hasDrinks;
  final bool needsCard;
  final bool needsChange;
  final int? changeAmountCents;
  final double confidence;

  const OcrResult({
    required this.rawText,
    this.customerName,
    this.addressText,
    this.neighborhood,
    this.city,
    this.orderNumber,
    this.deliveryIdentifier,
    this.partnerCollectionCode,
    this.needsIfoodConfirmation = false,
    this.hasDrinks = false,
    this.needsCard = false,
    this.needsChange = false,
    this.changeAmountCents,
    this.confidence = 1.0,
  });

  bool get hasRequiredFields =>
      addressText != null && addressText!.trim().isNotEmpty;
}

class OcrService {
  // Nullable: if TextRecognizer() throws (e.g. stripped R8 components),
  // processImage() detects null and returns empty result → recovery popup.
  // Never rethrows — widget creation must never fail due to ML Kit init.
  TextRecognizer? _recognizer;

  OcrService() {
    AppLogger.log(LogEvents.mlkitInitStart,
        module: 'OcrService',
        className: 'OcrService',
        metadata: {'script': 'latin'});
    try {
      _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      AppLogger.log(LogEvents.mlkitInitSuccess,
          module: 'OcrService',
          className: 'OcrService',
          metadata: {'script': 'latin', 'status': 'recognizer_created'});
    } catch (e, st) {
      // Graceful degradation: log diagnostics, do not rethrow.
      // _recognizer stays null; processImage() will return empty result.
      AppLogger.error(LogEvents.mlkitInitFail,
          module: 'OcrService',
          className: 'OcrService',
          exception: e,
          stackTrace: st);
    }
  }

  /// Detects image format from magic bytes without loading the full image.
  static Future<String> _detectFormat(String path) async {
    try {
      final raf = await File(path).open(mode: FileMode.read);
      final header = await raf.read(8);
      await raf.close();
      if (header.length >= 2 && header[0] == 0xFF && header[1] == 0xD8) {
        return 'JPEG';
      }
      if (header.length >= 4 &&
          header[0] == 0x89 &&
          header[1] == 0x50 &&
          header[2] == 0x4E &&
          header[3] == 0x47) {
        return 'PNG';
      }
      if (header.length >= 4 &&
          header[0] == 0x52 &&
          header[1] == 0x49 &&
          header[2] == 0x46 &&
          header[3] == 0x46) {
        return 'WEBP';
      }
      return 'UNKNOWN';
    } catch (_) {
      return 'UNKNOWN';
    }
  }

  Future<OcrResult> processImage(String imagePath) async {
    final sid = SessionManager.ocr();
    final t0 = DateTime.now();

    AppLogger.log(
      LogEvents.ocrStart,
      module: 'OcrService',
      className: 'OcrService',
      method: 'processImage',
      sessionId: sid,
    );

    // ── File validation + image metadata ──────────────────────────────────
    int? fileSizeBytes;
    try {
      final file = File(imagePath);
      final exists = await file.exists();
      fileSizeBytes = exists ? await file.length() : null;
      AppLogger.log(
        LogEvents.ocrFileReceived,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'path': imagePath,
          'exists': exists,
          'size_bytes': fileSizeBytes,
        },
      );
      if (!exists) {
        AppLogger.error(LogEvents.ocrInputImageFail, module: 'OcrService',
            sessionId: sid, metadata: {'reason': 'file_not_found'});
        return OcrResult(rawText: '', confidence: 0.0);
      }

      // Detect format from magic bytes and log image diagnostics
      AppLogger.log(LogEvents.ocrImagePreprocessStart,
          module: 'OcrService', sessionId: sid);
      final format = await _detectFormat(imagePath);
      AppLogger.log(
        LogEvents.ocrImageFormat,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'format': format,
          'size_bytes': fileSizeBytes,
          'path_ext': imagePath.split('.').last.toLowerCase(),
          'preprocessing': 'none',
        },
      );
      AppLogger.log(LogEvents.ocrImagePreprocessSuccess,
          module: 'OcrService', sessionId: sid,
          metadata: {'format': format});
    } catch (e, st) {
      AppLogger.error(LogEvents.ocrInputImageFail, module: 'OcrService',
          sessionId: sid, exception: e, stackTrace: st);
    }

    // ── ML Kit recognition ─────────────────────────────────────────────────
    // Guard: if TextRecognizer failed to initialize (e.g. R8 stripping),
    // return empty result now — recovery popup will handle it upstream.
    if (_recognizer == null) {
      AppLogger.log(LogEvents.mlkitModelMissing,
          severity: LogSeverity.error,
          module: 'OcrService',
          sessionId: sid,
          metadata: {'reason': 'recognizer_null_at_processImage'});
      return OcrResult(rawText: '', confidence: 0.0);
    }

    AppLogger.log(LogEvents.ocrRecognizerStart,
        module: 'OcrService', sessionId: sid);

    late final RecognizedText recognized;
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      AppLogger.log(LogEvents.ocrInputImageSuccess,
          module: 'OcrService', sessionId: sid);

      recognized = await _recognizer!.processImage(inputImage);
    } catch (e, st) {
      final ms = DateTime.now().difference(t0).inMilliseconds;
      AppLogger.error(
        LogEvents.ocrRecognizerFail,
        module: 'OcrService',
        sessionId: sid,
        metadata: {'duration_ms': ms},
        exception: e,
        stackTrace: st,
      );
      return OcrResult(rawText: '', confidence: 0.0);
    }

    final recognizerMs = DateTime.now().difference(t0).inMilliseconds;
    AppLogger.log(
      LogEvents.ocrRecognizerSuccess,
      module: 'OcrService',
      sessionId: sid,
      metadata: {
        'duration_ms': recognizerMs,
        'blocks': recognized.blocks.length,
      },
    );

    // ── Line extraction ────────────────────────────────────────────────────
    final lines = recognized.blocks
        .expand((b) => b.lines)
        .map((l) => l.text.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final fullText = lines.join('\n').toUpperCase();

    // Text preview (first 300 chars, newlines → |)
    final preview = recognized.text.length > 300
        ? '${recognized.text.substring(0, 300)}…'
        : recognized.text;
    AppLogger.log(
      LogEvents.ocrTextPreview,
      module: 'OcrService',
      sessionId: sid,
      metadata: {
        'lines': lines.length,
        'chars': recognized.text.length,
        'preview': preview.replaceAll('\n', '|'),
      },
    );

    if (lines.isEmpty) {
      AppLogger.log(
        LogEvents.ocrProcessFail,
        severity: LogSeverity.warning,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'reason': 'no_lines_extracted',
          'raw_text_length': recognized.text.length,
          'duration_ms': recognizerMs,
        },
      );
      return OcrResult(rawText: recognized.text, confidence: 0.0);
    }

    // ── Field extraction ──────────────────────────────────────────────────
    AppLogger.log(LogEvents.ocrRegexStart,
        module: 'OcrService', sessionId: sid);

    final address = _extractAfterAnchor(lines, OcrKeywords.addressAnchors);
    final customerName =
        _extractAfterAnchor(lines, OcrKeywords.customerNameAnchors);
    final neighborhood =
        _extractAfterAnchor(lines, OcrKeywords.neighborhoodAnchors);
    final orderNumber = _extractOrderNumber(fullText, lines);
    final deliveryId =
        _extractAfterAnchor(lines, OcrKeywords.deliveryIdAnchors);
    final collectionResult = _extractCollectionCode(fullText, lines);
    final collectionCode = collectionResult.$1;
    final collectionMethod = collectionResult.$2;

    // Log each found field individually for traceability
    if (address != null) {
      AppLogger.log(LogEvents.ocrFieldAddressFound,
          module: 'OcrService', sessionId: sid,
          metadata: {'value': address});
    }
    if (customerName != null) {
      AppLogger.log(LogEvents.ocrFieldCustomerFound,
          module: 'OcrService', sessionId: sid,
          metadata: {'value': customerName});
    }
    if (deliveryId != null) {
      AppLogger.log(LogEvents.ocrFieldLocatorFound,
          module: 'OcrService', sessionId: sid,
          metadata: {'field': 'deliveryIdentifier', 'value': deliveryId});
    }
    if (collectionCode != null) {
      final eventName = collectionMethod == 'anchor'
          ? LogEvents.ocrFieldCollectionFound
          : LogEvents.ocrFieldCollectionFallback;
      AppLogger.log(eventName,
          module: 'OcrService', sessionId: sid,
          metadata: {'value': collectionCode, 'method': collectionMethod});
    }

    // Log missing critical fields
    final missing = <String>[];
    if (address == null) missing.add('address');
    if (collectionCode == null && deliveryId == null) missing.add('locator');

    if (missing.isNotEmpty) {
      AppLogger.log(
        LogEvents.ocrRegexFail,
        severity: LogSeverity.warning,
        module: 'OcrService',
        sessionId: sid,
        metadata: {'missing_fields': missing},
      );
    } else {
      AppLogger.log(LogEvents.ocrRegexSuccess,
          module: 'OcrService', sessionId: sid);
    }

    final totalMs = DateTime.now().difference(t0).inMilliseconds;
    final result = OcrResult(
      rawText: recognized.text,
      customerName: customerName,
      addressText: address,
      neighborhood: neighborhood,
      orderNumber: orderNumber,
      deliveryIdentifier: deliveryId,
      partnerCollectionCode: collectionCode,
      needsIfoodConfirmation:
          _containsAny(fullText, OcrKeywords.ifoodConfirmation),
      hasDrinks: _containsAny(fullText, OcrKeywords.drinks),
      needsCard: _containsAny(fullText, OcrKeywords.cardMachine),
      needsChange: _containsAny(fullText, OcrKeywords.change),
      changeAmountCents: _extractChangeAmount(fullText),
      confidence: lines.isEmpty ? 0.0 : 1.0,
    );

    if (result.hasRequiredFields) {
      AppLogger.log(
        LogEvents.ocrProcessSuccess,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'duration_ms': totalMs,
          'has_address': result.addressText != null,
          'has_locator': result.partnerCollectionCode != null ||
              result.deliveryIdentifier != null,
          'needs_ifood': result.needsIfoodConfirmation,
        },
      );
    } else {
      AppLogger.log(
        LogEvents.ocrLowConfidence,
        severity: LogSeverity.warning,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'reason': 'no_address',
          'lines': lines.length,
          'duration_ms': totalMs,
          'has_locator': result.partnerCollectionCode != null,
        },
      );
    }

    return result;
  }

  Future<void> dispose() async {
    await _recognizer?.close();
  }

  // ── Collection code extraction (standard + relaxed passes) ───────────────

  /// Returns (code, method) where method is 'anchor' or the regex pattern used.
  (String?, String) _extractCollectionCode(
      String fullText, List<String> lines) {
    final fromAnchor =
        _extractAfterAnchor(lines, OcrKeywords.collectionCodeAnchors);
    if (fromAnchor != null && fromAnchor.isNotEmpty) {
      return (fromAnchor, 'anchor');
    }

    final relaxed = [
      (RegExp(r'COD[^\n\d]{0,10}(\w{4,10})', caseSensitive: false), 'cod_prefix'),
      (RegExp(r'#\s*([A-Z0-9]{4,10})'), 'hash_prefix'),
      (RegExp(r'CODE[^\n\d]{0,5}(\w{4,10})', caseSensitive: false), 'code_prefix'),
      (RegExp(r'\b([A-Z]{2,4}[\s\-]?\d{4,8})\b'), 'alphanum_pattern'),
    ];

    for (final (pattern, label) in relaxed) {
      final match = pattern.firstMatch(fullText);
      if (match != null) {
        final candidate = match.group(1)?.replaceAll(RegExp(r'\s'), '');
        if (candidate != null && candidate.length >= 4) {
          return (candidate, label);
        }
      }
    }
    return (null, 'not_found');
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  String? _extractAfterAnchor(List<String> lines, List<String> anchors) {
    for (int i = 0; i < lines.length; i++) {
      final upper = lines[i].toUpperCase();
      for (final anchor in anchors) {
        if (upper.contains(anchor)) {
          final colonIdx = lines[i].indexOf(':');
          if (colonIdx != -1 && colonIdx < lines[i].length - 1) {
            final value = lines[i].substring(colonIdx + 1).trim();
            if (value.isNotEmpty) return value;
          }
          if (i + 1 < lines.length) {
            final next = lines[i + 1].trim();
            if (next.isNotEmpty && !_isAnchorLine(next)) return next;
          }
        }
      }
    }
    return null;
  }

  String? _extractOrderNumber(String fullText, List<String> lines) {
    final fromAnchor =
        _extractAfterAnchor(lines, OcrKeywords.orderNumberAnchors);
    if (fromAnchor != null) {
      final digits = RegExp(r'\d{4,}').firstMatch(fromAnchor)?.group(0);
      if (digits != null) return digits;
    }
    final matches = RegExp(r'\b\d{4,6}\b').allMatches(fullText);
    if (matches.isNotEmpty) return matches.first.group(0);
    return null;
  }

  int? _extractChangeAmount(String fullText) {
    final match = RegExp(r'TROCO[^\d]*R?\$?\s*(\d+)[,.](\d{2})',
            caseSensitive: false)
        .firstMatch(fullText);
    if (match == null) return null;
    final reais = int.tryParse(match.group(1) ?? '0') ?? 0;
    final cents = int.tryParse(match.group(2) ?? '0') ?? 0;
    return reais * 100 + cents;
  }

  bool _containsAny(String text, List<String> keywords) =>
      keywords.any((kw) => text.contains(kw.toUpperCase()));

  bool _isAnchorLine(String line) {
    final upper = line.toUpperCase();
    const allAnchors = [
      ...OcrKeywords.customerNameAnchors,
      ...OcrKeywords.addressAnchors,
      ...OcrKeywords.neighborhoodAnchors,
      ...OcrKeywords.orderNumberAnchors,
      ...OcrKeywords.deliveryIdAnchors,
      ...OcrKeywords.collectionCodeAnchors,
    ];
    return allAnchors.any((a) => upper.contains(a));
  }
}
