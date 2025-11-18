pluginManagement {
    // Esta é a forma correta de ler o SDK
    val flutterSdkPath = System.getenv("FLUTTER_ROOT")
        ?: run {
            val properties = java.util.Properties()
            val localPropertiesFile = File(settingsDir, "local.properties")
            if (localPropertiesFile.exists()) {
                properties.load(localPropertiesFile.inputStream())
            }
            properties.getProperty("flutter.sdk")
        }

    require(flutterSdkPath != null) { "flutter.sdk not set in local.properties or FLUTTER_ROOT env var" }

    // Agora o 'flutterSdkPath' está no escopo correto
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.10" apply false
}

include(":app")

// Este script é inteligente e vai ler o 'local.properties' sozinho
apply(from = "../packages/flutter_tools/gradle/app_plugin_loader.gradle")