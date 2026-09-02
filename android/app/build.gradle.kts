import com.android.build.api.variant.FilterConfiguration.FilterType.ABI

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val abiVersionCodes =
    mapOf(
        "armeabi-v7a" to 1,
        "arm64-v8a" to 2,
        "x86_64" to 3,
    )

android {
    namespace = "com.stonegate.tsacdop"
    compileSdk = 37
    compileSdkMinor = 0
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.stonegate.tsacdop"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("KEYSTORE") ?: "keystore.jks")
            storePassword = System.getenv("KEYSTORE_PASSWORD")
            keyAlias = System.getenv("KEY_ALIAS")
            keyPassword = System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            isShrinkResources = false
        }
    }

    flavorDimensions += "deploy"
    productFlavors {
        create("play") {
            dimension = "deploy"
            signingConfig = signingConfigs.getByName("release")
        }
        create("fdroid") {
            dimension = "deploy"
        }
    }
}

androidComponents {
    onVariants { variant ->
        variant.outputs.forEach { output ->
            val abi = output.filters.find { it.filterType == ABI }?.identifier
            val abiVersionCode = abiVersionCodes[abi]

            if (abiVersionCode != null) {
                output.versionCode.set(output.versionCode.get() * 10 + abiVersionCode)
            }
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
