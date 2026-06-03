#!/usr/bin/env sh
set -eu

PACKAGE="${PACKAGE:-com.example.controle_entregas}"
ADB="${ADB:-adb}"
APK_PATH="${APK_PATH:-build/app/outputs/flutter-apk/app-release.apk}"
FIXTURE_SRC="${FIXTURE_SRC:-/home/lucas/Imagens/imagem para testes no app}"
DEVICE_FILES_ROOT="/sdcard/Android/data/$PACKAGE/files"
DEVICE_FIXTURE_DIR="$DEVICE_FILES_ROOT/test_fixtures/pedidos"
REPORT_DEVICE="$DEVICE_FILES_ROOT/automation_reports/latest_smoke_report.md"
WORKFLOW_REPORT_DEVICE="$DEVICE_FILES_ROOT/automation_reports/workflow_report.md"
OUT_ROOT="reports/device_smoke"
RUN_STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_DIR="$OUT_ROOT/$RUN_STAMP"
SCREENSHOT_DIR="$OUT_DIR/screenshots"
LATEST_REPORT="$OUT_ROOT/latest_smoke_report.md"
DEEP_LINK="deliveryflow://automation/smoke"
WAIT_SECONDS="${WAIT_SECONDS:-180}"

log() {
  printf '%s\n' "$*"
}

fail() {
  log "FAIL [$STAGE]: $*"
  exit 1
}

stage() {
  STAGE="$1"
  log "[$2/9] $1"
}

resolve_adb() {
  if ! command -v "$ADB" >/dev/null 2>&1; then
    sdk_dir="$(awk -F= '/^sdk.dir=/ { print $2; exit }' android/local.properties 2>/dev/null || true)"
    if [ -n "$sdk_dir" ] && [ -x "$sdk_dir/platform-tools/adb" ]; then
      ADB="$sdk_dir/platform-tools/adb"
    fi
  fi
  command -v "$ADB" >/dev/null 2>&1 || \
    fail "adb not found in PATH or android/local.properties. Set ADB=/path/to/adb and retry."
}

resolve_flutter() {
  if command -v flutter >/dev/null 2>&1; then
    printf '%s\n' "flutter"
    return
  fi
  flutter_dir="$(awk -F= '/^flutter.sdk=/ { print $2; exit }' android/local.properties 2>/dev/null || true)"
  if [ -n "$flutter_dir" ] && [ -x "$flutter_dir/bin/flutter" ]; then
    printf '%s\n' "$flutter_dir/bin/flutter"
    return
  fi
  printf '%s\n' ""
}

local_fixture_count() {
  find "$FIXTURE_SRC" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | wc -l | tr -d ' '
}

device_fixture_count() {
  $ADB shell "find '$DEVICE_FIXTURE_DIR' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \\) 2>/dev/null | wc -l" | tr -d ' \r'
}

write_local_fixture_audit() {
  {
    log "# Local Fixtures"
    log "Source: $FIXTURE_SRC"
    log ""
    find "$FIXTURE_SRC" -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) \
      -printf '%f\t%s\t%TY-%Tm-%Td %TH:%TM:%TS\n' | sort
  } > "$OUT_DIR/fixtures_local.txt"
}

write_device_fixture_audit() {
  {
    log "# Device Fixtures"
    log "Source: $DEVICE_FIXTURE_DIR"
    log ""
    $ADB shell "find '$DEVICE_FIXTURE_DIR' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \\) -exec ls -l {} \\; 2>/dev/null" | tr -d '\r'
  } > "$OUT_DIR/fixtures_device.txt"
}

capture_screenshot() {
  name="$1"
  if $ADB exec-out screencap -p > "$SCREENSHOT_DIR/$name.png" 2>/dev/null; then
    log "Captured screenshot: screenshots/$name.png"
  else
    rm -f "$SCREENSHOT_DIR/$name.png"
    log "WARN: could not capture screenshot $name.png"
  fi
}

write_device_report() {
  device_id="$1"
  manufacturer="$($ADB shell getprop ro.product.manufacturer | tr -d '\r')"
  model="$($ADB shell getprop ro.product.model | tr -d '\r')"
  android_version="$($ADB shell getprop ro.build.version.release | tr -d '\r')"
  sdk="$($ADB shell getprop ro.build.version.sdk | tr -d '\r')"
  fingerprint="$($ADB shell getprop ro.build.fingerprint | tr -d '\r')"
  apk_size="$(stat -c %s "$APK_PATH")"
  apk_mtime="$(stat -c '%y' "$APK_PATH")"
  version_name="$($ADB shell dumpsys package "$PACKAGE" 2>/dev/null | awk -F= '/versionName=/ { print $2; exit }' | tr -d '\r')"
  version_code="$($ADB shell dumpsys package "$PACKAGE" 2>/dev/null | awk '/versionCode=/ { for (i = 1; i <= NF; i++) if ($i ~ /^versionCode=/) { sub(/^versionCode=/, "", $i); print $i; exit } }' | tr -d '\r')"

  {
    log "# Device Smoke Metadata"
    log ""
    log "Execution Timestamp: $RUN_STAMP"
    log "Device ID: $device_id"
    log "Manufacturer: $manufacturer"
    log "Model: $model"
    log "Android Version: $android_version"
    log "SDK: $sdk"
    log "Fingerprint: $fingerprint"
    log ""
    log "## APK"
    log "APK Path: $APK_PATH"
    log "APK Size: $apk_size bytes"
    log "APK Modified: $apk_mtime"
    log "versionName: ${version_name:-unknown}"
    log "versionCode: ${version_code:-unknown}"
    log ""
    log "## adb devices"
    $ADB devices | tr -d '\r'
  } > "$OUT_DIR/device_report.md"
}

collect_logcat() {
  raw_logcat="$OUT_DIR/logcat_raw.txt"
  $ADB logcat -d > "$raw_logcat" 2>/dev/null || true
  grep -E 'AUTOMATION|APP_UNCAUGHT|Flutter|Exception|Error|OCR|IFood|History|DeliveryFlow' \
    "$raw_logcat" > "$OUT_DIR/logcat_filtered.txt" || true
  rm -f "$raw_logcat"
}

collect_device_inventory() {
  $ADB shell "find '$DEVICE_FILES_ROOT' -maxdepth 5 -type f 2>/dev/null" | \
    tr -d '\r' | sort > "$OUT_DIR/device_files.txt" || true
}

collect_failure_evidence() {
  collect_logcat
  capture_screenshot final
  collect_device_inventory
  write_device_fixture_audit
}

critical_error_count() {
  {
    grep -E 'APP_UNCAUGHT_FLUTTER_ERROR|APP_UNCAUGHT_PLATFORM_ERROR|CRITICAL|FATAL|Unhandled' \
      "$OUT_DIR/smoke_report.md" "$OUT_DIR/logcat_filtered.txt" 2>/dev/null || true
    grep -E 'Flutter|DeliveryFlow|AUTOMATION|OCR|IFood|History' \
      "$OUT_DIR/logcat_filtered.txt" 2>/dev/null | grep -E 'Exception|Error' || true
  } | wc -l | tr -d ' '
}

stage "Checking device" 1
mkdir -p "$OUT_DIR" "$SCREENSHOT_DIR"
resolve_adb
DEVICE_ID="$($ADB devices | awk 'NR > 1 && $2 == "device" { print $1; exit }')"
[ -n "$DEVICE_ID" ] || fail "no connected adb device. Connect a device with USB debugging enabled."
log "Device: $DEVICE_ID"

stage "Installing APK" 2
if [ ! -f "$APK_PATH" ]; then
  FLUTTER_BIN="$(resolve_flutter)"
  [ -n "$FLUTTER_BIN" ] || fail "APK not found at $APK_PATH and Flutter is unavailable. Build the APK or set APK_PATH."
  log "APK not found. Building release APK..."
  "$FLUTTER_BIN" build apk --release || fail "Flutter release build failed."
fi
$ADB install -r "$APK_PATH" >/dev/null || \
  fail "APK install failed. If signatures differ, uninstall $PACKAGE or install an APK signed with the same key."

stage "Syncing fixtures" 3
[ -d "$FIXTURE_SRC" ] || fail "fixture source not found: $FIXTURE_SRC. Set FIXTURE_SRC=/custom/path and retry."
LOCAL_FIXTURES_FOUND="$(local_fixture_count)"
log "LOCAL_FIXTURES_FOUND: $LOCAL_FIXTURES_FOUND"
[ "$LOCAL_FIXTURES_FOUND" -gt 0 ] || fail "0 local fixtures found. Add .jpg/.jpeg/.png files to $FIXTURE_SRC."
$ADB shell "mkdir -p '$DEVICE_FIXTURE_DIR'" >/dev/null
$ADB shell "find '$DEVICE_FIXTURE_DIR' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \\) -delete" >/dev/null 2>&1 || true
find "$FIXTURE_SRC" -maxdepth 1 -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | sort | \
  while IFS= read -r fixture; do
    $ADB push "$fixture" "$DEVICE_FIXTURE_DIR/" >/dev/null 2>&1
  done
DEVICE_FIXTURES_FOUND="$(device_fixture_count)"
log "DEVICE_FIXTURES_FOUND: $DEVICE_FIXTURES_FOUND"
[ "$DEVICE_FIXTURES_FOUND" -gt 0 ] || fail "0 device fixtures found after push. Check device storage permissions/path."
write_local_fixture_audit
write_device_fixture_audit

stage "Collecting metadata" 4
write_device_report "$DEVICE_ID"
collect_device_inventory
capture_screenshot before
$ADB logcat -c >/dev/null 2>&1 || true

stage "Launching automation" 5
$ADB shell rm -f "$REPORT_DEVICE" >/dev/null 2>&1 || true
$ADB shell am force-stop "$PACKAGE"
$ADB shell am start -a android.intent.action.VIEW -d "$DEEP_LINK" >/dev/null || {
  collect_failure_evidence
  fail "deep link launch failed: $DEEP_LINK"
}

stage "Waiting for report" 6
i=0
while [ "$i" -lt "$WAIT_SECONDS" ]; do
  if $ADB shell "[ -f '$REPORT_DEVICE' ]" >/dev/null 2>&1; then
    break
  fi
  i=$((i + 5))
  sleep 5
done
if ! $ADB shell "[ -f '$REPORT_DEVICE' ]" >/dev/null 2>&1; then
  collect_failure_evidence
  fail "automation report not found after ${WAIT_SECONDS}s. See $OUT_DIR/logcat_filtered.txt and screenshots/final.png."
fi

stage "Pulling artifacts" 7
$ADB pull "$REPORT_DEVICE" "$OUT_DIR/smoke_report.md" >/dev/null || fail "could not pull smoke report from device."
if $ADB shell "[ -f '$WORKFLOW_REPORT_DEVICE' ]" >/dev/null 2>&1; then
  $ADB pull "$WORKFLOW_REPORT_DEVICE" "$OUT_DIR/workflow_report.md" >/dev/null || true
fi
cp "$OUT_DIR/smoke_report.md" "$LATEST_REPORT"
collect_logcat
capture_screenshot final
collect_device_inventory
write_device_fixture_audit
LOG_LOCAL="$OUT_DIR/deliveryflow.log"
if $ADB shell run-as "$PACKAGE" sh -c "'cat app_flutter/deliveryflow.log'" > "$LOG_LOCAL" 2>/dev/null; then
  log "Pulled app log: $LOG_LOCAL"
else
  rm -f "$LOG_LOCAL"
  log "WARN: app log pull skipped; run-as is unavailable for this build."
fi

stage "Analyzing results" 8
PASS_COUNT="$(awk -F': ' '/^PASS:/ { print $2; exit }' "$OUT_DIR/smoke_report.md")"
FAIL_COUNT="$(awk -F': ' '/^FAIL:/ { print $2; exit }' "$OUT_DIR/smoke_report.md")"
RUN_ID="$(awk -F': ' '/^Run ID:/ { print $2; exit }' "$OUT_DIR/smoke_report.md")"
DURATION="$(awk -F': ' '/^Duration:/ { print $2; exit }' "$OUT_DIR/smoke_report.md")"
PASS_COUNT="${PASS_COUNT:-0}"
FAIL_COUNT="${FAIL_COUNT:-0}"
RUN_ID="${RUN_ID:-unknown}"
DURATION="${DURATION:-unknown}"
if [ -f "$OUT_DIR/workflow_report.md" ]; then
  if grep -E '^.+FAIL$|FAIL \(' "$OUT_DIR/workflow_report.md" >/dev/null 2>&1; then
    WORKFLOW_VALIDATION="FAIL"
  else
    WORKFLOW_VALIDATION="PASS"
  fi
else
  WORKFLOW_VALIDATION="MISSING"
fi
CRITICAL_ERRORS="$(critical_error_count)"

stage "Complete" 9
log ""
log "Smoke Summary"
log "PASS: $PASS_COUNT"
log "FAIL: $FAIL_COUNT"
log "CRITICAL_ERRORS: $CRITICAL_ERRORS"
log "WORKFLOW_VALIDATION: $WORKFLOW_VALIDATION"
log "REPORT_DIR: $OUT_DIR"
log "RUN_ID: $RUN_ID"
log "Execution Time: $DURATION"
log ""
log "Artifacts Saved:"
find "$OUT_DIR" -maxdepth 2 -type f | sort | sed 's/^/  /'
log "  $LATEST_REPORT"

if [ "$FAIL_COUNT" -gt 0 ]; then
  fail "automation reported $FAIL_COUNT failing test(s). See $OUT_DIR/smoke_report.md."
fi
if [ "$CRITICAL_ERRORS" -gt 0 ]; then
  fail "detected $CRITICAL_ERRORS critical error line(s). See $OUT_DIR/logcat_filtered.txt."
fi
if [ "$WORKFLOW_VALIDATION" != "PASS" ]; then
  fail "workflow validation did not pass. See $OUT_DIR/workflow_report.md."
fi
log "PASS"
