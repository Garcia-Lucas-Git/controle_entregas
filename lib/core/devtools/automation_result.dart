class AutomationRunResult {
  final String runId;
  final DateTime startedAt;
  final DateTime finishedAt;
  final List<AutomationTestResult> tests;
  final List<AutomationOcrFixtureResult> ocrFixtures;
  final List<String> criticalErrors;
  final String reportPath;

  const AutomationRunResult({
    required this.runId,
    required this.startedAt,
    required this.finishedAt,
    required this.tests,
    required this.ocrFixtures,
    required this.criticalErrors,
    required this.reportPath,
  });

  Duration get duration => finishedAt.difference(startedAt);
  int get passCount =>
      tests.where((t) => t.status == AutomationStatus.pass).length;
  int get partialCount =>
      tests.where((t) => t.status == AutomationStatus.partial).length;
  int get failCount =>
      tests.where((t) => t.status == AutomationStatus.fail).length;
  int get skippedCount =>
      tests.where((t) => t.status == AutomationStatus.skipped).length;

  bool get passed => failCount == 0;
}

class AutomationTestResult {
  final String name;
  final AutomationStatus status;
  final int durationMs;
  final String? message;
  final Map<String, dynamic> metadata;

  const AutomationTestResult({
    required this.name,
    required this.status,
    required this.durationMs,
    this.message,
    this.metadata = const {},
  });
}

class AutomationOcrFixtureResult {
  final String fileName;
  final AutomationStatus status;
  final int rawTextLength;
  final String? locator;
  final bool addressFound;
  final int durationMs;
  final List<String> missingFields;
  final String? message;

  const AutomationOcrFixtureResult({
    required this.fileName,
    required this.status,
    required this.rawTextLength,
    required this.locator,
    required this.addressFound,
    required this.durationMs,
    required this.missingFields,
    this.message,
  });
}

enum AutomationStatus {
  pass,
  partial,
  fail,
  skipped;

  String get label => name.toUpperCase();
}
