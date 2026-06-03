import 'package:controle_entregas/services/app_logger.dart';
import 'package:controle_entregas/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Phase 1 — OCR Sandbox
/// Standalone screen to test OCR extraction without the full delivery flow.
/// Shows raw text, all extracted fields, session ID, and timing.
class OcrSandboxScreen extends StatefulWidget {
  const OcrSandboxScreen({super.key});

  @override
  State<OcrSandboxScreen> createState() => _OcrSandboxScreenState();
}

class _OcrSandboxScreenState extends State<OcrSandboxScreen> {
  final _service = OcrService();
  final _picker = ImagePicker();

  OcrResult? _result;
  String? _sessionId;
  int? _durationMs;
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _run(ImageSource source) async {
    setState(() {
      _processing = true;
      _result = null;
      _error = null;
    });

    final sid = SessionManager.ocr();
    AppLogger.log(LogEvents.ocrSandboxStarted,
        module: 'OcrSandboxScreen',
        sessionId: sid,
        metadata: {'source': source.name});

    try {
      final image = await _picker.pickImage(
          source: source, imageQuality: 95);
      if (image == null) {
        setState(() => _processing = false);
        return;
      }

      final t0 = DateTime.now();
      final result = await _service.processImage(image.path);
      final ms = DateTime.now().difference(t0).inMilliseconds;

      setState(() {
        _result = result;
        _sessionId = sid;
        _durationMs = ms;
        _processing = false;
      });
    } catch (e, st) {
      AppLogger.error(LogEvents.exception,
          module: 'OcrSandboxScreen', sessionId: sid,
          exception: e, stackTrace: st);
      setState(() {
        _error = e.toString();
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Sandbox'),
        actions: [
          if (_sessionId != null)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copiar Session ID',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _sessionId!));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session ID copiado')));
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _processing
                        ? null
                        : () => _run(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _processing
                        ? null
                        : () => _run(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                  ),
                ),
              ],
            ),
          ),

          if (_processing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(),
            ),

          if (_error != null)
            _SandboxCard('Erro', _error!, isError: true),

          if (_result != null) ...[
            _MetaRow(
              sessionId: _sessionId!,
              durationMs: _durationMs!,
              textLength: _result!.rawText.length,
              hasRequiredFields: _result!.hasRequiredFields,
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _FieldCard('Endereço', _result!.addressText,
                      required: true),
                  _FieldCard('Localizador (collection)',
                      _result!.partnerCollectionCode),
                  _FieldCard('Identificador', _result!.deliveryIdentifier),
                  _FieldCard('Cliente', _result!.customerName),
                  _FieldCard('Pedido', _result!.orderNumber),
                  _FieldCard('Bairro', _result!.neighborhood),
                  _FlagsCard(_result!),
                  _SandboxCard('Texto bruto (preview)',
                      _result!.rawText.length > 500
                          ? '${_result!.rawText.substring(0, 500)}…'
                          : _result!.rawText),
                ],
              ),
            ),
          ] else if (!_processing)
            const Expanded(
              child: Center(
                child: Text(
                  'Tire uma foto ou selecione da galeria para testar o OCR.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String sessionId;
  final int durationMs;
  final int textLength;
  final bool hasRequiredFields;

  const _MetaRow({
    required this.sessionId,
    required this.durationMs,
    required this.textLength,
    required this.hasRequiredFields,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasRequiredFields ? cs.primaryContainer : cs.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SID: $sessionId',
              style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: hasRequiredFields
                      ? cs.onPrimaryContainer
                      : cs.onErrorContainer)),
          Text(
            '${durationMs}ms · $textLength chars · ${hasRequiredFields ? "✓ Campos OK" : "⚠ Sem endereço"}',
            style: TextStyle(
                fontSize: 12,
                color: hasRequiredFields
                    ? cs.onPrimaryContainer
                    : cs.onErrorContainer),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final String label;
  final String? value;
  final bool required;

  const _FieldCard(this.label, this.value, {this.required = false});

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(
          hasValue ? Icons.check_circle : Icons.radio_button_unchecked,
          color: hasValue
              ? Theme.of(context).colorScheme.primary
              : required
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.outlineVariant,
          size: 20,
        ),
        title: Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        subtitle: Text(
          hasValue ? value! : '— não encontrado',
          style: TextStyle(
              fontSize: 13,
              color: hasValue ? null : Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}

class _FlagsCard extends StatelessWidget {
  final OcrResult result;
  const _FlagsCard(this.result);

  @override
  Widget build(BuildContext context) {
    final flags = <String>[];
    if (result.needsIfoodConfirmation) flags.add('iFood');
    if (result.hasDrinks) flags.add('Bebidas');
    if (result.needsCard) flags.add('Maquininha');
    if (result.needsChange) flags.add('Troco');

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        title: const Text('Flags detectadas',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        subtitle: Text(
          flags.isEmpty ? '— nenhuma' : flags.join(', '),
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

class _SandboxCard extends StatelessWidget {
  final String label;
  final String content;
  final bool isError;

  const _SandboxCard(this.label, this.content, {this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: isError ? Theme.of(context).colorScheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SelectableText(
              content,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
