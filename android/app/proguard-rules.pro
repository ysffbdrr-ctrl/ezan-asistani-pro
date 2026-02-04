# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Play Core (for split APKs)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.** { *; }

# Audio Service
-keep class com.ryanheise.audioservice.** { *; }

# HTTP
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep application class
-keep public class * extends android.app.Application
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}
