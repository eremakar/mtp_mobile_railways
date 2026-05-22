import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.Terminal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    val hasReleaseKeystore = keystorePropertiesFile.exists()
    if (hasReleaseKeystore) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                enableV1Signing = true
                enableV2Signing = true

                @Suppress("DEPRECATION")
                isV1SigningEnabled = true
                @Suppress("DEPRECATION")
                isV2SigningEnabled = true
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.Terminal"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}


// Скрипт для сборки apk + подпись V1 (cd android ./gradlew --no-daemon clean :app:sunmiApk)


val flutterRootDir = rootProject.projectDir.parentFile

fun loadPropsOrNull(file: File): Properties? {
    if (!file.exists()) return null
    return Properties().apply { load(FileInputStream(file)) }
}

val localProps = loadPropsOrNull(rootProject.file("local.properties"))
val sdkDirPath = localProps?.getProperty("sdk.dir")
    ?: throw GradleException("sdk.dir not found. Ensure android/local.properties contains sdk.dir=...")
val sdkDirFile = File(sdkDirPath)

val buildToolsVersion = "35.0.1" // installed on your machine
val apksignerPath = File(sdkDirFile, "build-tools/$buildToolsVersion/apksigner").absolutePath
val zipalignPath = File(sdkDirFile, "build-tools/$buildToolsVersion/zipalign").absolutePath

val keyPropsFile = rootProject.file("key.properties")
val keyProps = loadPropsOrNull(keyPropsFile)
    ?: throw GradleException("android/key.properties not found. Create it to enable SUNMI signing.")

val ksStoreFileRel = keyProps.getProperty("storeFile")
    ?: throw GradleException("key.properties is missing 'storeFile'")
val ksAlias = keyProps.getProperty("keyAlias")
    ?: throw GradleException("key.properties is missing 'keyAlias'")
val ksStorePass = keyProps.getProperty("storePassword")
    ?: throw GradleException("key.properties is missing 'storePassword'")
val ksKeyPass = keyProps.getProperty("keyPassword")
    ?: throw GradleException("key.properties is missing 'keyPassword'")

val ksPath = rootProject.file(ksStoreFileRel).absolutePath

val sunmiOutDir = File(flutterRootDir, "build/app/outputs/sunmi")
val flutterReleaseApk = File(flutterRootDir, "build/app/outputs/flutter-apk/app-release.apk").absolutePath
val alignedApk = File(sunmiOutDir, "app-release-aligned.apk").absolutePath
val sunmiApkOut = File(sunmiOutDir, "app-release-sunmi.apk").absolutePath

val flutterReleaseApkTask = tasks.register<Exec>("flutterReleaseApk") {
    group = "sunmi"
    description = "flutter clean + flutter build apk --release"
    workingDir = flutterRootDir
    commandLine("bash", "-lc", "flutter clean && flutter build apk --release")
}

val sunmiZipalignTask = tasks.register<Exec>("sunmiZipalign") {
    group = "sunmi"
    description = "zipalign Flutter release APK"
    dependsOn(flutterReleaseApkTask)
    workingDir = flutterRootDir

    doFirst {
        sunmiOutDir.mkdirs()
    }

    commandLine(zipalignPath, "-p", "-f", "4", flutterReleaseApk, alignedApk)
}

val sunmiSignTask = tasks.register<Exec>("sunmiSign") {
    group = "sunmi"
    description = "Sign aligned APK with V1+V2 for SUNMI"
    dependsOn(sunmiZipalignTask)
    workingDir = flutterRootDir

    commandLine(
        apksignerPath,
        "sign",
        "--verbose",
        "--min-sdk-version",
        "21",
        "--ks",
        ksPath,
        "--ks-key-alias",
        ksAlias,
        "--ks-pass",
        "pass:$ksStorePass",
        "--key-pass",
        "pass:$ksKeyPass",
        "--v1-signing-enabled",
        "true",
        "--v2-signing-enabled",
        "true",
        "--v3-signing-enabled",
        "false",
        "--out",
        sunmiApkOut,
        alignedApk
    )
}

val sunmiVerifyTask = tasks.register<Exec>("sunmiVerify") {
    group = "sunmi"
    description = "Verify SUNMI APK (forces v1 check with --min-sdk-version 21)"
    dependsOn(sunmiSignTask)
    workingDir = flutterRootDir

    commandLine(
        apksignerPath,
        "verify",
        "--verbose",
        "--print-certs",
        "--min-sdk-version",
        "21",
        sunmiApkOut
    )
}

tasks.register("sunmiApk") {
    group = "sunmi"
    description = "Build + sign + verify SUNMI-ready APK (V1+V2)"
    dependsOn(sunmiVerifyTask)

    doLast {
        println("✅ SUNMI APK ready: ${sunmiApkOut}")
    }
}
