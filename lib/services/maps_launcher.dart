import 'package:controle_entregas/services/app_logger.dart';
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
      metadata: {'primary': request.primary},
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
    if (await canLaunchUrl(primaryUri)) {
      await launchUrl(primaryUri, mode: LaunchMode.externalApplication);
      return true;
    }
    final fallbackUri = Uri.parse(fallback);
    if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }
}

class MapsNavigationRequest {
  final String primary;
  final String fallback;

  const MapsNavigationRequest({required this.primary, required this.fallback});
}
