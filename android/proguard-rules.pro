# Keep core components of Kotlin Coroutines
-keep class kotlin.coroutines.** { *; }
-keep class kotlinx.coroutines.** { *; }

# Keep intrinsic support classes (Resolves CoroutineSingletons errors)
-keep class kotlin.coroutines.intrinsics.** { *; }

# Keep Metadata and Annotations so JNI/jnigen can read function structure
-keepattributes *Annotation*, InnerClasses, EnclosingMethod, Signature, Exceptions, Metadata

# Keep entire package containing your logic
-keep class com.vanvixi.file_saver_ffi.** {
    <methods>;
    <fields>;
}

# Prevent parameter name obfuscation (Critical for JNI signature matching)
-keepparameternames

# Keep base Java/Kotlin classes commonly used in return values
-keep class kotlin.Result { *; }
-keep class kotlin.jvm.internal.** { *; }
