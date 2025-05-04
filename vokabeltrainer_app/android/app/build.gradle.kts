plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace     = "com.example.vokabeltrainer_app_new"
    compileSdk    = flutter.compileSdkVersion
    ndkVersion    = "27.0.12077973"      // ↑ kompatibel mit flutter_tts ≥ v4

    defaultConfig {
        applicationId = "com.example.vokabeltrainer_app_new"
        minSdk        = flutter.minSdkVersion
        targetSdk     = flutter.targetSdkVersion
        versionCode   = 1
        versionName   = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = "11" }
}

dependencies { implementation(kotlin("stdlib")) }
