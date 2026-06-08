import 'package:controle_entregas/core/providers/database_provider.dart';
import 'package:controle_entregas/domain/entities/shift.dart';
import 'package:controle_entregas/presentation/screens/active_route_screen.dart';
import 'package:controle_entregas/presentation/screens/shift_details_screen.dart';
import 'package:controle_entregas/presentation/screens/automation_runner_screen.dart';
import 'package:controle_entregas/presentation/screens/add_history_screen.dart';
import 'package:controle_entregas/presentation/screens/dev_tools_screen.dart';
import 'package:controle_entregas/presentation/screens/diagnostics_dashboard_screen.dart';
import 'package:controle_entregas/presentation/screens/manual_delivery_screen.dart';
import 'package:controle_entregas/presentation/screens/log_viewer_screen.dart';
import 'package:controle_entregas/presentation/screens/delivery_card_screen.dart';
import 'package:controle_entregas/presentation/screens/history_screen.dart';
import 'package:controle_entregas/presentation/screens/payment_forecast_screen.dart';
import 'package:controle_entregas/presentation/screens/home_screen.dart';
import 'package:controle_entregas/presentation/screens/ifood_confirmation_screen.dart';
import 'package:controle_entregas/presentation/screens/new_route_screen.dart';
import 'package:controle_entregas/presentation/screens/ocr_sandbox_screen.dart';
import 'package:controle_entregas/presentation/screens/route_review_screen.dart';
import 'package:controle_entregas/presentation/screens/settings_screen.dart';
import 'package:controle_entregas/presentation/screens/session_explorer_screen.dart';
import 'package:controle_entregas/presentation/screens/shift_report_screen.dart';
import 'package:controle_entregas/services/ocr_service.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const settings = '/settings';
  static const newRoute = '/shift/:shiftId/route/new';
  static const routeReview = '/shift/:shiftId/route/:routeId/review';
  static const activeRoute = '/shift/:shiftId/route/:routeId/active';
  static const deliveryCard =
      '/shift/:shiftId/route/:routeId/delivery/:deliveryId';
  static const iFoodConfirmation =
      '/shift/:shiftId/route/:routeId/delivery/:deliveryId/ifood';
  static const shiftHistory = '/history';
  static const shiftDetails = '/shift/:shiftId/details';
  static const shiftReport = '/history/shift/:shiftId/report';
  static const weekDetails = '/history/week-details';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);

  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) async {
      if (state.matchedLocation == AppRoutes.home) return null;
      if (state.matchedLocation == AppRoutes.settings) return null;
      if (state.matchedLocation == '/dev/automation-runner') return null;
      if (state.matchedLocation == '/smoke') return null;
      if (state.matchedLocation == '/automation/smoke') return null;
      final s = await settingsRepo.getSettings();
      if (!s.isSetupComplete) return AppRoutes.settings;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.newRoute,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return NewRouteScreen(
            shiftId: int.parse(state.pathParameters['shiftId']!),
            routeId: extra['routeId'] as int?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.routeReview,
        builder: (context, state) => RouteReviewScreen(
          shiftId: int.parse(state.pathParameters['shiftId']!),
          routeId: int.parse(state.pathParameters['routeId']!),
          ocrResults: state.extra as List<OcrResult>? ?? [],
        ),
      ),
      GoRoute(
        path: AppRoutes.activeRoute,
        builder: (context, state) => ActiveRouteScreen(
          shiftId: int.parse(state.pathParameters['shiftId']!),
          routeId: int.parse(state.pathParameters['routeId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.deliveryCard,
        builder: (context, state) => DeliveryCardScreen(
          shiftId: int.parse(state.pathParameters['shiftId']!),
          routeId: int.parse(state.pathParameters['routeId']!),
          deliveryId: int.parse(state.pathParameters['deliveryId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.iFoodConfirmation,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return IFoodConfirmationScreen(
            deliveryId: int.parse(state.pathParameters['deliveryId']!),
            deliveryIdentifier: extra['deliveryIdentifier'] as String?,
            partnerCollectionCode: extra['partnerCollectionCode'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.shiftHistory,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/history/add',
        builder: (context, state) =>
            AddHistoryScreen(entry: state.extra as Shift?),
      ),
      GoRoute(
        path: '/history/payment-forecast',
        builder: (context, state) => const PaymentForecastScreen(),
      ),
      GoRoute(
        path: AppRoutes.weekDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return WeekDetailsScreen(
            weekStart: extra['start'] as DateTime,
            weekEnd: extra['end'] as DateTime,
          );
        },
      ),
      GoRoute(
        path: '/shift/:shiftId/manual',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ManualDeliveryScreen(
            shiftId: int.parse(state.pathParameters['shiftId']!),
            routeId: extra['routeId'] as int?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.shiftDetails,
        builder: (context, state) => ShiftDetailsScreen(
          shiftId: int.parse(state.pathParameters['shiftId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.shiftReport,
        builder: (context, state) => ShiftReportScreen(
          shiftId: int.parse(state.pathParameters['shiftId']!),
        ),
      ),
      GoRoute(
        path: '/dev/tools',
        builder: (context, state) => const DevToolsScreen(),
      ),
      GoRoute(
        path: '/dev/ocr-sandbox',
        builder: (context, state) => const OcrSandboxScreen(),
      ),
      GoRoute(
        path: '/dev/logs',
        builder: (context, state) => const LogViewerScreen(),
      ),
      GoRoute(
        path: '/dev/sessions',
        builder: (context, state) => const SessionExplorerScreen(),
      ),
      GoRoute(
        path: '/dev/diagnostics',
        builder: (context, state) => const DiagnosticsDashboardScreen(),
      ),
      GoRoute(
        path: '/dev/automation-runner',
        builder: (context, state) => const AutomationRunnerScreen(),
      ),
      GoRoute(
        path: '/smoke',
        builder: (context, state) => AutomationRunnerScreen(
          runToken: state.uri.queryParameters['run'] ?? '',
          launchedFromDeepLink: true,
        ),
      ),
      GoRoute(
        path: '/automation/smoke',
        builder: (context, state) => AutomationRunnerScreen(
          runToken: state.uri.queryParameters['run'] ?? '',
          launchedFromDeepLink: true,
        ),
      ),
    ],
  );
}
