# DeliveryFlow Device Smoke Test

Run ID: AUTO-1780609852753
Started: 2026-06-04T21:50:52.753132Z
Finished: 2026-06-04T21:50:56.460322Z
Duration: 3707 ms

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
WhatsApp Image 2026-06-03 at 13.55.16 (1).jpeg | PASS | 766 | 60297894 | true | 801
WhatsApp Image 2026-06-03 at 13.55.16 (2).jpeg | PASS | 758 | 89603033 | true | 232
WhatsApp Image 2026-06-03 at 13.55.16.jpeg | PASS | 728 | 42360973 | true | 241
WhatsApp Image 2026-06-03 at 13.55.17 (1).jpeg | PASS | 820 | 55211992 | true | 240
WhatsApp Image 2026-06-03 at 13.55.17.jpeg | PASS | 762 | 36084009 | true | 222
WhatsApp Image 2026-06-03 at 13.55.18 (1).jpeg | PASS | 712 | 61434988 | true | 230
WhatsApp Image 2026-06-03 at 13.55.18 (2).jpeg | PASS | 707 | 85627902 | true | 198
WhatsApp Image 2026-06-03 at 13.55.18 (3).jpeg | PASS | 765 | 88262924 | true | 216
WhatsApp Image 2026-06-03 at 13.55.18.jpeg | PASS | 467 | 70328745 | true | 220

## Critical Errors

None
