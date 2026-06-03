import 'package:controle_entregas/application/routes/route_notifier.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:controle_entregas/services/ocr_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class NewRouteScreen extends ConsumerStatefulWidget {
  final int shiftId;
  const NewRouteScreen({super.key, required this.shiftId});

  @override
  ConsumerState<NewRouteScreen> createState() => _NewRouteScreenState();
}

class _NewRouteScreenState extends ConsumerState<NewRouteScreen> {
  final _ocrService = OcrService();
  final _picker = ImagePicker();

  int? _routeId;
  final List<OcrResult> _results = [];
  bool _processing = false;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    setState(() => _processing = true);
    final sid = SessionManager.ocr();
    AppLogger.log(
      LogEvents.ocrStart,
      module: 'NewRouteScreen',
      screen: 'NewRouteScreen',
      sessionId: sid,
      metadata: {'source': 'camera'},
    );
    AppLogger.log(
      LogEvents.ocrSourceCamera,
      module: 'NewRouteScreen',
      sessionId: sid,
    );

    // Log permission status before invoking camera
    try {
      final status = await Permission.camera.status;
      if (status.isDenied) await Permission.camera.request();
      final after = await Permission.camera.status;
      AppLogger.log(
        after.isGranted
            ? LogEvents.permissionCameraGranted
            : LogEvents.permissionCameraDenied,
        severity: after.isGranted ? LogSeverity.info : LogSeverity.warning,
        module: 'NewRouteScreen',
        sessionId: sid,
        metadata: {'status': after.name},
      );
    } catch (_) {}

    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
      );
      if (image == null) {
        if (mounted) setState(() => _processing = false);
        return;
      }

      final result = await _ocrService.processImage(image.path);
      _logLocatorCaptured(result, sid, source: 'camera');
      if (!mounted) return;

      if (result.rawText.trim().isEmpty) {
        AppLogger.warn(
          LogEvents.ocrProcessFail,
          module: 'NewRouteScreen',
          sessionId: sid,
          metadata: {'reason': 'empty_raw_text'},
        );
        setState(() => _processing = false);
        _showRecoveryDialog();
        return;
      }

      if (!result.hasRequiredFields) {
        AppLogger.warn(
          LogEvents.ocrLowConfidence,
          module: 'NewRouteScreen',
          sessionId: sid,
        );
      }

      _routeId ??= await ref
          .read(routeNotifierProvider.notifier)
          .createRoute(widget.shiftId);
      if (!mounted) return;

      setState(() {
        _results.add(result);
        _processing = false;
      });
    } catch (e, st) {
      AppLogger.error(
        LogEvents.exception,
        module: 'NewRouteScreen',
        screen: 'NewRouteScreen',
        method: '_captureAndProcess',
        sessionId: sid,
        exception: e,
        stackTrace: st,
      );
      if (mounted) {
        setState(() => _processing = false);
        _showRecoveryDialog();
      }
    }
  }

  Future<void> _importFromGallery() async {
    final sid = SessionManager.ocr();
    AppLogger.log(
      LogEvents.ocrSourceGallery,
      module: 'NewRouteScreen',
      sessionId: sid,
    );

    // Log storage permission status before gallery access
    try {
      final perm = await Permission.photos.status;
      AppLogger.log(
        perm.isGranted
            ? LogEvents.permissionStorageGranted
            : LogEvents.permissionStorageDenied,
        severity: perm.isGranted ? LogSeverity.info : LogSeverity.warning,
        module: 'NewRouteScreen',
        sessionId: sid,
        metadata: {'status': perm.name},
      );
    } catch (_) {}

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );
      if (image == null) return;

      AppLogger.log(
        LogEvents.ocrFileReceived,
        module: 'NewRouteScreen',
        sessionId: sid,
        metadata: {'path': image.path},
      );
      setState(() => _processing = true);

      final result = await _ocrService.processImage(image.path);
      _logLocatorCaptured(result, sid, source: 'gallery');
      if (!mounted) return;

      if (result.rawText.trim().isEmpty) {
        AppLogger.warn(
          LogEvents.galleryOcrFail,
          module: 'NewRouteScreen',
          sessionId: sid,
        );
        setState(() => _processing = false);
        _showRecoveryDialog();
        return;
      }

      AppLogger.info(
        LogEvents.galleryOcrSuccess,
        module: 'NewRouteScreen',
        sessionId: sid,
      );

      _routeId ??= await ref
          .read(routeNotifierProvider.notifier)
          .createRoute(widget.shiftId);
      if (!mounted) return;

      setState(() {
        _results.add(result);
        _processing = false;
      });
    } catch (e, st) {
      AppLogger.error(
        LogEvents.exception,
        module: 'NewRouteScreen',
        method: '_importFromGallery',
        exception: e,
        stackTrace: st,
      );
      if (mounted) {
        setState(() => _processing = false);
        _showRecoveryDialog();
      }
    }
  }

  void _logLocatorCaptured(
    OcrResult result,
    String sid, {
    required String source,
  }) {
    final locator = result.partnerCollectionCode ?? result.deliveryIdentifier;
    if (locator == null || locator.isEmpty) return;
    AppLogger.log(
      LogEvents.locatorCaptured,
      module: 'NewRouteScreen',
      sessionId: sid,
      metadata: {'value': locator, 'length': locator.length, 'source': source},
    );
  }

  void _showRecoveryDialog() {
    AppLogger.info(
      LogEvents.recoveryPopupOpened,
      module: 'NewRouteScreen',
      screen: 'NewRouteScreen',
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Não foi possível ler os dados desta foto'),
        content: const Text(
          'Você pode reenviar a foto, importar uma imagem da galeria ou '
          'registrar a entrega manualmente.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppLogger.info(
                LogEvents.userSelectedRetry,
                module: 'NewRouteScreen',
              );
            },
            child: const Text('Reenviar Foto'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppLogger.info(
                LogEvents.ocrSourceGallery,
                module: 'NewRouteScreen',
              );
              _importFromGallery();
            },
            child: const Text('Importar da Galeria'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppLogger.info(
                LogEvents.userSelectedManualEntry,
                module: 'NewRouteScreen',
              );
              if (mounted) _openManualEntry();
            },
            child: const Text('Manualmente'),
          ),
        ],
      ),
    );
  }

  void _openManualEntry() {
    AppLogger.info(LogEvents.userSelectedManualEntry, module: 'NewRouteScreen');
    context.push(
      '/shift/${widget.shiftId}/manual',
      extra: {'routeId': _routeId},
    );
  }

  Future<void> _proceed() async {
    if (_routeId == null || _results.isEmpty) return;
    if (!mounted) return;
    context.go(
      '/shift/${widget.shiftId}/route/${_routeId!}/review',
      extra: _results,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Rota'),
        actions: [
          if (_results.isNotEmpty && !_processing)
            TextButton(onPressed: _proceed, child: const Text('Revisar')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _results.isEmpty
                ? _EmptyCapture(processing: _processing)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) =>
                        _OcrPreviewCard(result: _results[i], index: i),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (_processing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(),
                  ),
                FilledButton.icon(
                  onPressed: _processing ? null : _captureAndProcess,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tirar Foto'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _processing ? null : _importFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Importar da Galeria'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _processing ? null : _openManualEntry,
                  icon: const Icon(Icons.edit_location_alt_outlined),
                  label: const Text('Entrada Manual'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                if (_results.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _processing ? null : _proceed,
                    icon: const Icon(Icons.check),
                    label: Text('Revisar ${_results.length} comprovante(s)'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCapture extends StatelessWidget {
  final bool processing;
  const _EmptyCapture({required this.processing});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            processing
                ? 'Processando comprovante...'
                : 'Fotografe os comprovantes da rota.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OcrPreviewCard extends StatelessWidget {
  final OcrResult result;
  final int index;
  const _OcrPreviewCard({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.customerName ?? 'Cliente não identificado',
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!result.hasRequiredFields)
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.amber,
                    size: 20,
                  ),
              ],
            ),
            if (result.addressText != null) ...[
              const SizedBox(height: 8),
              Text(
                result.addressText!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (result.orderNumber != null) ...[
              const SizedBox(height: 4),
              Text(
                'Pedido: ${result.orderNumber}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
            if (result.needsIfoodConfirmation ||
                result.hasDrinks ||
                result.needsCard ||
                result.needsChange) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  if (result.needsIfoodConfirmation) _FlagChip('iFood'),
                  if (result.hasDrinks) _FlagChip('Bebidas'),
                  if (result.needsCard) _FlagChip('Maquininha'),
                  if (result.needsChange) _FlagChip('Troco'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  final String label;
  const _FlagChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
