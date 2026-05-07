-keep class com.baseflow.googleapiavailability.** { *; }
-keep class com.baseflow.geolocator.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }

## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Google Fonts — prevent stripping HTTP classes it uses
-keep class com.google.** { *; }
-dontwarn com.google.**

## OkHttp (used by google_fonts for downloading fonts at runtime)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

## Gson / JSON parsing
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

## SharedPreferences
-keep class androidx.datastore.** { *; }

## General AndroidX
-keep class androidx.lifecycle.** { *; }