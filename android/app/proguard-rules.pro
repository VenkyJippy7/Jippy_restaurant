####################################
# Flutter
####################################
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }

# Keep your Flutter app package (change com.jippymart.restaurant to your app's package)
-keep class com.jippymart.restaurant.** { *; }

####################################
# Firebase (Messaging, App Check, etc.)
####################################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase Messaging services (FirebaseInstanceIdService is deprecated but keep it if you still use it)
-keep class * extends com.google.firebase.messaging.FirebaseMessagingService
-keep class * extends com.google.firebase.iid.FirebaseInstanceIdService

# Firebase App Check
-keep class com.google.firebase.appcheck.** { *; }
-keep class com.google.firebase.appcheck.playintegrity.** { *; }

####################################
# Play Integrity API
####################################
-keep class com.google.android.play.core.integrity.** { *; }
-keep class com.google.android.play.integrity.** { *; }
-keep class com.google.android.play.integrity.internal.** { *; }
-dontwarn com.google.android.play.core.integrity.**
-dontwarn com.google.android.play.integrity.**

####################################
# Flutter Local Notifications
####################################
-keep class com.dexterous.flutterlocalnotifications.** { *; }

####################################
# Google Maps (optional, if used)
####################################
-keep class com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**

####################################
# Play Core (SplitInstallManager, dynamic features)
####################################
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

####################################
# Kotlin and Coroutines (if used)
####################################
-dontwarn kotlin.**
-keep class kotlin.** { *; }
-keepclassmembers class kotlin.Metadata { *; }

####################################
# Android Components (Activity, Service, etc.)
####################################
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Parcelable support
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Enum support
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

####################################
# Attributes for reflection
####################################
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepattributes Signature
-keepattributes *Annotation*

####################################
# General reflection support (constructors)
####################################
-keepclassmembers class * {
    public <init>(...);
}

####################################
# Remove logs in release builds (optional)
####################################
-assumenosideeffects class android.util.Log {
    public static int v(java.lang.String, java.lang.String);
    public static int d(java.lang.String, java.lang.String);
    public static int i(java.lang.String, java.lang.String);
    public static int w(java.lang.String, java.lang.String);
    public static int e(java.lang.String, java.lang.String);
}

# Keep Stripe classes
-keep class com.stripe.android.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.** { *; }

# Keep Stripe Push Provisioning specific classes
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity$* { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$* { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider { *; }
-keep class com.stripe.android.pushProvisioning.EphemeralKeyUpdateListener { *; }

# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }

# Keep Google Pay (NBU Paisa) classes
-keep class com.google.android.apps.nbu.paisa.** { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.** { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.client.** { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.PaymentsClient { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.Wallet { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.WalletUtils { *; }

# Keep Google Pay classes
-keep class com.google.android.gms.pay.** { *; }
-keep class com.google.android.gms.wallet.** { *; }

# Keep ProGuard annotations
-keep @interface proguard.annotation.Keep
-keep @interface proguard.annotation.KeepClassMembers
-keep @proguard.annotation.Keep class *
-keepclassmembers class * {
    @proguard.annotation.Keep *;
}

# Keep React Native Stripe SDK
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }
-keep class com.reactnativestripesdk.pushprovisioning.DefaultPushProvisioningProxy { *; }
-keep class com.reactnativestripesdk.pushprovisioning.PushProvisioningProxy { *; }
-keep class com.reactnativestripesdk.pushprovisioning.PushProvisioningProxy$* { *; }

# Keep all classes referenced by Razorpay
-keep class com.razorpay.RzpGpayMerged { *; }
-keep class com.razorpay.AnalyticsConstants { *; }
-keep class com.razorpay.AnalyticsEvent { *; }

# Keep all classes referenced by Stripe
-keep class com.stripe.android.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.stripe.android.pushProvisioning.EphemeralKeyUpdateListener { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider { *; }

# Suppress warnings for missing classes
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.PaymentsClient
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.Wallet
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.WalletUtils
-dontwarn com.stripe.android.pushProvisioning.EphemeralKeyUpdateListener
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Keep all classes that might be used by reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
