// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$openShiftHash() => r'bdcc41ec71cd23c1ddada29d40c4029023b9dfa2';

/// See also [openShift].
@ProviderFor(openShift)
final openShiftProvider = AutoDisposeStreamProvider<Shift?>.internal(
  openShift,
  name: r'openShiftProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$openShiftHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenShiftRef = AutoDisposeStreamProviderRef<Shift?>;
String _$allShiftsHash() => r'46a56e2cb689eef88f525bac8ab7ad47810fc804';

/// See also [allShifts].
@ProviderFor(allShifts)
final allShiftsProvider = AutoDisposeStreamProvider<List<Shift>>.internal(
  allShifts,
  name: r'allShiftsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allShiftsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllShiftsRef = AutoDisposeStreamProviderRef<List<Shift>>;
String _$shiftNotifierHash() => r'14da55a14382c0d600b93ee62eb23b2626f6d5a4';

/// See also [ShiftNotifier].
@ProviderFor(ShiftNotifier)
final shiftNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ShiftNotifier, Shift?>.internal(
      ShiftNotifier.new,
      name: r'shiftNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shiftNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShiftNotifier = AutoDisposeAsyncNotifier<Shift?>;
String _$historicalEntryNotifierHash() =>
    r'47952afe1ceaa02f822979ffb93cb2be60f3793e';

/// See also [HistoricalEntryNotifier].
@ProviderFor(HistoricalEntryNotifier)
final historicalEntryNotifierProvider =
    AutoDisposeAsyncNotifierProvider<HistoricalEntryNotifier, void>.internal(
      HistoricalEntryNotifier.new,
      name: r'historicalEntryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historicalEntryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HistoricalEntryNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
