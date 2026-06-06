// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routesForShiftHash() => r'e6433073f2eef6eaa779fb0d1f604c2bc56c1d6d';

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

/// See also [routesForShift].
@ProviderFor(routesForShift)
const routesForShiftProvider = RoutesForShiftFamily();

/// See also [routesForShift].
class RoutesForShiftFamily extends Family<AsyncValue<List<RouteEntity>>> {
  /// See also [routesForShift].
  const RoutesForShiftFamily();

  /// See also [routesForShift].
  RoutesForShiftProvider call(int shiftId) {
    return RoutesForShiftProvider(shiftId);
  }

  @override
  RoutesForShiftProvider getProviderOverride(
    covariant RoutesForShiftProvider provider,
  ) {
    return call(provider.shiftId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'routesForShiftProvider';
}

/// See also [routesForShift].
class RoutesForShiftProvider
    extends AutoDisposeStreamProvider<List<RouteEntity>> {
  /// See also [routesForShift].
  RoutesForShiftProvider(int shiftId)
    : this._internal(
        (ref) => routesForShift(ref as RoutesForShiftRef, shiftId),
        from: routesForShiftProvider,
        name: r'routesForShiftProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$routesForShiftHash,
        dependencies: RoutesForShiftFamily._dependencies,
        allTransitiveDependencies:
            RoutesForShiftFamily._allTransitiveDependencies,
        shiftId: shiftId,
      );

  RoutesForShiftProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shiftId,
  }) : super.internal();

  final int shiftId;

  @override
  Override overrideWith(
    Stream<List<RouteEntity>> Function(RoutesForShiftRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoutesForShiftProvider._internal(
        (ref) => create(ref as RoutesForShiftRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shiftId: shiftId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<RouteEntity>> createElement() {
    return _RoutesForShiftProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutesForShiftProvider && other.shiftId == shiftId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shiftId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoutesForShiftRef on AutoDisposeStreamProviderRef<List<RouteEntity>> {
  /// The parameter `shiftId` of this provider.
  int get shiftId;
}

class _RoutesForShiftProviderElement
    extends AutoDisposeStreamProviderElement<List<RouteEntity>>
    with RoutesForShiftRef {
  _RoutesForShiftProviderElement(super.provider);

  @override
  int get shiftId => (origin as RoutesForShiftProvider).shiftId;
}

String _$routeByIdHash() => r'ddda8994fc15aa9e35581f16acf4fdc925756a06';

/// See also [routeById].
@ProviderFor(routeById)
const routeByIdProvider = RouteByIdFamily();

/// See also [routeById].
class RouteByIdFamily extends Family<AsyncValue<RouteEntity?>> {
  /// See also [routeById].
  const RouteByIdFamily();

  /// See also [routeById].
  RouteByIdProvider call(int routeId) {
    return RouteByIdProvider(routeId);
  }

  @override
  RouteByIdProvider getProviderOverride(covariant RouteByIdProvider provider) {
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
  String? get name => r'routeByIdProvider';
}

/// See also [routeById].
class RouteByIdProvider extends AutoDisposeStreamProvider<RouteEntity?> {
  /// See also [routeById].
  RouteByIdProvider(int routeId)
    : this._internal(
        (ref) => routeById(ref as RouteByIdRef, routeId),
        from: routeByIdProvider,
        name: r'routeByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$routeByIdHash,
        dependencies: RouteByIdFamily._dependencies,
        allTransitiveDependencies: RouteByIdFamily._allTransitiveDependencies,
        routeId: routeId,
      );

  RouteByIdProvider._internal(
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
    Stream<RouteEntity?> Function(RouteByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RouteByIdProvider._internal(
        (ref) => create(ref as RouteByIdRef),
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
  AutoDisposeStreamProviderElement<RouteEntity?> createElement() {
    return _RouteByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RouteByIdProvider && other.routeId == routeId;
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
mixin RouteByIdRef on AutoDisposeStreamProviderRef<RouteEntity?> {
  /// The parameter `routeId` of this provider.
  int get routeId;
}

class _RouteByIdProviderElement
    extends AutoDisposeStreamProviderElement<RouteEntity?>
    with RouteByIdRef {
  _RouteByIdProviderElement(super.provider);

  @override
  int get routeId => (origin as RouteByIdProvider).routeId;
}

String _$routeNotifierHash() => r'cfdc315e4a087eca01aa6f2a6bd8d5e77dee403a';

/// See also [RouteNotifier].
@ProviderFor(RouteNotifier)
final routeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RouteNotifier, void>.internal(
      RouteNotifier.new,
      name: r'routeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$routeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RouteNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
