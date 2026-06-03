import 'package:controle_entregas/core/monitoring/network_monitor.dart';
import 'package:controle_entregas/presentation/router/app_router.dart';
import 'package:controle_entregas/services/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeliveryFlowApp extends ConsumerStatefulWidget {
  const DeliveryFlowApp({super.key});

  @override
  ConsumerState<DeliveryFlowApp> createState() => _DeliveryFlowAppState();
}

class _DeliveryFlowAppState extends ConsumerState<DeliveryFlowApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NetworkMonitor.start();
    AppLogger.info(LogEvents.appReady, module: 'DeliveryFlowApp');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        AppLogger.info(LogEvents.appBackground, module: 'DeliveryFlowApp');
      case AppLifecycleState.resumed:
        AppLogger.info(LogEvents.appForeground, module: 'DeliveryFlowApp');
      case AppLifecycleState.detached:
        NetworkMonitor.stop();
        AppLogger.info(LogEvents.appClose, module: 'DeliveryFlowApp');
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'DeliveryFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
