#!/usr/bin/env sh
set -eu

PACKAGE="com.example.controle_entregas"
ADB="${ADB:-adb}"
APK_PATH="${APK_PATH:-build/app/outputs/flutter-apk/app-release.apk}"
REPORT_DEVICE="/sdcard/Android/data/$PACKAGE/files/automation_reports/latest_smoke_report.md"
OUT_DIR="reports/device_smoke"
DEEP_LINK="deliveryflow://automation/smoke"
WAIT_SECONDS="${WAIT_SECONDS:-180}"

log() {
  printf '%s\n' "$*"
}

fail() {
  log "FAIL: $*"
  exit 1
}

if ! command -v "$ADB" >/dev/null 2>&1; then
  SDK_DIR="$(awk -F= '/^sdk.dir=/ { print $2; exit }' android/local.properties 2>/dev/null || true)"
  if [ -n "$SDK_DIR" ] && [ -x "$SDK_DIR/platform-tools/adb" ]; then
    ADB="$SDK_DIR/platform-tools/adb"
  fi
fi
command -v "$ADB" >/dev/null 2>&1 || fail "adb not found in PATH or android/local.properties"

DEVICE_COUNT="$($ADB devices | awk 'NR > 1 && $2 == "device" { count++ } END { print count + 0 }')"
[ "$DEVICE_COUNT" -ge 1 ] || fail "no connected adb device"

if [ ! -f "$APK_PATH" ]; then
  if command -v flutter >/dev/null 2>&1; then
    log "APK not found. Building release APK..."
    flutter build apk --release
  else
    fail "APK not found at $APK_PATH and flutter is not available"
  fi
fi

mkdir -p "$OUT_DIR"

log "Installing $APK_PATH"
$ADB install -r "$APK_PATH" >/dev/null

log "Preparing automation report path"
$ADB shell rm -f "$REPORT_DEVICE" >/dev/null 2>&1 || true

log "Launching automation: $DEEP_LINK"
$ADB shell am force-stop "$PACKAGE"
$ADB shell am start -a android.intent.action.VIEW -d "$DEEP_LINK" >/dev/null

log "Waiting for report: $REPORT_DEVICE"
i=0
while [ "$i" -lt "$WAIT_SECONDS" ]; do
  if $ADB shell "[ -f '$REPORT_DEVICE' ]" >/dev/null 2>&1; then
    break
  fi
  i=$((i + 5))
  sleep 5
done

$ADB shell "[ -f '$REPORT_DEVICE' ]" >/dev/null 2>&1 || \
  fail "automation report not found after ${WAIT_SECONDS}s"

REPORT_LOCAL="$OUT_DIR/latest_smoke_report.md"
$ADB pull "$REPORT_DEVICE" "$REPORT_LOCAL" >/dev/null
log "Pulled report: $REPORT_LOCAL"

LOG_LOCAL="$OUT_DIR/deliveryflow.log"
if $ADB shell run-as "$PACKAGE" sh -c "'cat app_flutter/deliveryflow.log'" \
  > "$LOG_LOCAL" 2>/dev/null; then
  log "Pulled app log via run-as: $LOG_LOCAL"
else
  rm -f "$LOG_LOCAL"
  log "App log pull skipped; run-as is unavailable for this build."
fi

FAIL_COUNT="$(awk -F': ' '/^FAIL:/ { print $2; exit }' "$REPORT_LOCAL")"
FAIL_COUNT="${FAIL_COUNT:-0}"

log "Automation summary:"
grep -A 8 '## Summary' "$REPORT_LOCAL" || true
if [ "$FAIL_COUNT" -gt 0 ]; then
  log "FAIL: automation reported $FAIL_COUNT failing test(s)"
  exit 1
fi
log "PASS"
