# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Android Activity / Service / BroadcastReceiver / Fragment
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends androidx.fragment.app.Fragment

# Health Connect
-keep class android.health.** { *; }
-keep class android.health.connect.** { *; }
-dontwarn android.health.**

# Google Play Services / Health
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# OkHttp (used by Dio)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Keep annotations and source info for crash reporting
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# Preserve generic type info
-keepattributes InnerClasses

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
