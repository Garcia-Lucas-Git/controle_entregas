import 'package:controle_entregas/application/earnings/earnings_notifier.dart';
import 'package:controle_entregas/services/report_generator.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class ShiftReportScreen extends ConsumerWidget {
  final int shiftId;
  const ShiftReportScreen({super.key, required this.shiftId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync =
        ref.watch(shiftReportDataProvider(shiftId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Turno'),
        actions: [
          reportAsync.when(
            data: (data) => IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Compartilhar',
              onPressed: () => _share(data),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Erro: $e')),
        data: (data) {
          final text = ReportGenerator.generate(data);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                Row(
                  children: [
                    _SummaryCard(
                      label: 'Entregas',
                      value: '${data.totalDeliveries}',
                      icon: Icons.local_shipping,
                    ),
                    const SizedBox(width: 12),
                    _SummaryCard(
                      label: 'Ganhos',
                      value: data.totalEarnings.format(),
                      icon: Icons.attach_money,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Report text preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    text,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: () => _share(data),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar via WhatsApp'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _share(ShiftReportData data) async {
    final text = ReportGenerator.generate(data);
    await Share.share(text, subject: 'Relatório de Turno — DeliveryFlow');
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  color: Theme.of(context).colorScheme.primary, size: 22),
              const SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
