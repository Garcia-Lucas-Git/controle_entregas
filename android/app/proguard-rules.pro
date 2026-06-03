# ── Flutter engine & plugins ──────────────────────────────────────────────────
# Dart code compiles to native ARM via AOT — ProGuard does not touch it.
# These rules protect the Java/Kotlin plugin bridge layer.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# ── Drift / SQLite (Android binding) ──────────────────────────────────────────
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
-keepclassmembers class * extends androidx.sqlite.db.SupportSQLiteOpenHelper { *; }

# ── ML Kit Text Recognition (Latin only — keep core recognizer) ───────────────
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }

# ── ML Kit ComponentDiscovery — keep no-arg constructors used by reflection ───
# Root cause confirmed: R8 strips these constructors → NoSuchMethodException
# → VisionCommonRegistrar/CommonComponentRegistrar never register →
# → TextRecognizer.processImage() receives null internal dependencies → NPE.
# Evidence: usage.txt shows both <init>() removed; seeds.txt shows class kept.
-keepclassmembers class com.google.mlkit.common.internal.CommonComponentRegistrar {
  public <init>();
}
-keepclassmembers class com.google.mlkit.vision.common.internal.VisionCommonRegistrar {
  public <init>();
}

# ── ML Kit — suppress missing class warnings for unused script recognizers ────
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions

# ── Play Core (referenced by FlutterPlayStoreSplitApplication) ────────────────
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
