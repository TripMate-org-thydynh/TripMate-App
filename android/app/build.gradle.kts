import java.util.Properties
import java.io.FileInputStream
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Keystore release đọc từ android/key.properties (file này KHÔNG commit).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.tripmate.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.tripmate.app"
        minSdk = 24
        targetSdk = 36
        // Lấy từ pubspec.yaml (version: x.y.z+build) — bump version ở một chỗ duy nhất.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.isNotEmpty()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Ký bằng keystore thật khi có android/key.properties; nếu không có
            // (máy dev chưa cấu hình) rơi về debug key để `flutter run --release`
            // vẫn chạy. Bản nộp Google Play BẮT BUỘC phải có key.properties.
            // Chốt chặn bảo vệ: Nếu đang chạy task đóng gói bundle (.aab) để nộp store
            // mà thiếu key.properties thì chặn ngay (throw GradleException) thay vì âm thầm
            // ký bằng debug key khiến Play Console từ chối.
            val isBuildingBundle = gradle.startParameter.taskNames.any {
                it.contains("bundle", ignoreCase = true)
            }
            signingConfig = if (keystoreProperties.isNotEmpty()) {
                signingConfigs.getByName("release")
            } else if (isBuildingBundle) {
                throw GradleException(
                    "Không tìm thấy android/key.properties để ký bản phát hành (bundle)! " +
                    "Bản bundle (.aab) nộp lên Google Play Store bắt buộc phải được ký bằng khóa release thật. " +
                    "Vui lòng tạo file android/key.properties trước khi build bundle."
                )
            } else {
                signingConfigs.getByName("debug")
            }
            
            // Enable R8 / ProGuard shrinking and obfuscation
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
