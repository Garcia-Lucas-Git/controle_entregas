import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class MapsLauncher {
  static MapsNavigationRequest? buildNavigationRequest(List<String> addresses) {
    if (addresses.isEmpty) return null;
    final encoded = addresses.map(Uri.encodeComponent).toList();
    String primary;
    String fallback;

    if (addresses.length == 1) {
      primary = 'google.navigation:q=${encoded.first}&mode=d';
      fallback =
          'https://www.google.com/maps/dir/?api=1&destination=${encoded.first}&travelmode=driving';
    } else {
      final destination = encoded.last;
      final waypoints = encoded.sublist(0, encoded.length - 1).join('|');
      primary =
          'https://www.google.com/maps/dir/?api=1&destination=$destination&waypoints=$waypoints&travelmode=driving';
      fallback =
          'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving';
    }

    return MapsNavigationRequest(primary: primary, fallback: fallback);
  }

  static Future<void> navigateTo(List<String> addresses) async {
    final sid = SessionManager.maps();

    if (addresses.isEmpty) {
      AppLogger.warn(
        LogEvents.mapsAddressEmpty,
        module: 'MapsLauncher',
        sessionId: sid,
      );
      return;
    }

    AppLogger.log(
      LogEvents.mapsOpenStart,
      module: 'MapsLauncher',
      sessionId: sid,
      metadata: {'count': addresses.length, 'destinations': addresses},
    );

    final request = buildNavigationRequest(addresses);
    if (request == null) return;

    AppLogger.log(
      LogEvents.mapsUriGenerated,
      module: 'MapsLauncher',
      sessionId: sid,
      metadata: {'primary': request.primary, 'fallback': request.fallback},
    );
    AppLogger.log(
      LogEvents.mapsRouteCreated,
      module: 'MapsLauncher',
      sessionId: sid,
      metadata: {'stop_count': addresses.length, 'destinations': addresses},
    );

    final launched = await _launch(
      request.primary,
      fallback: request.fallback,
      sid: sid,
    );
    if (launched) {
      AppLogger.info(
        LogEvents.mapsOpenSuccess,
        module: 'MapsLauncher',
        sessionId: sid,
      );
      AppLogger.log(
        LogEvents.mapsRouteOpened,
        module: 'MapsLauncher',
        sessionId: sid,
        metadata: {'stop_count': addresses.length},
      );
    } else {
      AppLogger.warn(
        LogEvents.mapsOpenFail,
        module: 'MapsLauncher',
        sessionId: sid,
        metadata: {'primary': request.primary, 'fallback': request.fallback},
      );
    }
  }

  static Future<bool> _launch(
    String primary, {
    required String fallback,
    required String sid,
  }) async {
    final primaryUri = Uri.parse(primary);
    final fallbackUri = Uri.parse(fallback);
    if (await _tryLaunch(primaryUri, sid: sid, label: 'primary')) return true;
    return _tryLaunch(fallbackUri, sid: sid, label: 'fallback');
  }

  static Future<bool> _tryLaunch(
    Uri uri, {
    required String sid,
    required String label,
  }) async {
    try {
      final canLaunch = await canLaunchUrl(uri);
      AppLogger.log(
        LogEvents.mapsLaunchCallback,
        module: 'MapsLauncher',
        sessionId: sid,
        metadata: {
          'target': label,
          'uri': uri.toString(),
          'can_launch': canLaunch,
        },
      );
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      AppLogger.log(
        LogEvents.mapsLaunchReturn,
        module: 'MapsLauncher',
        sessionId: sid,
        metadata: {
          'target': label,
          'uri': uri.toString(),
          'launched': launched,
        },
      );
      return launched;
    } catch (e, st) {
      AppLogger.error(
        LogEvents.mapsLaunchError,
        module: 'MapsLauncher',
        sessionId: sid,
        metadata: {'target': label, 'uri': uri.toString()},
        exception: e,
        stackTrace: st,
      );
      return false;
    }
  }
}

class MapsNavigationRequest {
  final String primary;
  final String fallback;

  const MapsNavigationRequest({required this.primary, required this.fallback});
}

// Shows dialog asking if user wants to append a return destination.
// Returns addresses unchanged if user selects "Não adicionar" or dismisses.
// Only shows dialog when at least one return address is configured.
Future<List<String>> pickFinalDestination(
  BuildContext context, {
  required List<String> addresses,
  required String pizzeriaAddress,
  required String homeAddress,
}) async {
  final hasPizzeria = pizzeriaAddress.isNotEmpty;
  final hasHome = homeAddress.isNotEmpty;

  if (!hasPizzeria && !hasHome) return addresses;

  AppLogger.log(
    LogEvents.mapsFinalDestinationDialogOpened,
    module: 'MapsLauncher',
    metadata: {
      'has_pizzeria': hasPizzeria,
      'has_home': hasHome,
      'delivery_count': addresses.length,
    },
  );

  final choice = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Destino final da rota'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, 'none'),
          child: const Text('Não adicionar'),
        ),
        // When both exist: pizzeria as secondary, home as primary.
        // When only one: it becomes the primary (FilledButton).
        if (hasPizzeria && hasHome)
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'work'),
            child: const Text('Voltar para pizzaria'),
          ),
        if (hasPizzeria && !hasHome)
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'work'),
            child: const Text('Voltar para pizzaria'),
          ),
        if (hasHome)
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'home'),
            child: const Text('Ir para casa'),
          ),
      ],
    ),
  );

  String? finalAddress;
  if (choice == 'work') finalAddress = pizzeriaAddress;
  if (choice == 'home') finalAddress = homeAddress;

  AppLogger.log(
    LogEvents.mapsFinalDestinationSelected,
    module: 'MapsLauncher',
    metadata: {
      'type': choice ?? 'none',
      'billable_deliveries': addresses.length,
    },
  );

  if (finalAddress != null) {
    AppLogger.log(
      LogEvents.mapsFinalDestinationAppended,
      module: 'MapsLauncher',
      metadata: {
        'type': choice,
        'address': finalAddress,
        'maps_stop_count': addresses.length + 1,
        'billable_deliveries': addresses.length,
      },
    );
    return [...addresses, finalAddress];
  }
  return addresses;
}
