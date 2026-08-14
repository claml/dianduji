import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing reads DIANDUJI_STORE_FILE / DIANDUJI_STORE_PASSWORD /
// DIANDUJI_KEY_ALIAS / DIANDUJI_KEY_PASSWORD from, in order of precedence:
//   1. android/key.properties (the documented operator flow; never committed)
//   2. environment variables (CI use)
//   3. Gradle -P properties
// Release builds fail with an actionable message when any value is missing;
// debug builds stay development-signed. See android/key.properties.example.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

// Accept both the DIANDUJI_* key names (environment/CI style) and the
// short Flutter-template names (storeFile/storePassword/keyAlias/keyPassword)
// used inside android/key.properties.
fun releaseValue(key: String): String? {
    val shortName = when (key) {
        "DIANDUJI_STORE_FILE" -> "storeFile"
        "DIANDUJI_STORE_PASSWORD" -> "storePassword"
        "DIANDUJI_KEY_ALIAS" -> "keyAlias"
        "DIANDUJI_KEY_PASSWORD" -> "keyPassword"
        else -> null
    }
    return keystoreProperties.getProperty(key)
        ?: shortName?.let(keystoreProperties::getProperty)
        ?: System.getenv(key)
        ?: providers.gradleProperty(key).orNull
}

val releaseValues = listOf(
    "DIANDUJI_STORE_FILE",
    "DIANDUJI_STORE_PASSWORD",
    "DIANDUJI_KEY_ALIAS",
    "DIANDUJI_KEY_PASSWORD",
).associateWith(::releaseValue)

val releaseRequested =
    gradle.startParameter.taskNames.any { it.contains("Release") }
val missingReleaseValues = releaseValues.filterValues { it.isNullOrBlank() }.keys
if (releaseRequested && missingReleaseValues.isNotEmpty()) {
    error(
        "Missing release signing values: ${missingReleaseValues.joinToString()}.\n" +
            "Provide them via android/key.properties (see key.properties.example) " +
            "or the DIANDUJI_* environment variables.",
    )
}

android {
    namespace = "com.dianduji.dian_du_ji"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.dianduji.dian_du_ji"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (missingReleaseValues.isEmpty()) {
            create("release") {
                storeFile = releaseValues.getValue("DIANDUJI_STORE_FILE")
                    ?.let { file(it) }
                storePassword = releaseValues.getValue("DIANDUJI_STORE_PASSWORD")
                keyAlias = releaseValues.getValue("DIANDUJI_KEY_ALIAS")
                keyPassword = releaseValues.getValue("DIANDUJI_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Signed only from externally provided credentials; never falls
            // back to the debug key for a release artifact.
            val releaseSigning = signingConfigs.findByName("release")
            if (releaseSigning != null) signingConfig = releaseSigning
        }
    }

    testOptions {
        unitTests.isReturnDefaultValues = true
    }
}

dependencies {
    testImplementation("junit:junit:4.13.2")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
