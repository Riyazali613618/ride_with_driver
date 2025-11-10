# ======================= FLUTTER CORE =======================
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# ======================= KOTLIN =============================
-keep class kotlin.** { *; }
-dontwarn kotlin.**
-keep class kotlinx.** { *; }
-dontwarn kotlinx.**

# ======================= DART REFLECTION SUPPORT ============
-keepattributes InnerClasses, EnclosingMethod, Signature, Annotation
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
    <methods>;
}

# ======================= FIREBASE ===========================
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Messaging background service
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.iid.FirebaseInstanceIdService { *; }

# ======================= GOOGLE PLAY CORE ===================
-keep class com.google.android.play.** { *; }
-dontwarn com.google.android.play.**

# ======================= RAZORPAY ===========================
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-dontwarn proguard.annotation.**
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# ======================= NOTIFICATIONS ======================
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# ======================= GSON ===============================
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ======================= PARCELABLE SUPPORT =================
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# ======================= CAMERA =============================
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# ======================= PERMISSION HANDLER ================
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ======================= GOOGLE ML KIT ======================
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ======================= FLUTTER DEFERRED ===================
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# ======================= GENERAL ============================
-dontnote
-dontwarn
