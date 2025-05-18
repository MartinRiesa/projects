android {
    namespace     = "com.example.vokabeltrainer_app_new"
    compileSdk    = flutter.compileSdkVersion
    ndkVersion    = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.vokabeltrainer_app_new"
        minSdk        = flutter.minSdkVersion
        targetSdk     = flutter.targetSdkVersion
        versionCode   = 1
        versionName   = "1.0"
    }

    signingConfigs {
        create("release") {
            storeFile = file("my-release-key.jks")
            storePassword = "#4tkJTnv"
            keyAlias = "my-key-alias"
            keyPassword = "#4tkJTnv"
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("debug") {
            // Debug-Konfiguration bleibt wie sie ist
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = "11" }
}
