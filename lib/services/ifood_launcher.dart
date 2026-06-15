import 'package:url_launcher/url_launcher.dart';

class IfoodLauncher {
  static final Uri confirmationUri = Uri.parse(
    'https://confirmacao-entrega-propria.ifood.com.br/',
  );

  static Future<bool> open() async {
    try {
      return await launchUrl(
        confirmationUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}
