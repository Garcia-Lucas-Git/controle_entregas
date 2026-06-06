import 'dart:convert';

import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/ifood/ifood_provider.dart';
import 'package:controle_entregas/application/settings/settings_notifier.dart';
import 'package:controle_entregas/application/wakelock/wakelock_controller.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IFoodConfirmationScreen extends ConsumerStatefulWidget {
  final int deliveryId;
  final String? deliveryIdentifier;
  final String? partnerCollectionCode;

  const IFoodConfirmationScreen({
    super.key,
    required this.deliveryId,
    this.deliveryIdentifier,
    this.partnerCollectionCode,
  });

  @override
  ConsumerState<IFoodConfirmationScreen> createState() =>
      _IFoodConfirmationScreenState();
}

class _IFoodConfirmationScreenState
    extends ConsumerState<IFoodConfirmationScreen> {
  late WebViewController _webViewController;
  late final String _sid;
  late final WakeLockController _wakeLock;
  final List<String> _codeDigits = [];
  bool _webViewReady = false;
  bool _disposed = false;

  String? get _locatorCode =>
      widget.deliveryIdentifier?.trim().isNotEmpty == true
      ? widget.deliveryIdentifier!.trim()
      : null;

  String? get _locatorDigits => _locatorCode?.replaceAll(RegExp(r'\D'), '');

  int get _expectedDigits {
    final digits = _locatorDigits;
    return digits != null && digits.isNotEmpty ? digits.length : 6;
  }

  @override
  void initState() {
    super.initState();
    _sid = SessionManager.ifood();
    _wakeLock = ref.read(wakeLockControllerProvider.notifier);
    _wakeLock.acquire();
    final locator = _locatorCode;
    if (locator != null) {
      _logLocator(
        LogEvents.locatorCaptured,
        locator,
        extra: {'delivery_id': widget.deliveryId, 'stage': 'ifood_screen_init'},
      );
    }
    AppLogger.log(
      LogEvents.ifoodOpenStart,
      module: 'IFoodConfirmationScreen',
      screen: 'IFoodConfirmationScreen',
      sessionId: _sid,
      metadata: {
        'delivery_id': widget.deliveryId,
        'has_collection_code': widget.partnerCollectionCode != null,
        'has_identifier': widget.deliveryIdentifier != null,
      },
    );
    _initWebView();
  }

  @override
  void dispose() {
    _disposed = true;
    _wakeLock.release();
    super.dispose();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Motorola G56) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/120.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (_disposed) return;
            AppLogger.log(
              LogEvents.ifoodPageLoading,
              module: 'IFoodConfirmationScreen',
              sessionId: _sid,
              metadata: {'url': url},
            );
          },
          onPageFinished: (url) {
            if (_disposed || !mounted) return;
            setState(() => _webViewReady = true);
            ref.read(iFoodNotifierProvider.notifier).onWebViewReady();
            AppLogger.log(
              LogEvents.ifoodPageLoaded,
              module: 'IFoodConfirmationScreen',
              sessionId: _sid,
              metadata: {'url': url},
            );
            _attemptAssistedFill();
          },
          onWebResourceError: (error) {
            if (_disposed || !mounted) return;
            AppLogger.error(
              LogEvents.ifoodPageFail,
              module: 'IFoodConfirmationScreen',
              sessionId: _sid,
              metadata: {
                'description': error.description,
                'error_code': error.errorCode,
                'error_type': error.errorType?.toString(),
                'url': error.url,
              },
            );
            ref
                .read(iFoodNotifierProvider.notifier)
                .onWebViewFailed(error.description);
            _openManualFallback();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_disposed) return NavigationDecision.navigate;
            AppLogger.log(
              LogEvents.ifoodWebviewUrlChanged,
              severity: LogSeverity.verbose,
              module: 'IFoodConfirmationScreen',
              sessionId: _sid,
              metadata: {
                'url': request.url,
                'is_main_frame': request.isMainFrame,
              },
            );
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            if (_disposed) return;
            AppLogger.error(
              LogEvents.ifoodWebviewHttpError,
              module: 'IFoodConfirmationScreen',
              sessionId: _sid,
              metadata: {
                'status_code': error.response?.statusCode,
                'url': error.request?.uri.toString(),
              },
            );
          },
        ),
      );

    // Load the iFood URL after settings are available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_disposed || !mounted) return;
      final settings = await ref.read(settingsNotifierProvider.future);
      if (_disposed || !mounted) return;
      AppLogger.log(
        LogEvents.ifoodPageLoading,
        module: 'IFoodConfirmationScreen',
        sessionId: _sid,
        metadata: {'url': settings.ifoodUrl},
      );
      await _webViewController.loadRequest(Uri.parse(settings.ifoodUrl));
    });
  }

  void _logLocator(String event, String value, {Map<String, dynamic>? extra}) {
    AppLogger.log(
      event,
      module: 'IFoodConfirmationScreen',
      sessionId: _sid,
      metadata: {'value': value, 'length': value.length, ...?extra},
    );
  }

  Future<void> _attemptAssistedFill() async {
    final code = _locatorCode;
    if (code == null || _disposed || !mounted) return;
    await Clipboard.setData(ClipboardData(text: code));
    AppLogger.log(
      LogEvents.ifoodLocatorClipboardCopy,
      module: 'IFoodConfirmationScreen',
      sessionId: _sid,
      metadata: {'code': code, 'trigger': 'assisted_fill'},
    );
    final settings = await ref.read(settingsNotifierProvider.future);
    if (_disposed || !mounted) return;
    final selector = settings.ifoodFieldSelector.trim();
    if (selector.isNotEmpty) {
      await _injectCode(code, selector);
      return;
    }
    AppLogger.log(
      LogEvents.ifoodJsInjectionStart,
      module: 'IFoodConfirmationScreen',
      sessionId: _sid,
      metadata: {'mode': 'best_effort'},
    );
    try {
      final codeLiteral = jsonEncode(code);
      await _webViewController.runJavaScript('''
        (function() {
          var selectors = [
            'input[type="tel"]',
            'input[inputmode="numeric"]',
            'input[name*="code" i]',
            'input[name*="codigo" i]',
            'input[name*="locator" i]',
            'input'
          ];
          for (var i = 0; i < selectors.length; i++) {
            var el = document.querySelector(selectors[i]);
            if (el) {
              el.focus();
              el.value = $codeLiteral;
              el.dispatchEvent(new Event('input', { bubbles: true }));
              el.dispatchEvent(new Event('change', { bubbles: true }));
              return true;
            }
          }
          return false;
        })();
      ''');
      AppLogger.log(
        LogEvents.ifoodJsInjectionSuccess,
        module: 'IFoodConfirmationScreen',
        sessionId: _sid,
        metadata: {'mode': 'best_effort'},
      );
    } catch (e, st) {
      AppLogger.error(
        LogEvents.ifoodJsInjectionFail,
        module: 'IFoodConfirmationScreen',
        sessionId: _sid,
        exception: e,
        stackTrace: st,
      );
      AppLogger.info(
        LogEvents.ifoodManualFallback,
        module: 'IFoodConfirmationScreen',
        sessionId: _sid,
      );
    }
  }

  Future<void> _injectCode(String code, String selector) async {
    if (selector.isEmpty || _disposed || !mounted) return;
    AppLogger.log(
      LogEvents.ifoodJsInjectionStart,
      module: 'IFoodConfirmationScreen',
      sessionId: _sid,
      metadata: {'selector': selector, 'code_length': code.length},
    );
    _logLocator(
      LogEvents.locatorJsInjection,
      code,
      extra: {'selector': selector},
    );
    try {
      final selectorLiteral = jsonEncode(selector);
      final codeLiteral = jsonEncode(code);
      await _webViewController.runJavaScript('''
        (function() {
          var el = document.querySelector($selectorLiteral);
          if (el) {
            el.value = $codeLiteral;
            el.dispatchEvent(new Event('input', { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));
          }
        })();
      ''');
      AppLogger.log(
        LogEvents.ifoodJsInjectionSuccess,
        module: 'IFoodConfirmationScreen',
        sessionId: _sid,
      );
    } catch (e, st) {
      AppLogger.error(
        LogEvents.ifoodJsInjectionFail,
        module: 'IFoodConfirmationScreen',
        sessionId: _sid,
        exception: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _submitCode() async {
    if (_codeDigits.length < _expectedDigits) return;
    if (_disposed || !mounted) return;

    final typedCode = _codeDigits.join();
    final locator = _locatorCode;
    final locatorDigits = _locatorDigits;
    final code = locator != null && locatorDigits == typedCode
        ? locator
        : typedCode;
    _logLocator(
      LogEvents.locatorRequestSent,
      code,
      extra: {'typed_value': typedCode, 'delivery_id': widget.deliveryId},
    );

    final settings = await ref.read(settingsNotifierProvider.future);
    if (_disposed || !mounted) return;

    if (settings.ifoodFieldSelector.isNotEmpty) {
      AppLogger.log(
        LogEvents.ifoodSelectorFound,
        module: 'IFoodConfirmationScreen',
        sessionId: _sid,
        metadata: {'selector': settings.ifoodFieldSelector},
      );
      await _injectCode(code, settings.ifoodFieldSelector);
      if (_disposed || !mounted) return;
    } else {
      AppLogger.warn(
        LogEvents.ifoodSelectorNotFound,
        module: 'IFoodConfirmationScreen',
        sessionId: _sid,
        metadata: {'hint': 'Configure selector in Settings > iFood'},
      );
    }

    if (_disposed || !mounted) return;
    ref.read(iFoodNotifierProvider.notifier).onWebViewSuccess();
    await ref
        .read(deliveryNotifierProvider.notifier)
        .updateIfood(widget.deliveryId, success: true);
    AppLogger.log(
      LogEvents.ifoodConfirmSuccess,
      module: 'IFoodConfirmationScreen',
      sessionId: _sid,
      metadata: {'delivery_id': widget.deliveryId},
    );

    if (_disposed || !mounted) return;
    _showResult(success: true);
  }

  Future<void> _openManualFallback() async {
    if (_disposed || !mounted) return;
    final settings = await ref.read(settingsNotifierProvider.future);
    if (_disposed || !mounted) return;
    final uri = Uri.parse(settings.ifoodUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showResult({required bool success}) {
    if (_disposed || !mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ResultOverlay(
        success: success,
        onDismiss: () {
          Navigator.of(ctx).pop();
          context.pop();
        },
      ),
    );
  }

  void _onDigitTap(String digit) {
    if (_disposed || !mounted) return;
    if (_codeDigits.length >= _expectedDigits) return;
    setState(() => _codeDigits.add(digit));
    if (_codeDigits.length == _expectedDigits) {
      _submitCode();
    }
  }

  void _onBackspace() {
    if (_disposed || !mounted) return;
    if (_codeDigits.isEmpty) return;
    setState(() => _codeDigits.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final ifoodStatus = ref.watch(iFoodNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmação iFood'),
        actions: [
          // Subordinate manual fallback button
          TextButton(
            onPressed: _openManualFallback,
            child: Text(
              'Abrir manualmente',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── WebView (upper ~55%) ──────────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.38,
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (!_webViewReady)
                  const Center(child: CircularProgressIndicator()),
                if (ifoodStatus.state == IFoodState.failed ||
                    ifoodStatus.state == IFoodState.manualFallback)
                  _WebViewErrorBanner(
                    message: ifoodStatus.errorMessage,
                    onRetry: () {
                      if (_disposed || !mounted) return;
                      ref.read(iFoodNotifierProvider.notifier).reset();
                      setState(() => _webViewReady = false);
                      _initWebView();
                    },
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Locator reference ─────────────────────────────────────────
          if (_locatorCode != null)
            _LocatorReference(code: _locatorCode!, sessionId: _sid),

          // ── Code entry display ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_expectedDigits, (i) {
                final filled = i < _codeDigits.length;
                return Container(
                  width: 40,
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: filled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filled ? _codeDigits[i] : '',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Numpad ────────────────────────────────────────────────────
          Expanded(
            child: _NumPad(onDigit: _onDigitTap, onBackspace: _onBackspace),
          ),

          // Manual confirmed option when in fallback
          if (ifoodStatus.state == IFoodState.manualFallback)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: OutlinedButton(
                onPressed: () async {
                  if (_disposed || !mounted) return;
                  ref.read(iFoodNotifierProvider.notifier).onManualConfirmed();
                  await ref
                      .read(deliveryNotifierProvider.notifier)
                      .updateIfood(widget.deliveryId, success: true);
                  if (_disposed || !mounted) return;
                  _showResult(success: true);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Confirmei manualmente'),
              ),
            ),
        ],
      ),
    );
  }
}

// ── NumPad ─────────────────────────────────────────────────────────────────

class _NumPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _NumPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: rows
          .map(
            (row) => Expanded(
              child: Row(
                children: row
                    .map(
                      (label) => Expanded(
                        child: label.isEmpty
                            ? const SizedBox.shrink()
                            : _NumKey(
                                label: label,
                                onTap: label == '⌫'
                                    ? onBackspace
                                    : () => onDigit(label),
                              ),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// ── Result overlay ─────────────────────────────────────────────────────────

class _ResultOverlay extends StatelessWidget {
  final bool success;
  final VoidCallback onDismiss;

  const _ResultOverlay({required this.success, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog.fullscreen(
      backgroundColor: success
          ? colorScheme.primaryContainer
          : colorScheme.errorContainer,
      child: InkWell(
        onTap: onDismiss,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                size: 96,
                color: success ? colorScheme.primary : colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                success ? 'Confirmado!' : 'Falha na confirmação',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: success
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Toque para continuar',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: success
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Locator reference ──────────────────────────────────────────────────────

class _LocatorReference extends StatelessWidget {
  final String code;
  final String sessionId;
  const _LocatorReference({required this.code, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CÓDIGO LOCALIZADOR',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.1,
                    color: colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy, color: colorScheme.onSecondaryContainer),
            tooltip: 'Copiar código',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: code));
              AppLogger.log(
                LogEvents.locatorClipboardCopy,
                module: 'IFoodConfirmationScreen',
                sessionId: sessionId,
                metadata: {'value': code, 'length': code.length},
              );
              AppLogger.log(
                LogEvents.ifoodLocatorClipboardCopy,
                module: 'IFoodConfirmationScreen',
                sessionId: sessionId,
                metadata: {'code': code},
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Código copiado: $code'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── WebView error banner ───────────────────────────────────────────────────

class _WebViewErrorBanner extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _WebViewErrorBanner({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.errorContainer.withValues(alpha: 0.92),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Automação falhou — abrindo manualmente',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Tentar novamente',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
