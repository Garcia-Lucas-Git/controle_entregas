import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/routes/route_notifier.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum _RouteType { single, multiple }

class ManualDeliveryScreen extends ConsumerStatefulWidget {
  final int shiftId;
  final int? routeId;

  const ManualDeliveryScreen({super.key, required this.shiftId, this.routeId});

  @override
  ConsumerState<ManualDeliveryScreen> createState() =>
      _ManualDeliveryScreenState();
}

class _ManualDeliveryScreenState extends ConsumerState<ManualDeliveryScreen> {
  // Locator code is the primary field — first and required
  final _locatorCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  _RouteType _routeType = _RouteType.single;
  bool _saving = false;
  String? _locatorError;

  @override
  void dispose() {
    _locatorCtrl.dispose();
    _addressCtrl.dispose();
    _customerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final locator = _locatorCtrl.text.trim();
    if (locator.isEmpty) {
      setState(() => _locatorError = 'Obrigatório');
      return;
    }
    setState(() {
      _locatorError = null;
      _saving = true;
    });

    try {
      final routeId =
          widget.routeId ??
          await ref
              .read(routeNotifierProvider.notifier)
              .createRoute(widget.shiftId);

      final address = _addressCtrl.text.trim();
      final customer = _customerCtrl.text.trim();

      await ref
          .read(deliveryNotifierProvider.notifier)
          .createManual(
            routeId: routeId,
            shiftId: widget.shiftId,
            sequenceNumber: 1,
            addressText: address.isEmpty ? '—' : address,
            customerName: customer.isEmpty ? null : customer,
            orderNumber: locator,
            partnerCollectionCode: locator,
          );

      AppLogger.info(
        LogEvents.deliveryCreateSuccess,
        module: 'ManualDeliveryScreen',
        metadata: {'route_id': routeId, 'locator': locator},
      );

      if (!mounted) return;
      context.go('/shift/${widget.shiftId}/route/$routeId/active');
    } catch (e) {
      AppLogger.log(
        LogEvents.exception,
        module: 'ManualDeliveryScreen',
        error: e,
      );
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao registrar entrega. Tente novamente.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Manualmente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Locator code — primary, top, large
            TextField(
              controller: _locatorCtrl,
              autofocus: true,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                labelText: 'Código Localizador *',
                border: const OutlineInputBorder(),
                errorText: _locatorError,
                prefixIcon: const Icon(Icons.tag),
                hintText: 'Ex: 123456',
              ),
              onChanged: (_) {
                if (_locatorError != null) {
                  setState(() => _locatorError = null);
                }
              },
            ),
            const SizedBox(height: 20),

            // Address — optional
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                border: OutlineInputBorder(),
                hintText: 'Opcional',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Customer — optional
            TextField(
              controller: _customerCtrl,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                border: OutlineInputBorder(),
                hintText: 'Opcional',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            // Route type — secondary, at bottom
            Text('Tipo de Rota', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<_RouteType>(
              segments: const [
                ButtonSegment(
                  value: _RouteType.single,
                  label: Text('Entrega única'),
                ),
                ButtonSegment(
                  value: _RouteType.multiple,
                  label: Text('Múltiplas entregas'),
                ),
              ],
              selected: {_routeType},
              onSelectionChanged: (s) => setState(() => _routeType = s.first),
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Registrar Entrega'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
