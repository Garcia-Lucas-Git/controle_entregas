// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shiftReportDataHash() => r'2a78f07793eec95204a4d9196a044920bfe60fe8';

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

/// See also [shiftReportData].
@ProviderFor(shiftReportData)
const shiftReportDataProvider = ShiftReportDataFamily();

/// See also [shiftReportData].
class ShiftReportDataFamily extends Family<AsyncValue<ShiftReportData>> {
  /// See also [shiftReportData].
  const ShiftReportDataFamily();

  /// See also [shiftReportData].
  ShiftReportDataProvider call(int shiftId) {
    return ShiftReportDataProvider(shiftId);
  }

  @override
  ShiftReportDataProvider getProviderOverride(
    covariant ShiftReportDataProvider provider,
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
  String? get name => r'shiftReportDataProvider';
}

/// See also [shiftReportData].
class ShiftReportDataProvider
    extends AutoDisposeFutureProvider<ShiftReportData> {
  /// See also [shiftReportData].
  ShiftReportDataProvider(int shiftId)
    : this._internal(
        (ref) => shiftReportData(ref as ShiftReportDataRef, shiftId),
        from: shiftReportDataProvider,
        name: r'shiftReportDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$shiftReportDataHash,
        dependencies: ShiftReportDataFamily._dependencies,
        allTransitiveDependencies:
            ShiftReportDataFamily._allTransitiveDependencies,
        shiftId: shiftId,
      );

  ShiftReportDataProvider._internal(
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
    FutureOr<ShiftReportData> Function(ShiftReportDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShiftReportDataProvider._internal(
        (ref) => create(ref as ShiftReportDataRef),
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
  AutoDisposeFutureProviderElement<ShiftReportData> createElement() {
    return _ShiftReportDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShiftReportDataProvider && other.shiftId == shiftId;
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
mixin ShiftReportDataRef on AutoDisposeFutureProviderRef<ShiftReportData> {
  /// The parameter `shiftId` of this provider.
  int get shiftId;
}

class _ShiftReportDataProviderElement
    extends AutoDisposeFutureProviderElement<ShiftReportData>
    with ShiftReportDataRef {
  _ShiftReportDataProviderElement(super.provider);

  @override
  int get shiftId => (origin as ShiftReportDataProvider).shiftId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
