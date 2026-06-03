import 'dart:convert';
import 'dart:typed_data';

import 'package:controle_entregas/data/repositories/delivery_repository.dart';
import 'package:controle_entregas/data/repositories/earnings_repository.dart';
import 'package:controle_entregas/data/repositories/route_repository.dart';
import 'package:controle_entregas/data/repositories/shift_repository.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  final ShiftRepository _shifts;
  final RouteRepository _routes;
  final DeliveryRepository _deliveries;
  final EarningsRepository _earnings;

  ExportService({
    required this._shifts,
    required this._routes,
    required this._deliveries,
    required this._earnings,
  });

  Future<void> exportCsv({DateTime? from, DateTime? to}) async {
    final allShifts = await _shifts.watchAllShifts().first;

    final filtered = allShifts.where((s) {
      if (from != null && s.startedAt.isBefore(from)) return false;
      if (to != null && s.startedAt.isAfter(to)) return false;
      return true;
    }).toList();

    final rows = <List<String>>[];
    rows.add(_headers());

    for (final shift in filtered) {
      final routes = await _routes.getRoutesForShift(shift.id);
      for (final route in routes) {
        if (route.isOpen) continue;
        final deliveries = await _deliveries.getDeliveriesForRoute(route.id);
        final entries = await _earnings.getEntriesForShift(shift.id);
        final entry =
            entries.where((e) => e.routeId == route.id).firstOrNull;

        for (final d in deliveries.where((d) => d.isCompleted)) {
          final earningsType = entry?.earningsType.toJson() ?? 'normal';
          final rateCents = entry?.rateApplied.cents ?? 800;

          rows.add([
            _fmtDate(d.completedAt ?? d.createdAt),
            '${shift.id}',
            '${route.routeNumber}',
            '${d.sequenceNumber}',
            d.customerName ?? '',
            d.addressText,
            d.orderNumber ?? '',
            earningsType,
            '$rateCents',
            _formatReais(rateCents),
            (d.completedAt ?? d.createdAt).toIso8601String(),
          ]);
        }
      }
    }

    final csv = _buildCsv(rows);
    // UTF-8 BOM for Google Sheets compatibility
    final bom = [0xEF, 0xBB, 0xBF];
    final bytes = Uint8List.fromList([...bom, ...utf8.encode(csv)]);

    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: 'deliveryflow_export.csv',
          mimeType: 'text/csv',
        ),
      ],
      subject: 'DeliveryFlow — Exportação de dados',
    );
  }

  List<String> _headers() => [
        'data',
        'turno_id',
        'numero_rota',
        'ordem_entrega',
        'nome_cliente',
        'endereco',
        'numero_pedido',
        'tipo_ganho',
        'valor_centavos',
        'valor_reais',
        'horario_conclusao',
      ];

  String _buildCsv(List<List<String>> rows) =>
      rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');

  String _escapeCsv(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _fmtDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  String _formatReais(int cents) {
    final reais = cents ~/ 100;
    final c = cents % 100;
    return '$reais,${c.toString().padLeft(2, '0')}';
  }
}
