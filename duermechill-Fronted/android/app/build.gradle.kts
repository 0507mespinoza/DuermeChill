plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.proyecto_intermodular"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        create("release") {
            storeFile = file(project.findProperty("KEYSTORE_PATH") ?: "keystore.jks")
            storePassword = project.findProperty("KEYSTORE_PASS")?.toString() ?: ""
            keyAlias = project.findProperty("KEY_ALIAS")?.toString() ?: "release"
            keyPassword = project.findProperty("KEY_PASS")?.toString() ?: ""
        }
    }

    defaultConfig {
        applicationId = "com.example.proyecto_intermodular"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}

tasks.configureEach {
    if (name.contains("AarMetadata")) {
        enabled = false
    }
}