// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deliveriesForRouteHash() =>
    r'eb3ef61185c097ad3fe4506655ebcf343d59c113';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [deliveriesForRoute].
@ProviderFor(deliveriesForRoute)
const deliveriesForRouteProvider = DeliveriesForRouteFamily();

/// See also [deliveriesForRoute].
class DeliveriesForRouteFamily extends Family<AsyncValue<List<Delivery>>> {
  /// See also [deliveriesForRoute].
  const DeliveriesForRouteFamily();

  /// See also [deliveriesForRoute].
  DeliveriesForRouteProvider call(int routeId) {
    return DeliveriesForRouteProvider(routeId);
  }

  @override
  DeliveriesForRouteProvider getProviderOverride(
    covariant DeliveriesForRouteProvider provider,
  ) {
    return call(provider.routeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deliveriesForRouteProvider';
}

/// See also [deliveriesForRoute].
class DeliveriesForRouteProvider
    extends AutoDisposeStreamProvider<List<Delivery>> {
  /// See also [deliveriesForRoute].
  DeliveriesForRouteProvider(int routeId)
    : this._internal(
        (ref) => deliveriesForRoute(ref as DeliveriesForRouteRef, routeId),
        from: deliveriesForRouteProvider,
        name: r'deliveriesForRouteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$deliveriesForRouteHash,
        dependencies: DeliveriesForRouteFamily._dependencies,
        allTransitiveDependencies:
            DeliveriesForRouteFamily._allTransitiveDependencies,
        routeId: routeId,
      );

  DeliveriesForRouteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.routeId,
  }) : super.internal();

  final int routeId;

  @override
  Override overrideWith(
    Stream<List<Delivery>> Function(DeliveriesForRouteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeliveriesForRouteProvider._internal(
        (ref) => create(ref as DeliveriesForRouteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        routeId: routeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Delivery>> createElement() {
    return _DeliveriesForRouteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveriesForRouteProvider && other.routeId == routeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, routeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeliveriesForRouteRef on AutoDisposeStreamProviderRef<List<Delivery>> {
  /// The parameter `routeId` of this provider.
  int get routeId;
}

class _DeliveriesForRouteProviderElement
    extends AutoDisposeStreamProviderElement<List<Delivery>>
    with DeliveriesForRouteRef {
  _DeliveriesForRouteProviderElement(super.provider);

  @override
  int get routeId => (origin as DeliveriesForRouteProvider).routeId;
}

String _$deliveryByIdHash() => r'a1a3627166a9248860c96fb923a8641fc580d913';

/// See also [deliveryById].
@ProviderFor(deliveryById)
const deliveryByIdProvider = DeliveryByIdFamily();

/// See also [deliveryById].
class DeliveryByIdFamily extends Family<AsyncValue<Delivery?>> {
  /// See also [deliveryById].
  const DeliveryByIdFamily();

  /// See also [deliveryById].
  DeliveryByIdProvider call(int deliveryId) {
    return DeliveryByIdProvider(deliveryId);
  }

  @override
  DeliveryByIdProvider getProviderOverride(
    covariant DeliveryByIdProvider provider,
  ) {
    return call(provider.deliveryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deliveryByIdProvider';
}

/// See also [deliveryById].
class DeliveryByIdProvider extends AutoDisposeStreamProvider<Delivery?> {
  /// See also [deliveryById].
  DeliveryByIdProvider(int deliveryId)
    : this._internal(
        (ref) => deliveryById(ref as DeliveryByIdRef, deliveryId),
        from: deliveryByIdProvider,
        name: r'deliveryByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$deliveryByIdHash,
        dependencies: DeliveryByIdFamily._dependencies,
        allTransitiveDependencies:
            DeliveryByIdFamily._allTransitiveDependencies,
        deliveryId: deliveryId,
      );

  DeliveryByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deliveryId,
  }) : super.internal();

  final int deliveryId;

  @override
  Override overrideWith(
    Stream<Delivery?> Function(DeliveryByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeliveryByIdProvider._internal(
        (ref) => create(ref as DeliveryByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deliveryId: deliveryId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Delivery?> createElement() {
    return _DeliveryByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveryByIdProvider && other.deliveryId == deliveryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deliveryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeliveryByIdRef on AutoDisposeStreamProviderRef<Delivery?> {
  /// The parameter `deliveryId` of this provider.
  int get deliveryId;
}

class _DeliveryByIdProviderElement
    extends AutoDisposeStreamProviderElement<Delivery?>
    with DeliveryByIdRef {
  _DeliveryByIdProviderElement(super.provider);

  @override
  int get deliveryId => (origin as DeliveryByIdProvider).deliveryId;
}

String _$deliveryNotifierHash() => r'be90c972a29541d17e994a874a867afb5f1f16a8';

/// See also [DeliveryNotifier].
@ProviderFor(DeliveryNotifier)
final deliveryNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DeliveryNotifier, void>.internal(
      DeliveryNotifier.new,
      name: r'deliveryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deliveryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeliveryNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
