plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shiheng.shiheng_oa"
    compileSdk = 36
    ndkVersion = "29.0.14033849"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.shiheng.shiheng_oa"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        // 从 pubspec.yaml 读 version
        val pubspecFile = rootProject.file("../pubspec.yaml")
        val versionLine = pubspecFile.readLines().first { it.startsWith("version:") }
        val versionStr = versionLine.substringAfter("version:").trim()
        val parts = versionStr.split("+")
        versionName = parts[0]
        versionCode = if (parts.size > 1) parts[1].toInt() else 1
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}
