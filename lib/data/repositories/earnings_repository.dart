import 'dart:convert';

import 'package:controle_entregas/data/database/app_database.dart';
import 'package:controle_entregas/data/database/daos/earnings_dao.dart';
import 'package:controle_entregas/domain/entities/delivery.dart';
import 'package:controle_entregas/domain/entities/earnings_entry.dart';
import 'package:controle_entregas/domain/enums/earnings_type.dart';
import 'package:controle_entregas/domain/value_objects/earnings_rules.dart';
import 'package:controle_entregas/domain/value_objects/money.dart';
import 'package:drift/drift.dart';

class EarningsRepository {
  final EarningsDao _dao;

  EarningsRepository(AppDatabase db) : _dao = db.earningsDao;

  Future<EarningsConfig> getCurrentConfig() async {
    final row = await _dao.getCurrentConfig();
    if (row == null) return const EarningsConfig.defaults();
    return EarningsConfig(
      baseRateCents: row.baseRateCents,
      longSingleDeliveryRateCents: row.longSingleDeliveryRateCents,
    );
  }

  Future<void> updateConfig({
    required int baseRateCents,
    required int longSingleDeliveryRateCents,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return _dao.updateCurrentConfig(
      baseRateCents: baseRateCents,
      longSingleDeliveryRateCents: longSingleDeliveryRateCents,
      effectiveFrom: now,
    );
  }

  /// Called at route close time. Classifies and persists the earnings entry.
  Future<EarningsEntry> classifyAndSaveRoute({
    required int routeId,
    required int shiftId,
    required int deliveryCountAtClose,
    required List<Delivery> completedDeliveries,
  }) async {
    final config = await getCurrentConfig();

    // For single-delivery routes, use that delivery's distance
    final distanceKm =
        deliveryCountAtClose == 1 && completedDeliveries.isNotEmpty
        ? completedDeliveries.first.distanceKm
        : null;

    final type = EarningsRules.classify(
      deliveryCountAtClose: deliveryCountAtClose,
      distanceKm: distanceKm,
    );
    final rate = EarningsRules.rateFor(type, config);

    final reason = _buildReason(
      type: type,
      deliveryCount: deliveryCountAtClose,
      distanceKm: distanceKm,
    );

    final snapshot = jsonEncode(config.toJson());
    final now = DateTime.now().toUtc().toIso8601String();

    final id = await _dao.insertEarningsEntry(
      EarningsEntriesTableCompanion(
        routeId: Value(routeId),
        shiftId: Value(shiftId),
        earningsType: Value(type.toJson()),
        rateAppliedCents: Value(rate.cents),
        routeDeliveryCount: Value(deliveryCountAtClose),
        routeDistanceKm: Value(distanceKm),
        classificationReason: Value(reason),
        configSnapshot: Value(snapshot),
        createdAt: Value(now),
      ),
    );

    return EarningsEntry(
      id: id,
      routeId: routeId,
      shiftId: shiftId,
      earningsType: type,
      rateApplied: rate,
      routeDeliveryCount: deliveryCountAtClose,
      routeDistanceKm: distanceKm,
      classificationReason: reason,
      configSnapshot: snapshot,
      createdAt: DateTime.parse(now),
    );
  }

  Future<void> syncRouteEntry({
    required int routeId,
    required int shiftId,
    required List<Delivery> completedDeliveries,
  }) async {
    final deliveryCount = completedDeliveries.length;
    if (deliveryCount == 0) {
      await _dao.deleteEntryForRoute(routeId);
      return;
    }

    final existing = await _dao.getEntryForRoute(routeId);
    if (existing != null) {
      await _dao.updateRouteEntry(
        routeId: routeId,
        earningsType: existing.earningsType,
        rateAppliedCents: existing.rateAppliedCents,
        routeDeliveryCount: deliveryCount,
        routeDistanceKm: existing.routeDistanceKm,
        classificationReason: existing.classificationReason,
        configSnapshot: existing.configSnapshot,
      );
      return;
    }

    final config = await getCurrentConfig();
    final distanceKm = deliveryCount == 1
        ? completedDeliveries.first.distanceKm
        : null;
    final type = EarningsRules.classify(
      deliveryCountAtClose: deliveryCount,
      distanceKm: distanceKm,
    );
    final rate = EarningsRules.rateFor(type, config);
    final reason = _buildReason(
      type: type,
      deliveryCount: deliveryCount,
      distanceKm: distanceKm,
    );
    final snapshot = jsonEncode(config.toJson());
    await _dao.insertEarningsEntry(
      EarningsEntriesTableCompanion(
        routeId: Value(routeId),
        shiftId: Value(shiftId),
        earningsType: Value(type.toJson()),
        rateAppliedCents: Value(rate.cents),
        routeDeliveryCount: Value(deliveryCount),
        routeDistanceKm: Value(distanceKm),
        classificationReason: Value(reason),
        configSnapshot: Value(snapshot),
        createdAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  /// Decrements routeDeliveryCount by 1 for the given route's earnings entry.
  /// Deletes the entry when count reaches 0.
  Future<void> deleteEntryForRoute(int routeId) =>
      _dao.deleteEntryForRoute(routeId);

  Future<void> decrementRouteDelivery(int routeId) async {
    final row = await _dao.getEntryForRoute(routeId);
    if (row == null) return;
    final newCount = row.routeDeliveryCount - 1;
    if (newCount <= 0) {
      await _dao.deleteEntryForRoute(routeId);
    } else {
      await _dao.updateEntryDeliveryCount(routeId, newCount);
    }
  }

  Future<List<EarningsEntry>> getEntriesForShift(int shiftId) async {
    final rows = await _dao.getEntriesForShift(shiftId);
    return rows.map(_entryFromRow).toList();
  }

  Stream<List<EarningsEntry>> watchEntriesForShift(int shiftId) => _dao
      .watchEntriesForShift(shiftId)
      .map((r) => r.map(_entryFromRow).toList());

  static String _buildReason({
    required EarningsType type,
    required int deliveryCount,
    required double? distanceKm,
  }) {
    if (deliveryCount > 1) {
      return 'Rota com $deliveryCount entregas — tarifa base aplicada';
    }
    if (type == EarningsType.longSingleDelivery && distanceKm != null) {
      return 'Entrega única com distância de '
          '${distanceKm.toStringAsFixed(1)}km — '
          'tarifa longa aplicada (limite: '
          '${EarningsRules.kLongSingleDeliveryThresholdKm.toStringAsFixed(1)}km)';
    }
    if (distanceKm != null) {
      return 'Entrega única com distância de '
          '${distanceKm.toStringAsFixed(1)}km — '
          'abaixo do limite de '
          '${EarningsRules.kLongSingleDeliveryThresholdKm.toStringAsFixed(1)}km';
    }
    return 'Entrega única sem distância registrada — '
        'classificada como normal (padrão conservador)';
  }

  static EarningsEntry _entryFromRow(EarningsEntriesTableData r) =>
      EarningsEntry(
        id: r.id,
        routeId: r.routeId,
        shiftId: r.shiftId,
        earningsType: EarningsType.fromJson(r.earningsType),
        rateApplied: Money(r.rateAppliedCents),
        routeDeliveryCount: r.routeDeliveryCount,
        routeDistanceKm: r.routeDistanceKm,
        classificationReason: r.classificationReason,
        configSnapshot: r.configSnapshot,
        createdAt: DateTime.parse(r.createdAt),
      );
}
