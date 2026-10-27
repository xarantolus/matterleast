import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}
// Release signing is configured only when signing material is present, so
// debug builds work without a keystore. CI decodes the keystore to
// X_KEYSTORE_PATH, which wins over a storeFile copied into the secret; a
// relative storeFile is relative to android/, next to key.properties.
val releaseStoreFile: File? =
    System.getenv("X_KEYSTORE_PATH")?.takeIf { it.isNotEmpty() }?.let(::File)
        ?: keystoreProperties.getProperty("storeFile")?.let(rootProject::file)

fun signingProperty(name: String): String =
    keystoreProperties.getProperty(name)
        ?: throw GradleException("android/key.properties has no $name, so the release build cannot be signed.")

android {
    namespace = "io.github.xarantolus.matterleast"
    // receive_sharing_intent 1.9 compiles against Android 37.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications needs java.time on older Android.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.github.xarantolus.matterleast"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // The tray plugin's native library (nativeapi) is for desktops;
    // nothing on Android loads it.
    packaging {
        jniLibs {
            excludes += "**/libcnativeapi.so"
        }
    }

    signingConfigs {
        if (releaseStoreFile != null) {
            create("release") {
                keyAlias = signingProperty("keyAlias")
                keyPassword = signingProperty("keyPassword")
                storeFile = releaseStoreFile
                storePassword = signingProperty("storePassword")
            }
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-dev"
            manifestPlaceholders["applicationLabel"] = "Matterleast (debug)"
        }
        release {
            manifestPlaceholders["applicationLabel"] = "Matterleast"
            signingConfig = signingConfigs.getByName(if (releaseStoreFile != null) "release" else "debug")
            isMinifyEnabled = true
            isShrinkResources = true
        }
        // Profile builds are the only ones worth reading frame times from, so
        // they must build too: without a label the manifest merger fails.
        maybeCreate("profile").apply {
            applicationIdSuffix = ".profile"
            versionNameSuffix = "-profile"
            manifestPlaceholders["applicationLabel"] = "Matterleast (profile)"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
