#!/bin/bash

# تنظیم متغیر پروژه
PROJECT_DIR=$(pwd)
echo "📍 در حال کار در: $PROJECT_DIR"

# 1. پاکسازی کش‌ها
echo "🧹 پاکسازی کش‌های قدیمی..."
rm -rf ~/.gradle/caches/
rm -rf android/.gradle
rm -rf android/build
rm -rf android/app/build

# 2. تصحیح نسخه Gradle (به 8.14 آپدیت شد برای Flutter 3.38)
echo "🔧 تصحیح نسخه Gradle..."
cat > android/gradle/wrapper/gradle-wrapper.properties << 'EOL'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOL

# 3. تصحیح settings.gradle.kts (سازگار با Flutter جدید)
echo "📝 تصحیح تنظیمات..."
cat > android/settings.gradle.kts << 'EOL'
pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.5.0" apply false  // آپدیت به 8.5 برای AGP
    id("org.jetbrains.kotlin.android") version "1.9.25" apply false  // آپدیت Kotlin
}
include(":app")
EOL

# 4. تصحیح gradle.properties
cat > android/gradle.properties << 'EOL'
org.gradle.jvmargs=-Xmx4096M -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError
org.gradle.parallel=true
org.gradle.daemon=true
org.gradle.caching=true
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
EOL

# 5. دانلود gradle-wrapper.jar (برای نسخه 8.14)
echo "📥 دانلود Gradle wrapper..."
cd android
wget -q https://github.com/gradle/gradle/raw/v8.14/gradle/wrapper/gradle-wrapper.jar -O gradle/wrapper/gradle-wrapper.jar
cd ..

# 6. Flutter clean و pub get
echo "🧹 پاکسازی Flutter..."
flutter clean
flutter pub get

echo "=========================================="
echo " مشکل رفع شد!"
echo "حالا این دستور را اجرا کنید:"
echo "flutter run"
echo "=========================================="
