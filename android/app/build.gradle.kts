import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
// Release signing is configured only when signing material is present, so
// debug builds work without a keystore.
val releaseStorePath: String? =
    keystoreProperties.getProperty("storeFile") ?: System.getenv("X_KEYSTORE_PATH")

android {
    namespace = "io.github.xarantolus.matterleast"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
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

    signingConfigs {
        if (releaseStorePath != null) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(releaseStorePath)
                storePassword = keystoreProperties.getProperty("storePassword")
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
            signingConfig = signingConfigs.getByName(if (releaseStorePath != null) "release" else "debug")
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
