# DeliveryFlow — Checkpoint de Recuperação
**Data:** 2026-06-01  
**Status:** Implementação Fase 4 concluída / Fase 5 (Build APK) interrompida

---

## STATUS ATUAL

### `dart analyze lib/` → **No issues found** ✅
### APK build → **PENDENTE** (último build falhou, correção já aplicada)

---

## FASES CONCLUÍDAS

### Fase 1 — Base ✅
- pubspec.yaml com todas as dependências
- AndroidManifest.xml com permissões (CAMERA, WAKE_LOCK, INTERNET)
- Estrutura de pastas completa
- Domain: enums, entities, value objects
- Data: 7 tabelas Drift, 5 DAOs, AppDatabase com seed
- Repositories: ShiftRepository, RouteRepository, DeliveryRepository, EarningsRepository, SettingsRepository
- Providers Riverpod: database_provider.dart (todos os repos + ExportService)
- build_runner executado com sucesso

### Fase 2 — Navigation + Home + Settings ✅
- GoRouter configurado (9 rotas, redirect guard de setup)
- ShiftNotifier (openShift, closeShift)
- HomeScreen (3 estados: setup, sem turno, turno ativo)
- SettingsScreen (nome, pizzaria, taxas, iFood, OCR, exportação)

### Fase 3 — OCR + Rotas ✅
- OcrService (ML Kit Latin, parser por keyword anchors, detecção de flags)
- OcrKeywords centralizado em constants.dart
- MapsLauncher (deep link single-stop + multi-waypoint + fallback)
- RouteNotifier (createRoute, closeRoute + classificação de ganhos)
- DeliveryNotifier (createFromOcr, createManual, complete, updateIfood)
- NewRouteScreen (câmera, OCR, preview por comprovante)
- RouteReviewScreen (cards editáveis, drag-to-reorder, flags toggle)
- ActiveRouteScreen (lista pendentes/concluídas, barra progresso, Maps, WakeLock, Fechar Rota)

### Fase 4 — Delivery + iFood + Relatório + Histórico ✅
- DeliveryCardScreen (WakeLock, warnings banner, botão 72dp, setInProgress automático)
- IFoodConfirmationScreen (WebView automático, numpad nativo, JS injection, state machine, overlay resultado)
- IFoodNotifier (state machine: loading→webviewActive→success|failed→manualFallback→manualConfirmed)
- EarningsNotifier + shiftReportDataProvider
- ReportGenerator (relatório texto português)
- ExportService (CSV UTF-8 BOM, Google Sheets, share_plus)
- HistoryScreen (agrupamento mês, expansão por turno)
- ShiftReportScreen (preview selecionável, compartilhar)
- Router: todas as 9 rotas conectadas a telas reais
- Seção "Exportar Dados" adicionada à SettingsScreen

---

## PRÓXIMO PASSO IMEDIATO

### Corrigir e rodar o build APK

O build anterior falhou com erro R8 (missing classes ML Kit).  
A correção JÁ FOI APLICADA:

**Arquivo criado:** `android/app/proguard-rules.pro`
```
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
```

**Arquivo atualizado:** `android/app/build.gradle.kts`  
Release buildType agora tem `isMinifyEnabled = true`, `isShrinkResources = true`, e referencia `proguard-rules.pro`.

**Comando para retomar:**
```bash
export PATH="$PATH:/home/lucas/snap/flutter/common/flutter/bin"
flutter build apk --release --split-per-abi --target-platform android-arm64
```

**APK gerado em:**
```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## ARQUIVOS CRIADOS (por fase)

### Domínio
- `lib/domain/enums/shift_status.dart`
- `lib/domain/enums/route_status.dart`
- `lib/domain/enums/delivery_status.dart`
- `lib/domain/enums/earnings_type.dart`
- `lib/domain/entities/shift.dart`
- `lib/domain/entities/route_entity.dart`
- `lib/domain/entities/delivery.dart`
- `lib/domain/entities/earnings_entry.dart`
- `lib/domain/entities/app_settings.dart`
- `lib/domain/value_objects/money.dart`
- `lib/domain/value_objects/earnings_rules.dart`

### Banco de dados (Drift)
- `lib/data/database/app_database.dart`
- `lib/data/database/tables/shifts_table.dart`
- `lib/data/database/tables/routes_table.dart`
- `lib/data/database/tables/deliveries_table.dart`
- `lib/data/database/tables/receipts_table.dart`
- `lib/data/database/tables/earnings_entries_table.dart`
- `lib/data/database/tables/earnings_config_table.dart`
- `lib/data/database/tables/app_config_table.dart`
- `lib/data/database/daos/shifts_dao.dart`
- `lib/data/database/daos/routes_dao.dart`
- `lib/data/database/daos/deliveries_dao.dart`
- `lib/data/database/daos/earnings_dao.dart`
- `lib/data/database/daos/config_dao.dart`
- `lib/data/database/daos/receipts_dao.dart`

### Repositórios
- `lib/data/repositories/shift_repository.dart`
- `lib/data/repositories/route_repository.dart`
- `lib/data/repositories/delivery_repository.dart`
- `lib/data/repositories/earnings_repository.dart`
- `lib/data/repositories/settings_repository.dart`

### Application layer
- `lib/application/shifts/shift_notifier.dart`
- `lib/application/routes/route_notifier.dart`
- `lib/application/deliveries/delivery_notifier.dart`
- `lib/application/earnings/earnings_notifier.dart`
- `lib/application/settings/settings_notifier.dart`
- `lib/application/wakelock/wakelock_controller.dart`
- `lib/application/ifood/ifood_provider.dart`

### Serviços
- `lib/services/ocr_service.dart`
- `lib/services/maps_launcher.dart`
- `lib/services/report_generator.dart`
- `lib/services/export_service.dart`

### Core
- `lib/core/constants.dart`
- `lib/core/providers/database_provider.dart`

### Presentation
- `lib/presentation/router/app_router.dart`
- `lib/presentation/screens/home_screen.dart`
- `lib/presentation/screens/settings_screen.dart`
- `lib/presentation/screens/new_route_screen.dart`
- `lib/presentation/screens/route_review_screen.dart`
- `lib/presentation/screens/active_route_screen.dart`
- `lib/presentation/screens/delivery_card_screen.dart`
- `lib/presentation/screens/ifood_confirmation_screen.dart`
- `lib/presentation/screens/history_screen.dart`
- `lib/presentation/screens/shift_report_screen.dart`

### Android
- `android/app/proguard-rules.pro` ← **CRÍTICO para o build APK**

### App entry
- `lib/main.dart`
- `lib/app.dart`

---

## DECISÕES ARQUITETURAIS APROVADAS (não reabrir)

| Decisão | Escolha |
|---|---|
| State management | Riverpod 2.x com riverpod_generator |
| Navigation | GoRouter 14.x |
| Database | Drift 2.x + sqlite3_flutter_libs |
| OCR | google_mlkit_text_recognition (Latin only) |
| Maps | url_launcher deep links (sem SDK) |
| iFood | webview_flutter (WebView primário, url_launcher fallback) |
| WakeLock | wakelock_plus (constraint arquitetural em 3 telas) |
| Export | share_plus (CSV UTF-8 BOM) |
| Target | Motorola G56 5G, Android 13, GMS garantido |

### Regra de remuneração (CONGELADA)
```
IF route.delivery_count_at_close == 1 AND delivery.distance_km > 8.0
THEN long_single_delivery → R$10,00
ELSE normal → R$8,00
```
- `EarningsRules.kLongSingleDeliveryThresholdKm = 8.0` (constante hardcoded)
- Classificação ocorre no fechamento da rota
- Sem override manual

### Status de entrega (CONGELADO)
```
pending → in_progress → completed
```
Sem estado `failed`. Sem fluxo de entrega não realizada.

### Distância (Opção C aprovada)
- Persistir apenas `distance_km` (REAL nullable)
- Coordenadas são temporárias (não persistidas no banco)
- Mecanismo de captura: a ser definido na próxima sessão se necessário

---

## DEPENDÊNCIAS NO pubspec.yaml

```yaml
flutter_riverpod: ^2.6.1
riverpod_annotation: ^2.6.1
hooks_riverpod: ^2.6.1
flutter_hooks: ^0.20.5
go_router: ^14.6.2
drift: ^2.21.0
sqlite3_flutter_libs: ^0.5.26
path_provider: ^2.1.4
path: ^1.9.0
google_mlkit_text_recognition: ^0.13.1
image_picker: ^1.1.2
url_launcher: ^6.3.1
share_plus: ^10.1.4
webview_flutter: ^4.10.0
wakelock_plus: ^1.2.10
permission_handler: ^11.3.1
freezed_annotation: ^2.4.4
json_annotation: ^4.9.0
intl: ^0.19.0
shared_preferences: ^2.3.2
cupertino_icons: ^1.0.8

# dev
build_runner: ^2.4.13
drift_dev: ^2.21.0
riverpod_generator: ^2.6.1
freezed: ^2.5.7
json_serializable: ^6.8.0
flutter_lints: ^6.0.0
```

---

## FLUTTER PATH (ambiente)
```bash
export PATH="$PATH:/home/lucas/snap/flutter/common/flutter/bin"
```

---

## SCHEMA DO BANCO (schemaVersion = 1)

Tabelas: `shifts`, `routes`, `deliveries`, `receipts`,  
`earnings_entries`, `earnings_config`, `app_config`

Seed automático no `onCreate`: earnings_config (R$8/R$10) + app_config (defaults).
