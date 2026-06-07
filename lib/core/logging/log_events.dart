/// All structured log event constants used across the application.
/// Grouped by domain for discoverability.
abstract final class LogEvents {
  // ── App lifecycle ──────────────────────────────────────────────────────────
  static const appStart = 'APP_START';
  static const appReady = 'APP_READY';
  static const appBackground = 'APP_BACKGROUND';
  static const appForeground = 'APP_FOREGROUND';
  static const appClose = 'APP_CLOSE';
  static const appFlutterError = 'APP_UNCAUGHT_FLUTTER_ERROR';
  static const appPlatformError = 'APP_UNCAUGHT_PLATFORM_ERROR';
  static const appBuildMetadata = 'APP_BUILD_METADATA';

  // ── OCR ───────────────────────────────────────────────────────────────────
  static const ocrStart = 'OCR_START';
  static const ocrSourceCamera = 'OCR_SOURCE_CAMERA';
  static const ocrSourceGallery = 'OCR_SOURCE_GALLERY';
  static const ocrFileReceived = 'OCR_FILE_RECEIVED';
  static const ocrInputImageStart = 'OCR_INPUTIMAGE_START';
  static const ocrInputImageSuccess = 'OCR_INPUTIMAGE_SUCCESS';
  static const ocrInputImageFail = 'OCR_INPUTIMAGE_FAIL';
  static const ocrRecognizerStart = 'OCR_RECOGNIZER_START';
  static const ocrRecognizerSuccess = 'OCR_RECOGNIZER_SUCCESS';
  static const ocrRecognizerFail = 'OCR_RECOGNIZER_FAIL';
  static const ocrProcessSuccess = 'OCR_PROCESS_SUCCESS';
  static const ocrProcessFail = 'OCR_PROCESS_FAIL';
  static const ocrLowConfidence = 'OCR_LOW_CONFIDENCE';
  static const ocrConfidenceHigh = 'OCR_CONFIDENCE_HIGH';
  static const ocrConfidenceMedium = 'OCR_CONFIDENCE_MEDIUM';
  static const ocrConfidenceLow = 'OCR_CONFIDENCE_LOW';
  static const ocrTextPreview = 'OCR_TEXT_PREVIEW';
  static const ocrFieldLocatorFound = 'OCR_FIELD_LOCATOR_FOUND';
  static const ocrFieldCollectionFound = 'OCR_FIELD_COLLECTION_FOUND';
  static const ocrFieldCollectionFallback = 'OCR_FIELD_COLLECTION_FALLBACK';
  static const ocrFieldCustomerFound = 'OCR_FIELD_CUSTOMER_FOUND';
  static const ocrFieldAddressFound = 'OCR_FIELD_ADDRESS_FOUND';
  static const ocrRegexStart = 'OCR_REGEX_START';
  static const ocrRegexSuccess = 'OCR_REGEX_SUCCESS';
  static const ocrRegexFail = 'OCR_REGEX_FAIL';

  // ── Recovery flow ─────────────────────────────────────────────────────────
  static const recoveryPopupOpened = 'RECOVERY_POPUP_OPENED';
  static const userSelectedRetry = 'USER_SELECTED_RETRY';
  static const userSelectedManualEntry = 'USER_SELECTED_MANUAL_ENTRY';
  static const galleryOcrSuccess = 'GALLERY_OCR_SUCCESS';
  static const galleryOcrFail = 'GALLERY_OCR_FAIL';

  // ── Delivery ──────────────────────────────────────────────────────────────
  static const deliveryCreateSuccess = 'DELIVERY_CREATE_SUCCESS';
  static const deliveryCreateFail = 'DELIVERY_CREATE_FAIL';
  static const deliveryCompleted = 'DELIVERY_COMPLETED';
  static const deliveryDeleteRequest = 'DELIVERY_DELETE_REQUEST';
  static const deliveryDeleteSuccess = 'DELIVERY_DELETE_SUCCESS';
  static const routeDeleteRequest = 'ROUTE_DELETE_REQUEST';
  static const routeDeleteSuccess = 'ROUTE_DELETE_SUCCESS';

  // ── Payment cycle ─────────────────────────────────────────────────────────
  static const paymentPeriodCreated = 'PAYMENT_PERIOD_CREATED';
  static const paymentPeriodUpdated = 'PAYMENT_PERIOD_UPDATED';
  static const paymentForecastUpdated = 'PAYMENT_FORECAST_UPDATED';
  static const paymentHistoryGenerated = 'PAYMENT_HISTORY_GENERATED';

  // ── Shift ─────────────────────────────────────────────────────────────────
  static const shiftEndManualCheck = 'SHIFT_END_MANUAL_CHECK';
  static const shiftEndManualAdded = 'SHIFT_END_MANUAL_ADDED';
  static const shiftEndCompleted = 'SHIFT_END_COMPLETED';

  // ── History ───────────────────────────────────────────────────────────────
  static const historyLoadStart = 'HISTORY_LOAD_START';
  static const historyLoadSuccess = 'HISTORY_LOAD_SUCCESS';
  static const historyLoadEmpty = 'HISTORY_LOAD_EMPTY';
  static const historyLoadFail = 'HISTORY_LOAD_FAIL';
  static const historyRowsFound = 'HISTORY_ROWS_FOUND';
  static const historyEntryCreated = 'HISTORY_ENTRY_CREATED';
  static const historyEntryUpdated = 'HISTORY_ENTRY_UPDATED';
  static const historyEntryDeleted = 'HISTORY_ENTRY_DELETED';
  static const historyDeleteRequest = 'HISTORY_DELETE_REQUEST';
  static const historyDeleteSuccess = 'HISTORY_DELETE_SUCCESS';
  static const historyDeleteItem = 'HISTORY_DELETE';
  static const historyDeleteItemConfirmed = 'HISTORY_DELETE_CONFIRMED';
  static const historyRestoreItem = 'HISTORY_RESTORE';
  static const cleanupStart = 'CLEANUP_START';
  static const cleanupComplete = 'CLEANUP_COMPLETE';

  // ── Fuel tracking ─────────────────────────────────────────────────────────
  static const fuelExpenseRecorded = 'FUEL_EXPENSE_RECORDED';
  static const dailyGoal = 'DAILY_GOAL';
  static const dailyGoalProgress = 'DAILY_GOAL_PROGRESS';
  static const dailyGoalReached = 'DAILY_GOAL_REACHED';
  static const periodReport = 'REPORT';

  // ── Google Maps ───────────────────────────────────────────────────────────
  static const mapsFinalDestinationDialogOpened = 'MAPS_FINAL_DESTINATION_DIALOG_OPENED';
  static const mapsFinalDestinationSelected = 'MAPS_FINAL_DESTINATION_SELECTED';
  static const mapsFinalDestinationAppended = 'MAPS_FINAL_DESTINATION_APPENDED';
  static const mapsOpenStart = 'MAPS_OPEN_START';
  static const mapsOpenSuccess = 'MAPS_OPEN_SUCCESS';
  static const mapsOpenFail = 'MAPS_OPEN_FAIL';
  static const mapsUriGenerated = 'MAPS_URI_GENERATED';
  static const mapsAddressEmpty = 'MAPS_VALIDATION_ADDRESS_EMPTY';
  static const mapsLaunchCallback = 'MAPS_LAUNCH_CALLBACK';
  static const mapsLaunchReturn = 'MAPS_LAUNCH_RETURN';
  static const mapsLaunchError = 'MAPS_LAUNCH_ERROR';
  static const mapsRouteCreated = 'MAPS_ROUTE_CREATED';
  static const mapsRouteOpened = 'MAPS_ROUTE_OPENED';

  // ── iFood ─────────────────────────────────────────────────────────────────
  static const ifoodOpenStart = 'IFOOD_OPEN_START';
  static const ifoodOpenSuccess = 'IFOOD_OPEN_SUCCESS';
  static const ifoodOpenFail = 'IFOOD_OPEN_FAIL';
  static const ifoodLocatorClipboardCopy = 'IFOOD_LOCATOR_CLIPBOARD_COPY';
  static const ifoodPageLoading = 'IFOOD_PAGE_LOADING';
  static const ifoodPageLoaded = 'IFOOD_PAGE_LOADED';
  static const ifoodPageFail = 'IFOOD_PAGE_FAIL';
  static const ifoodWebviewUrlChanged = 'IFOOD_WEBVIEW_URL_CHANGED';
  static const ifoodWebviewHttpError = 'IFOOD_WEBVIEW_HTTP_ERROR';
  static const ifoodSelectorSearch = 'IFOOD_SELECTOR_SEARCH';
  static const ifoodSelectorFound = 'IFOOD_SELECTOR_FOUND';
  static const ifoodSelectorNotFound = 'IFOOD_SELECTOR_NOT_FOUND';
  static const ifoodJsInjectionStart = 'IFOOD_JS_INJECTION_START';
  static const ifoodJsInjectionSuccess = 'IFOOD_JS_INJECTION_SUCCESS';
  static const ifoodJsInjectionFail = 'IFOOD_JS_INJECTION_FAIL';
  static const ifoodJsExecuteStart = 'IFOOD_JS_EXECUTE_START';
  static const ifoodJsExecuteSuccess = 'IFOOD_JS_EXECUTE_SUCCESS';
  static const ifoodJsExecuteFail = 'IFOOD_JS_EXECUTE_FAIL';
  static const ifoodConfirmSuccess = 'IFOOD_CONFIRM_SUCCESS';
  static const ifoodConfirmFail = 'IFOOD_CONFIRM_FAIL';
  static const ifoodManualFallback = 'IFOOD_MANUAL_FALLBACK';

  // ── Financial calculation ─────────────────────────────────────────────────
  static const financialCalcStart = 'FINANCIAL_CALC_START';
  static const financialDeliveryValue = 'FINANCIAL_DELIVERY_VALUE';
  static const financialRouteTotal = 'FINANCIAL_ROUTE_TOTAL';
  static const financialCalcComplete = 'FINANCIAL_CALC_COMPLETE';

  // ── Customer name extraction ──────────────────────────────────────────────
  static const customerCandidateFound = 'CUSTOMER_CANDIDATE_FOUND';
  static const customerValidated = 'CUSTOMER_VALIDATED';
  static const customerNotFound = 'CUSTOMER_NOT_FOUND';
  static const customerRejectedBlocklist = 'CUSTOMER_REJECTED_BLOCKLIST';

  // ── Parser ───────────────────────────────────────────────────────────────
  static const parserSuccessComplete = 'PARSER_SUCCESS_COMPLETE';
  static const parserSuccessPartial = 'PARSER_SUCCESS_PARTIAL';
  static const parserFail = 'PARSER_FAIL';
  static const parserLocatorInvalid = 'PARSER_LOCATOR_INVALID';
  static const parserAddressNotFound = 'PARSER_ADDRESS_NOT_FOUND';
  static const parserAddressMatch = 'PARSER_ADDRESS_MATCH';
  static const parserAddressFailReason = 'PARSER_ADDRESS_FAIL_REASON';
  static const parserOrderNotFound = 'PARSER_ORDER_NOT_FOUND';
  static const ocrRawTextCaptured = 'OCR_RAW_TEXT_CAPTURED';
  static const parserLabelFound = 'LABEL_FOUND';
  static const parserLabelValueExtracted = 'LABEL_VALUE_EXTRACTED';
  static const parserFieldConflictDetected = 'FIELD_CONFLICT_DETECTED';
  static const parserLocatorValidated = 'LOCATOR_VALIDATED';
  static const parserManualReviewRequired = 'MANUAL_REVIEW_REQUIRED';

  // ── Operational highlights ────────────────────────────────────────────────
  static const localizerCopied = 'LOCALIZER_COPIED';
  static const paymentDetected = 'PAYMENT_DETECTED';
  static const drinkDetected = 'DRINK_DETECTED';

  // ── Locator pipeline diagnostics ─────────────────────────────────────────
  static const locatorCaptured = 'LOCATOR_CAPTURED';
  static const locatorStored = 'LOCATOR_STORED';
  static const locatorClipboardCopy = 'LOCATOR_CLIPBOARD_COPY';
  static const locatorJsInjection = 'LOCATOR_JS_INJECTION';
  static const locatorRequestSent = 'LOCATOR_REQUEST_SENT';

  // ── Database ──────────────────────────────────────────────────────────────
  static const dbOpen = 'DB_OPEN';
  static const dbMigrationStart = 'DB_MIGRATION_START';
  static const dbMigrationSuccess = 'DB_MIGRATION_SUCCESS';
  static const dbMigrationFail = 'DB_MIGRATION_FAIL';
  static const dbDeliveryInsertSuccess = 'DB_DELIVERY_INSERT_SUCCESS';
  static const dbDeliveryInsertFail = 'DB_DELIVERY_INSERT_FAIL';

  // ── Permissions ───────────────────────────────────────────────────────────
  static const permissionCameraGranted = 'PERMISSION_CAMERA_GRANTED';
  static const permissionCameraDenied = 'PERMISSION_CAMERA_DENIED';
  static const permissionStorageGranted = 'PERMISSION_STORAGE_GRANTED';
  static const permissionStorageDenied = 'PERMISSION_STORAGE_DENIED';

  // ── Network ───────────────────────────────────────────────────────────────
  static const networkOnline = 'NETWORK_ONLINE';
  static const networkOffline = 'NETWORK_OFFLINE';
  static const networkStateChange = 'NETWORK_STATE_CHANGE';
  static const networkTypeChanged = 'NETWORK_TYPE_CHANGED';
  static const networkRequestStart = 'NETWORK_REQUEST_START';
  static const networkRequestSuccess = 'NETWORK_REQUEST_SUCCESS';
  static const networkRequestFail = 'NETWORK_REQUEST_FAIL';

  // ── ML Kit ────────────────────────────────────────────────────────────────
  static const mlkitInitStart = 'MLKIT_INIT_START';
  static const mlkitInitSuccess = 'MLKIT_INIT_SUCCESS';
  static const mlkitInitFail = 'MLKIT_INIT_FAIL';
  static const mlkitModelStatus = 'MLKIT_MODEL_STATUS';
  static const mlkitModelAvailable = 'MLKIT_MODEL_AVAILABLE';
  static const mlkitModelMissing = 'MLKIT_MODEL_MISSING';

  // ── OCR Deep Image Diagnostics ────────────────────────────────────────────
  static const ocrImageRotation = 'OCR_IMAGE_ROTATION';
  static const ocrImageFormat = 'OCR_IMAGE_FORMAT';
  static const ocrImageDimensions = 'OCR_IMAGE_DIMENSIONS';
  static const ocrImagePreprocessStart = 'OCR_IMAGE_PREPROCESS_START';
  static const ocrImagePreprocessSuccess = 'OCR_IMAGE_PREPROCESS_SUCCESS';
  static const ocrImagePreprocessFail = 'OCR_IMAGE_PREPROCESS_FAIL';

  // ── Automation runner ────────────────────────────────────────────────────
  static const automationDeepLinkReceived = 'AUTOMATION_DEEP_LINK_RECEIVED';
  static const automationScreenOpened = 'AUTOMATION_SCREEN_OPENED';
  static const automationRunStart = 'AUTOMATION_RUN_START';
  static const automationRunComplete = 'AUTOMATION_RUN_COMPLETE';
  static const automationRunFail = 'AUTOMATION_RUN_FAIL';
  static const automationTestStart = 'AUTOMATION_TEST_START';
  static const automationTestPass = 'AUTOMATION_TEST_PASS';
  static const automationTestFail = 'AUTOMATION_TEST_FAIL';
  static const automationFixtureDirCheck = 'AUTOMATION_FIXTURE_DIR_CHECK';
  static const automationFixtureFound = 'AUTOMATION_FIXTURE_FOUND';
  static const automationFixtureMissing = 'AUTOMATION_FIXTURE_MISSING';
  static const automationOcrFixtureStart = 'AUTOMATION_OCR_FIXTURE_START';
  static const automationOcrFixturePass = 'AUTOMATION_OCR_FIXTURE_PASS';
  static const automationOcrFixtureFail = 'AUTOMATION_OCR_FIXTURE_FAIL';
  static const automationReportGenerated = 'AUTOMATION_REPORT_GENERATED';

  // ── Field validation ─────────────────────────────────────────────────────
  static const fieldValidationStart = 'FIELD_VALIDATION_START';
  static const fieldValidationStepPass = 'FIELD_VALIDATION_STEP_PASS';
  static const fieldValidationStepFail = 'FIELD_VALIDATION_STEP_FAIL';
  static const fieldValidationStepSkip = 'FIELD_VALIDATION_STEP_SKIP';
  static const fieldValidationReportGenerated =
      'FIELD_VALIDATION_REPORT_GENERATED';
  static const fieldValidationComplete = 'FIELD_VALIDATION_COMPLETE';

  // ── Developer / diagnostics ───────────────────────────────────────────────
  static const dbIntegrityCheck = 'DB_INTEGRITY_CHECK';
  static const devToolsOpened = 'DEV_TOOLS_OPENED';
  static const ocrSandboxStarted = 'OCR_SANDBOX_STARTED';
  static const testDataGenerated = 'TEST_DATA_GENERATED';

  // ── Exceptions ────────────────────────────────────────────────────────────
  static const exception = 'EXCEPTION';
  static const criticalException = 'CRITICAL_EXCEPTION';

  // ── Phase 6.2 ────────────────────────────────────────────────────────────
  static const pizzaNumberAdded = 'PIZZA_NUMBER_ADDED';
  static const pizzaNumberUpdated = 'PIZZA_NUMBER_UPDATED';
  static const deliveryUpdated = 'DELIVERY_UPDATED';
  static const routeReordered = 'ROUTE_REORDERED';
  static const returnDestinationSelected = 'RETURN_DESTINATION_SELECTED';
  static const dashboardRecalculated = 'DASHBOARD_RECALCULATED';
  static const shiftReviewOpened = 'SHIFT_REVIEW_OPENED';
  static const shiftReviewCompleted = 'SHIFT_REVIEW_COMPLETED';
  static const paymentTextIgnoredFromOcr = 'PAYMENT_TEXT_IGNORED_FROM_OCR';

  // ── OCR history edit ──────────────────────────────────────────────────────
  static const ocrHistoryEditOpened = 'OCR_HISTORY_EDIT_OPENED';
  static const ocrDeliveryEdited = 'OCR_DELIVERY_EDITED';
  static const ocrDeliveryDeleteRequested = 'OCR_DELIVERY_DELETE_REQUESTED';
  static const ocrDeliveryDeleted = 'OCR_DELIVERY_DELETED';
  static const ocrRouteDeleteRequested = 'OCR_ROUTE_DELETE_REQUESTED';
  static const ocrRouteDeleted = 'OCR_ROUTE_DELETED';
  static const historyTotalsRecalculated = 'HISTORY_TOTALS_RECALCULATED';
  static const weeklyTotalsRecalculated = 'WEEKLY_TOTALS_RECALCULATED';
  static const monthlyTotalsRecalculated = 'MONTHLY_TOTALS_RECALCULATED';
}
