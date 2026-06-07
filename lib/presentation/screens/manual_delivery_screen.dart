import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/routes/route_notifier.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ManualDeliveryScreen extends ConsumerStatefulWidget {
  final int shiftId;
  final int? routeId;

  const ManualDeliveryScreen({super.key, required this.shiftId, this.routeId});

  @override
  ConsumerState<ManualDeliveryScreen> createState() =>
      _ManualDeliveryScreenState();
}

class _ManualDeliveryScreenState extends ConsumerState<ManualDeliveryScreen> {
  final _locatorCtrl = TextEditingController();
  final _pizzaCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  bool _saving = false;
  String? _locatorError;
  String? _pizzaError;

  @override
  void dispose() {
    _locatorCtrl.dispose();
    _pizzaCtrl.dispose();
    _addressCtrl.dispose();
    _houseCtrl.dispose();
    _customerCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final locator = _locatorCtrl.text.trim();
    final pizza = _pizzaCtrl.text.trim();
    bool hasError = false;
    if (locator.isEmpty) {
      setState(() => _locatorError = 'Obrigatório');
      hasError = true;
    }
    if (pizza.isEmpty) {
      setState(() => _pizzaError = 'Obrigatório');
      hasError = true;
    }
    if (hasError) return;

    setState(() {
      _locatorError = null;
      _pizzaError = null;
      _saving = true;
    });

    try {
      final routeId =
          widget.routeId ??
          await ref
              .read(routeNotifierProvider.notifier)
              .createRoute(widget.shiftId);

      final address = _addressCtrl.text.trim();
      final house = _houseCtrl.text.trim();
      final customer = _customerCtrl.text.trim();

      final fullAddress = address.isEmpty
          ? '—'
          : house.isNotEmpty
              ? '$address, $house'
              : address;

      await ref
          .read(deliveryNotifierProvider.notifier)
          .createManual(
            routeId: routeId,
            shiftId: widget.shiftId,
            sequenceNumber: 1,
            addressText: address.isEmpty ? '—' : address,
            houseNumber: house.isEmpty ? null : house,
            customerName: customer.isEmpty ? null : customer,
            orderNumber: locator,
            deliveryIdentifier: locator,
            pizzaNumber: pizza,
          );

      AppLogger.info(
        LogEvents.deliveryCreateSuccess,
        module: 'ManualDeliveryScreen',
        metadata: {
          'route_id': routeId,
          'locator': locator,
          'pizza': pizza,
          'address': fullAddress,
        },
      );
      AppLogger.log(
        LogEvents.pizzaNumberAdded,
        module: 'ManualDeliveryScreen',
        metadata: {'pizza': pizza, 'route_id': routeId},
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
            // Pizza number — primary operational field
            TextField(
              controller: _pizzaCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                labelText: '🍕 Número da Pizza *',
                border: const OutlineInputBorder(),
                errorText: _pizzaError,
                prefixIcon: const Icon(Icons.local_pizza_outlined),
                hintText: 'Ex: 42',
              ),
              onChanged: (_) {
                if (_pizzaError != null) setState(() => _pizzaError = null);
              },
            ),
            const SizedBox(height: 20),

            // Locator code — iFood identifier
            TextField(
              controller: _locatorCtrl,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 20,
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
                if (_locatorError != null) setState(() => _locatorError = null);
              },
            ),
            const SizedBox(height: 20),

            // Address split into rua + number
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                      border: OutlineInputBorder(),
                      hintText: 'Rua / Av.',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _houseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nº',
                      border: OutlineInputBorder(),
                      hintText: '123',
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
              ],
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
