# DeliveryFlow Device Smoke Test

Run ID: AUTO-1780515511601
Started: 2026-06-03T19:38:31.601942Z
Finished: 2026-06-03T19:38:35.094703Z
Duration: 3492 ms

## Summary

PASS: 8
PARTIAL: 0
FAIL: 0
SKIPPED: 0

## Test Results

- app_health: PASS
- database_health: PASS
- fixture_discovery: PASS
- ocr_fixture_processing: PASS
- parser_fixture_health: PASS
- delivery_lifecycle: PASS
- history_health: PASS
- log_health: PASS

## Business Workflow Validation

Shift Creation .............. PASS (SHIFT)
OCR Route Creation .......... PASS (OCR)
Delivery Creation ........... PASS (DATABASE)
Maps Integration ............ PASS (MAPS)
Background Recovery ......... PASS (INFRASTRUCTURE)
iFood Workflow .............. PASS (IFOOD)
Manual Entry ................ PASS (AUTOMATION)
History Validation .......... PASS (HISTORY)
Shift Closure ............... PASS (SHIFT)
Cleanup ..................... PASS (AUTOMATION)

## Failure Classification

None

## OCR Fixture Results

file | result | raw_text_length | locator | address_found | duration_ms
--- | --- | ---: | --- | --- | ---:
WhatsApp Image 2026-06-03 at 13.55.16 (1).jpeg | PASS | 766 | 7249 | true | 859
WhatsApp Image 2026-06-03 at 13.55.16 (2).jpeg | PASS | 758 | 7470 | true | 241
WhatsApp Image 2026-06-03 at 13.55.16.jpeg | PASS | 728 | 3769 | true | 248
WhatsApp Image 2026-06-03 at 13.55.17 (1).jpeg | PASS | 820 | 0672 | true | 267
WhatsApp Image 2026-06-03 at 13.55.17.jpeg | PASS | 762 | 8368 | true | 226
WhatsApp Image 2026-06-03 at 13.55.18 (1).jpeg | PASS | 712 | 4655 | true | 244
WhatsApp Image 2026-06-03 at 13.55.18 (2).jpeg | PASS | 707 | 0905 | true | 209
WhatsApp Image 2026-06-03 at 13.55.18 (3).jpeg | PASS | 765 | 7654 | true | 227
WhatsApp Image 2026-06-03 at 13.55.18.jpeg | PASS | 467 | 5102 | true | 221

## Critical Errors

None
