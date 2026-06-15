import 'package:controle_entregas/application/deliveries/delivery_notifier.dart';
import 'package:controle_entregas/application/routes/route_notifier.dart';
import 'package:controle_entregas/presentation/utils/currency_input.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _drinkOptions = [
  'Coca 1L',
  'Coca 1,5L',
  'Coca 2L',
  'Coca Zero 1L',
  'Coca Zero 2L',
  'Fanta Laranja 1L',
  'Fanta Laranja 2L',
  'Sprite 1L',
  'Guaraná 1L',
  'Outros',
];

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
  final _complementCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _cardAmountCtrl = TextEditingController();
  bool _needsCard = false;
  bool _hasDrinks = false;
  String? _drinkType;
  bool _saving = false;
  String? _locatorError;
  String? _pizzaError;

  @override
  void dispose() {
    _locatorCtrl.dispose();
    _pizzaCtrl.dispose();
    _addressCtrl.dispose();
    _houseCtrl.dispose();
    _complementCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _customerCtrl.dispose();
    _cardAmountCtrl.dispose();
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
    final cardAmountCents = parseBrazilianCurrencyToCents(_cardAmountCtrl.text);
    if (_needsCard && cardAmountCents == null) {
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
      final complement = _complementCtrl.text.trim();
      final neighborhood = _neighborhoodCtrl.text.trim();
      final customer = _customerCtrl.text.trim();
      final sequence = await ref
          .read(deliveryNotifierProvider.notifier)
          .nextSequenceForRoute(routeId);

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
            sequenceNumber: sequence,
            addressText: address.isEmpty ? '—' : address,
            houseNumber: house.isEmpty ? null : house,
            complement: complement.isEmpty ? null : complement,
            neighborhood: neighborhood.isEmpty ? null : neighborhood,
            customerName: customer.isEmpty ? null : customer,
            orderNumber: locator,
            deliveryIdentifier: locator,
            pizzaNumber: pizza,
            hasDrinks: _hasDrinks,
            drinkType: _hasDrinks ? _drinkType : null,
            needsCard: _needsCard,
            cardAmountCents: _needsCard ? cardAmountCents : null,
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

            TextField(
              controller: _complementCtrl,
              decoration: const InputDecoration(
                labelText: 'Complemento',
                border: OutlineInputBorder(),
                hintText: 'Casa fundo, bloco B, apto 302',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _neighborhoodCtrl,
              decoration: const InputDecoration(
                labelText: 'Bairro',
                border: OutlineInputBorder(),
                hintText: 'Opcional',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tem refrigerante'),
              value: _hasDrinks,
              onChanged: (value) => setState(() {
                _hasDrinks = value;
                if (!value) _drinkType = null;
              }),
            ),
            if (_hasDrinks) ...[
              DropdownButtonFormField<String>(
                initialValue: _drinkType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de refrigerante',
                  border: OutlineInputBorder(),
                ),
                items: _drinkOptions
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _drinkType = value),
              ),
              const SizedBox(height: 16),
            ],

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Maquininha'),
              value: _needsCard,
              onChanged: (value) => setState(() {
                _needsCard = value;
                if (!value) _cardAmountCtrl.clear();
              }),
            ),
            if (_needsCard) ...[
              TextField(
                controller: _cardAmountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: brazilianCurrencyInputFormatters,
                decoration: InputDecoration(
                  labelText: 'Valor da Maquininha *',
                  prefixText: 'R\$ ',
                  border: const OutlineInputBorder(),
                  errorText:
                      parseBrazilianCurrencyToCents(_cardAmountCtrl.text) ==
                          null
                      ? 'Obrigatório'
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
            ],

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
