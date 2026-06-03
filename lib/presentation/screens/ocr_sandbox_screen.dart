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
  final _rawTextCtrl = TextEditingController();

  bool _rawMode = false;
  OcrResult? _result;
  String? _sessionId;
  int? _durationMs;
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _rawTextCtrl.dispose();
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
    AppLogger.log(
      LogEvents.ocrSandboxStarted,
      module: 'OcrSandboxScreen',
      sessionId: sid,
      metadata: {'source': source.name},
    );

    try {
      final image = await _picker.pickImage(source: source, imageQuality: 95);
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
      AppLogger.error(
        LogEvents.exception,
        module: 'OcrSandboxScreen',
        sessionId: sid,
        exception: e,
        stackTrace: st,
      );
      setState(() {
        _error = e.toString();
        _processing = false;
      });
    }
  }

  Future<void> _runRawText() async {
    final text = _rawTextCtrl.text;
    if (text.trim().isEmpty) return;
    setState(() {
      _processing = true;
      _result = null;
      _error = null;
    });

    final sid = SessionManager.ocr();
    AppLogger.log(
      LogEvents.ocrSandboxStarted,
      module: 'OcrSandboxScreen',
      sessionId: sid,
      metadata: {'source': 'raw_text'},
    );

    try {
      final t0 = DateTime.now();
      final result = OcrService.parseRawText(text);
      final ms = DateTime.now().difference(t0).inMilliseconds;
      setState(() {
        _result = result;
        _sessionId = sid;
        _durationMs = ms;
        _processing = false;
      });
    } catch (e, st) {
      AppLogger.error(
        LogEvents.exception,
        module: 'OcrSandboxScreen',
        sessionId: sid,
        exception: e,
        stackTrace: st,
      );
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
                  const SnackBar(content: Text('Session ID copiado')),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.image_outlined),
                  label: Text('Imagem'),
                ),
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.text_fields),
                  label: Text('Texto'),
                ),
              ],
              selected: {_rawMode},
              onSelectionChanged: (v) => setState(() => _rawMode = v.first),
            ),
          ),
          if (!_rawMode)
            _ImageActions(processing: _processing, run: _run)
          else
            _RawTextActions(
              controller: _rawTextCtrl,
              processing: _processing,
              onRun: _runRawText,
            ),
          if (_processing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(),
            ),
          if (_error != null) _SandboxCard('Erro', _error!, isError: true),
          if (_result != null)
            _ResultView(
              result: _result!,
              sessionId: _sessionId!,
              durationMs: _durationMs!,
            )
          else if (!_processing)
            Expanded(
              child: Center(
                child: Text(
                  _rawMode
                      ? 'Cole um texto OCR bruto para testar o parser.'
                      : 'Tire uma foto ou selecione da galeria para testar o OCR.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageActions extends StatelessWidget {
  final bool processing;
  final Future<void> Function(ImageSource source) run;

  const _ImageActions({required this.processing, required this.run});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: processing ? null : () => run(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Câmera'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: processing ? null : () => run(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeria'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RawTextActions extends StatelessWidget {
  final TextEditingController controller;
  final bool processing;
  final VoidCallback onRun;

  const _RawTextActions({
    required this.controller,
    required this.processing,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Texto OCR bruto',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: processing ? null : onRun,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Simular Parser'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final OcrResult result;
  final String sessionId;
  final int durationMs;

  const _ResultView({
    required this.result,
    required this.sessionId,
    required this.durationMs,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _MetaRow(
            sessionId: sessionId,
            durationMs: durationMs,
            textLength: result.rawText.length,
            hasRequiredFields: result.hasRequiredFields,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _FieldCard('Endereço', result.addressText, required: true),
                _FieldCard(
                  'Localizador (collection)',
                  result.partnerCollectionCode,
                ),
                _FieldCard('Identificador', result.deliveryIdentifier),
                _FieldCard('Cliente', result.customerName),
                _FieldCard('Pedido', result.orderNumber),
                _FieldCard('Bairro', result.neighborhood),
                _MissingFieldsCard(result),
                _FlagsCard(result),
                _SandboxCard(
                  'Texto bruto (preview)',
                  result.rawText.length > 500
                      ? '${result.rawText.substring(0, 500)}…'
                      : result.rawText,
                ),
              ],
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
          Text(
            'SID: $sessionId',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: hasRequiredFields
                  ? cs.onPrimaryContainer
                  : cs.onErrorContainer,
            ),
          ),
          Text(
            '$durationMs ms · $textLength chars · '
            '${hasRequiredFields ? "Campos OK" : "Sem endereço"}',
            style: TextStyle(
              fontSize: 12,
              color: hasRequiredFields
                  ? cs.onPrimaryContainer
                  : cs.onErrorContainer,
            ),
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
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          hasValue ? value! : '— não encontrado',
          style: TextStyle(
            fontSize: 13,
            color: hasValue ? null : Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _MissingFieldsCard extends StatelessWidget {
  final OcrResult result;

  const _MissingFieldsCard(this.result);

  @override
  Widget build(BuildContext context) {
    final missing = <String>[];
    if (result.addressText == null || result.addressText!.trim().isEmpty) {
      missing.add('endereço');
    }
    if ((result.partnerCollectionCode == null ||
            result.partnerCollectionCode!.trim().isEmpty) &&
        (result.deliveryIdentifier == null ||
            result.deliveryIdentifier!.trim().isEmpty)) {
      missing.add('localizador');
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        title: const Text(
          'Validação',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          missing.isEmpty
              ? 'Campos obrigatórios encontrados'
              : 'Faltando: ${missing.join(', ')}',
          style: const TextStyle(fontSize: 13),
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
        title: const Text(
          'Flags detectadas',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
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
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
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
