# Flutter Engine ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class org.chromium.** { *; }

# Keep In-App Purchase classes safe from obfuscation/shrinking
-keep class com.android.billingclient.** { *; }
-keep class io.flutter.plugins.inapppurchase.** { *; }

# Play Core (deferred components) — Flutter engine tham chiếu tới các class này
# nhưng app không dùng split-install, nên chúng không có mặt lúc R8 chạy.
# Không suppress thì R8 fail toàn bộ build release.
-dontwarn com.google.android.play.core.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# flutter_secure_storage / androidx.security
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**
