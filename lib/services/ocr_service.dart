import 'dart:io';

import 'package:controle_entregas/core/constants.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  final String rawText;
  final String? customerName;
  final String? addressText;
  final String? houseNumber;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? orderNumber;
  final String? deliveryIdentifier;
  final String? partnerCollectionCode;
  final bool needsIfoodConfirmation;
  final bool hasDrinks;
  final String? drinkType;
  final bool needsCard;
  final int? cardAmountCents;
  final bool needsChange;
  final int? changeAmountCents;
  final double confidence;
  final String parserStatus;
  // Never populated by OCR; filled during review by user
  final String? pizzaNumber;

  const OcrResult({
    required this.rawText,
    this.customerName,
    this.addressText,
    this.houseNumber,
    this.complement,
    this.neighborhood,
    this.city,
    this.orderNumber,
    this.deliveryIdentifier,
    this.partnerCollectionCode,
    this.needsIfoodConfirmation = false,
    this.hasDrinks = false,
    this.drinkType,
    this.needsCard = false,
    this.cardAmountCents,
    this.needsChange = false,
    this.changeAmountCents,
    this.confidence = 1.0,
    this.parserStatus = 'sucesso_completo',
    this.pizzaNumber,
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
    AppLogger.log(
      LogEvents.mlkitInitStart,
      module: 'OcrService',
      className: 'OcrService',
      metadata: {'script': 'latin'},
    );
    try {
      _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      AppLogger.log(
        LogEvents.mlkitInitSuccess,
        module: 'OcrService',
        className: 'OcrService',
        metadata: {'script': 'latin', 'status': 'recognizer_created'},
      );
    } catch (e, st) {
      // Graceful degradation: log diagnostics, do not rethrow.
      // _recognizer stays null; processImage() will return empty result.
      AppLogger.error(
        LogEvents.mlkitInitFail,
        module: 'OcrService',
        className: 'OcrService',
        exception: e,
        stackTrace: st,
      );
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
        AppLogger.error(
          LogEvents.ocrInputImageFail,
          module: 'OcrService',
          sessionId: sid,
          metadata: {'reason': 'file_not_found'},
        );
        return OcrResult(rawText: '', confidence: 0.0);
      }

      // Detect format from magic bytes and log image diagnostics
      AppLogger.log(
        LogEvents.ocrImagePreprocessStart,
        module: 'OcrService',
        sessionId: sid,
      );
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
      AppLogger.log(
        LogEvents.ocrImagePreprocessSuccess,
        module: 'OcrService',
        sessionId: sid,
        metadata: {'format': format},
      );
    } catch (e, st) {
      AppLogger.error(
        LogEvents.ocrInputImageFail,
        module: 'OcrService',
        sessionId: sid,
        exception: e,
        stackTrace: st,
      );
    }

    // ── ML Kit recognition ─────────────────────────────────────────────────
    // Guard: if TextRecognizer failed to initialize (e.g. R8 stripping),
    // return empty result now — recovery popup will handle it upstream.
    if (_recognizer == null) {
      AppLogger.log(
        LogEvents.mlkitModelMissing,
        severity: LogSeverity.error,
        module: 'OcrService',
        sessionId: sid,
        metadata: {'reason': 'recognizer_null_at_processImage'},
      );
      return OcrResult(rawText: '', confidence: 0.0);
    }

    AppLogger.log(
      LogEvents.ocrRecognizerStart,
      module: 'OcrService',
      sessionId: sid,
    );

    late final RecognizedText recognized;
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      AppLogger.log(
        LogEvents.ocrInputImageSuccess,
        module: 'OcrService',
        sessionId: sid,
      );

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

    // ── Raw text captured log ──────────────────────────────────────────────
    AppLogger.log(
      LogEvents.ocrRawTextCaptured,
      module: 'OcrService',
      sessionId: sid,
      metadata: {'lines': lines.length, 'chars': recognized.text.length},
    );

    // ── Field extraction ──────────────────────────────────────────────────
    AppLogger.log(
      LogEvents.ocrRegexStart,
      module: 'OcrService',
      sessionId: sid,
    );

    final parsed = _parseLines(recognized.text, lines);
    final result = parsed.result;
    _logParserDetails(parsed, sid);

    // Log each found field individually for traceability
    if (result.addressText != null) {
      AppLogger.log(
        LogEvents.ocrFieldAddressFound,
        module: 'OcrService',
        sessionId: sid,
        metadata: {'value': result.addressText},
      );
    }
    if (result.customerName != null) {
      AppLogger.log(
        LogEvents.ocrFieldCustomerFound,
        module: 'OcrService',
        sessionId: sid,
        metadata: {'value': result.customerName},
      );
    }
    if (result.deliveryIdentifier != null) {
      AppLogger.log(
        LogEvents.ocrFieldLocatorFound,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'field': 'deliveryIdentifier',
          'value': result.deliveryIdentifier,
        },
      );
    }
    if (result.partnerCollectionCode != null) {
      final eventName = parsed.collectionMethod == 'anchor'
          ? LogEvents.ocrFieldCollectionFound
          : LogEvents.ocrFieldCollectionFallback;
      AppLogger.log(
        eventName,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'value': result.partnerCollectionCode,
          'method': parsed.collectionMethod,
        },
      );
    }

    final capturedLocator = result.deliveryIdentifier;
    if (capturedLocator != null && capturedLocator.isNotEmpty) {
      AppLogger.log(
        LogEvents.locatorCaptured,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'value': capturedLocator,
          'length': capturedLocator.length,
          'source': 'ocr_result',
        },
      );
    }

    if (parsed.missingFields.isNotEmpty) {
      AppLogger.log(
        LogEvents.ocrRegexFail,
        severity: LogSeverity.warning,
        module: 'OcrService',
        sessionId: sid,
        metadata: {'missing_fields': parsed.missingFields},
      );
    } else {
      AppLogger.log(
        LogEvents.ocrRegexSuccess,
        module: 'OcrService',
        sessionId: sid,
      );
    }

    final totalMs = DateTime.now().difference(t0).inMilliseconds;

    // ── Confidence level log ───────────────────────────────────────────────
    final confidenceEvent = result.confidence >= 0.8
        ? LogEvents.ocrConfidenceHigh
        : result.confidence >= 0.5
        ? LogEvents.ocrConfidenceMedium
        : LogEvents.ocrConfidenceLow;
    AppLogger.log(
      confidenceEvent,
      module: 'OcrService',
      sessionId: sid,
      metadata: {
        'confidence': result.confidence,
        'parser_status': result.parserStatus,
      },
    );

    // ── Operational detection logs ─────────────────────────────────────────
    if (result.needsCard || result.needsChange) {
      AppLogger.log(
        LogEvents.paymentDetected,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'needs_card': result.needsCard,
          'needs_change': result.needsChange,
          'change_amount_cents': result.changeAmountCents,
        },
      );
    }
    if (result.hasDrinks) {
      AppLogger.log(
        LogEvents.drinkDetected,
        module: 'OcrService',
        sessionId: sid,
        metadata: {'has_drinks': true},
      );
    }

    if (result.hasRequiredFields) {
      AppLogger.log(
        LogEvents.ocrProcessSuccess,
        module: 'OcrService',
        sessionId: sid,
        metadata: {
          'duration_ms': totalMs,
          'has_address': result.addressText != null,
          'has_locator':
              result.partnerCollectionCode != null ||
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
          'has_locator': result.deliveryIdentifier != null,
        },
      );
    }

    return result;
  }

  Future<void> dispose() async {
    await _recognizer?.close();
  }

  static OcrResult parseRawText(String rawText) {
    final lines = rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final parsed = _parseLines(rawText, lines);
    _logParserDetails(parsed, null);
    return parsed.result;
  }

  static _OcrParseDetails _parseLines(String rawText, List<String> lines) {
    if (lines.isEmpty) return _OcrParseDetails.empty(rawText);

    final fullText = lines.join('\n').toUpperCase();

    // Address: collect up to 2 lines to handle OCR line splits.
    final address = _extractAfterAnchor(
      lines,
      OcrKeywords.addressAnchors,
      maxLines: 2,
    );
    if (address != null) {
      AppLogger.log(
        LogEvents.parserAddressMatch,
        module: 'OcrService',
        metadata: {'value': address},
      );
    } else {
      // Log the lines that were near expected address position for diagnostics.
      final suspectLines = lines
          .where((l) => l.toUpperCase().contains('ENDERE'))
          .take(3)
          .toList();
      AppLogger.warn(
        LogEvents.parserAddressFailReason,
        module: 'OcrService',
        metadata: {
          'reason': 'no_address_anchor_matched',
          'suspect_lines': suspectLines,
          'total_lines': lines.length,
        },
      );
    }
    // Customer: try anchor-based first (receipts with explicit CLIENTE/NOME label),
    // then positional (iFood format: bare name line between Localizador and Endereco).
    final customerName =
        _extractAfterAnchor(
          lines,
          OcrKeywords.customerNameAnchors,
          maxLines: 2,
        ) ??
        _extractCustomerNamePositional(lines);
    if (customerName != null) {
      AppLogger.log(
        LogEvents.customerValidated,
        module: 'OcrService',
        metadata: {'name': customerName},
      );
    } else {
      AppLogger.warn(
        LogEvents.customerNotFound,
        module: 'OcrService',
        metadata: {'total_lines': lines.length},
      );
    }

    final complement = _extractAfterAnchor(lines, const [
      'COMPLEMENTO',
      'COMP',
    ], maxLines: 1);
    final neighborhood = _extractAfterAnchor(
      lines,
      OcrKeywords.neighborhoodAnchors,
    );
    final orderNumber = _extractOrderNumber(fullText, lines);
    final locatorResult = _extractLocator(lines);
    final deliveryId = locatorResult.$1;
    final locatorInvalid = locatorResult.$2;

    final missing = <String>[];
    if (address == null) missing.add('address');
    if (orderNumber == null) missing.add('order');
    if (deliveryId == null) missing.add('locator');

    // FAIL only when BOTH address AND order are missing (OCR unusable).
    // Missing only locator → PARTIAL (field warning, not total fail).
    final parserStatus = (address != null && orderNumber != null)
        ? (deliveryId != null ? 'sucesso_completo' : 'sucesso_parcial')
        : missing.length >= 2
        ? 'falha_total'
        : 'sucesso_parcial';

    // Log payment text that was detected but intentionally ignored (manual review only).
    final hasPaymentText =
        _containsAny(fullText, OcrKeywords.cardMachine) ||
        _containsAny(fullText, OcrKeywords.change) ||
        _containsAny(fullText, OcrKeywords.prepaidPaymentPhrases);
    if (hasPaymentText) {
      AppLogger.log(
        LogEvents.paymentTextIgnoredFromOcr,
        module: 'OcrService',
        metadata: {
          'raw_excerpt': fullText.length > 200
              ? fullText.substring(0, 200)
              : fullText,
        },
      );
    }

    // Split trailing house number from address (e.g. "R. SU 1, 100" → base + "100").
    final (cleanAddress, extractedHouseNumber) = address != null
        ? _splitHouseNumber(address)
        : (null, null);

    return _OcrParseDetails(
      result: OcrResult(
        rawText: rawText,
        customerName: customerName,
        addressText: cleanAddress,
        houseNumber: extractedHouseNumber,
        complement: complement,
        neighborhood: neighborhood,
        orderNumber: orderNumber,
        deliveryIdentifier: deliveryId,
        partnerCollectionCode: null,
        needsIfoodConfirmation: _containsAny(
          fullText,
          OcrKeywords.ifoodConfirmation,
        ),
        hasDrinks: _containsAny(fullText, OcrKeywords.drinks),
        drinkType: _extractDrinkType(fullText),
        needsCard: false, // Payment flags never set by OCR — manual review only
        cardAmountCents: null,
        needsChange:
            false, // Payment flags never set by OCR — manual review only
        changeAmountCents: null,
        confidence: parserStatus == 'sucesso_completo'
            ? 1.0
            : parserStatus == 'sucesso_parcial'
            ? 0.6
            : 0.0,
        parserStatus: parserStatus,
      ),
      collectionMethod: 'anchor',
      missingFields: missing,
      locatorInvalid: locatorInvalid,
    );
  }

  // ── iFood locator extraction ─────────────────────────────────────────────
  // ONLY from the "Localizador:" label. Never from generic numeric patterns.

  static (String?, bool) _extractLocator(List<String> lines) {
    final anchored = _extractAfterAnchor(lines, OcrKeywords.deliveryIdAnchors);
    if (anchored == null) return (null, false);

    final digits = anchored.replaceAll(RegExp(r'\D'), '');
    if (RegExp(r'^\d{8}$').hasMatch(digits)) return (digits, false);

    // Anchor was found but value is not 8 digits — log invalid but don't fallback.
    return (null, digits.isNotEmpty);
  }

  static void _logParserDetails(_OcrParseDetails parsed, String? sessionId) {
    final result = parsed.result;

    if (result.deliveryIdentifier != null) {
      AppLogger.log(
        LogEvents.parserLocatorValidated,
        module: 'OcrService',
        sessionId: sessionId,
        metadata: {
          'value': result.deliveryIdentifier,
          'length': result.deliveryIdentifier!.length,
        },
      );
    }
    if (parsed.locatorInvalid) {
      AppLogger.warn(
        LogEvents.parserLocatorInvalid,
        module: 'OcrService',
        sessionId: sessionId,
      );
    }
    if (result.addressText == null) {
      AppLogger.warn(
        LogEvents.parserAddressNotFound,
        module: 'OcrService',
        sessionId: sessionId,
      );
    }
    if (result.orderNumber == null) {
      AppLogger.warn(
        LogEvents.parserOrderNotFound,
        module: 'OcrService',
        sessionId: sessionId,
      );
    }
    if (result.parserStatus == 'falha_total') {
      AppLogger.warn(
        LogEvents.parserManualReviewRequired,
        module: 'OcrService',
        sessionId: sessionId,
        metadata: {'reason': 'mandatory_fields_missing'},
      );
    }

    final event = switch (result.parserStatus) {
      'sucesso_completo' => LogEvents.parserSuccessComplete,
      'sucesso_parcial' => LogEvents.parserSuccessPartial,
      _ => LogEvents.parserFail,
    };
    AppLogger.log(
      event,
      severity: result.parserStatus == 'falha_total'
          ? LogSeverity.warning
          : LogSeverity.info,
      module: 'OcrService',
      sessionId: sessionId,
      metadata: {
        'status': result.parserStatus,
        'has_order': result.orderNumber != null,
        'has_locator': result.deliveryIdentifier != null,
        'has_address': result.addressText != null,
        'has_name': result.customerName != null,
        'has_neighborhood': result.neighborhood != null,
      },
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  // Finds the first line containing an anchor keyword and extracts the value.
  // Inline value (after ':' on same line) takes priority.
  // Otherwise collects up to [maxLines] subsequent non-anchor lines.
  static String? _extractAfterAnchor(
    List<String> lines,
    List<String> anchors, {
    int maxLines = 1,
  }) {
    for (int i = 0; i < lines.length; i++) {
      final upper = lines[i].toUpperCase();
      for (final anchor in anchors) {
        if (upper.contains(anchor)) {
          AppLogger.log(
            LogEvents.parserLabelFound,
            module: 'OcrService',
            metadata: {'label': anchor, 'line': lines[i]},
          );

          // Inline value after colon on the same line.
          final colonIdx = lines[i].indexOf(':');
          if (colonIdx != -1 && colonIdx < lines[i].length - 1) {
            final value = lines[i].substring(colonIdx + 1).trim();
            if (value.isNotEmpty) {
              AppLogger.log(
                LogEvents.parserLabelValueExtracted,
                module: 'OcrService',
                metadata: {'label': anchor, 'value': value, 'source': 'inline'},
              );
              return value;
            }
          }

          // Collect subsequent lines until next anchor or boundary.
          final parts = <String>[];
          for (
            int j = i + 1;
            j < lines.length && parts.length < maxLines;
            j++
          ) {
            final next = lines[j].trim();
            if (next.isEmpty) continue;
            if (_isAnchorLine(next)) break;
            parts.add(next);
          }
          if (parts.isNotEmpty) {
            final value = parts.join(' ');
            AppLogger.log(
              LogEvents.parserLabelValueExtracted,
              module: 'OcrService',
              metadata: {
                'label': anchor,
                'value': value,
                'source': 'next_lines',
                'parts': parts.length,
              },
            );
            return value;
          }
        }
      }
    }
    return null;
  }

  // Extracts customer name by position: the first "name-like" line between
  // the Localizador line and the Endereco line (iFood receipt layout).
  static String? _extractCustomerNamePositional(List<String> lines) {
    int locatorIdx = -1;
    for (int i = 0; i < lines.length; i++) {
      final upper = lines[i].toUpperCase();
      if (OcrKeywords.deliveryIdAnchors.any((a) => upper.contains(a))) {
        locatorIdx = i;
        break;
      }
    }
    if (locatorIdx < 0) return null;

    int addressIdx = lines.length;
    for (int i = locatorIdx + 1; i < lines.length; i++) {
      final upper = lines[i].toUpperCase();
      if (OcrKeywords.addressAnchors.any((a) => upper.contains(a))) {
        addressIdx = i;
        break;
      }
    }

    // Name-like: only letters (including accented) and spaces, at least 2 words.
    final namePattern = RegExp(r'^[A-Za-zÀ-ÿ\s]+$');
    for (int i = locatorIdx + 1; i < addressIdx; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      if (!namePattern.hasMatch(line)) continue;
      final words = line.split(' ').where((w) => w.isNotEmpty).toList();
      if (words.length < 2) continue;
      if (_isAnchorLine(line)) continue;
      // Task 4: reject blocklisted values
      final upper = line.toUpperCase();
      if (OcrKeywords.customerNameBlocklist.any((b) => upper.contains(b))) {
        AppLogger.warn(
          LogEvents.customerRejectedBlocklist,
          module: 'OcrService',
          metadata: {'rejected': line},
        );
        continue;
      }
      AppLogger.log(
        LogEvents.customerCandidateFound,
        module: 'OcrService',
        metadata: {
          'candidate': line,
          'position': i,
          'locator_idx': locatorIdx,
          'address_idx': addressIdx,
        },
      );
      return line;
    }
    return null;
  }

  static String? _extractOrderNumber(String fullText, List<String> lines) {
    final fromAnchor = _extractAfterAnchor(
      lines,
      OcrKeywords.orderNumberAnchors,
    );
    if (fromAnchor != null) {
      final digits = RegExp(r'\d{4,}').firstMatch(fromAnchor)?.group(0);
      if (digits != null) return digits;
    }
    return null;
  }

  static bool _containsAny(String text, List<String> keywords) =>
      keywords.any((kw) => text.contains(kw.toUpperCase()));

  static bool _isAnchorLine(String line) {
    final upper = line.toUpperCase();
    const allAnchors = [
      ...OcrKeywords.customerNameAnchors,
      ...OcrKeywords.addressAnchors,
      ...OcrKeywords.neighborhoodAnchors,
      ...OcrKeywords.orderNumberAnchors,
      ...OcrKeywords.deliveryIdAnchors,
      ...OcrKeywords.collectionCodeAnchors,
      ...OcrKeywords.sectionBoundaryAnchors,
    ];
    return allAnchors.any((a) => upper.contains(a));
  }

  /// Splits a trailing house number from an address string.
  /// Matches ", 100" / ", n 41" / ", n. 41" patterns.
  /// Returns (baseAddress, houseNumber) — unchanged input when no match.
  static String? _extractDrinkType(String text) {
    final upper = text.toUpperCase();
    const options = [
      ('COCA ZERO 2L', 'Coca Zero 2L'),
      ('COCA ZERO 1L', 'Coca Zero 1L'),
      ('COCA 2L', 'Coca 2L'),
      ('COCA 1,5L', 'Coca 1,5L'),
      ('COCA 1.5L', 'Coca 1,5L'),
      ('COCA 1L', 'Coca 1L'),
      ('FANTA LARANJA 2L', 'Fanta Laranja 2L'),
      ('FANTA LARANJA 1L', 'Fanta Laranja 1L'),
      ('SPRITE 1L', 'Sprite 1L'),
      ('GUARANA 1L', 'Guaraná 1L'),
      ('GUARANÁ 1L', 'Guaraná 1L'),
      ('COCA ZERO', 'Coca Zero'),
      ('COCA', 'Coca'),
      ('FANTA', 'Fanta'),
      ('SPRITE', 'Sprite'),
      ('GUARANA', 'Guaraná'),
      ('GUARANÁ', 'Guaraná'),
    ];
    for (final option in options) {
      if (upper.contains(option.$1)) return option.$2;
    }
    return null;
  }

  static (String, String?) _splitHouseNumber(String address) {
    final regex = RegExp(r',\s*(?:[nN]\.?\s*)?(\d+)\s*$');
    final match = regex.firstMatch(address);
    if (match == null) return (address, null);
    final number = match.group(1)!;
    final base = address.substring(0, match.start).trim();
    if (base.isEmpty) return (address, null);
    return (base, number);
  }
}

class _OcrParseDetails {
  final OcrResult result;
  final String collectionMethod;
  final List<String> missingFields;
  final bool locatorInvalid;

  const _OcrParseDetails({
    required this.result,
    required this.collectionMethod,
    required this.missingFields,
    this.locatorInvalid = false,
  });

  factory _OcrParseDetails.empty(String rawText) => _OcrParseDetails(
    result: OcrResult(
      rawText: rawText,
      confidence: 0.0,
      parserStatus: 'falha_total',
    ),
    collectionMethod: 'not_found',
    missingFields: const ['address', 'order', 'locator'],
  );
}
