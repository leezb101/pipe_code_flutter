# 指定代码的压缩级别
-optimizationpasses 5     
 
# 不忽略库中的非public的类成员
-dontskipnonpubliclibraryclassmembers 
 
# google推荐算法
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
 
# 避免混淆Annotation、内部类、泛型、匿名类
-keepattributes *Annotation*,InnerClasses,Signature,EnclosingMethod
 
# 抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable
 
# 保持四大组件
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class * extends android.view.View
-keep public class com.android.vending.licensing.ILicensingService
 
# 保持support下的所有类及其内部类
-keep class android.support.** {*;}
 
# 保留继承的
-keep public class * extends android.support.v4.**
-keep public class * extends android.support.v7.**
-keep public class * extends android.support.annotation.**
 
# 保持自定义控件
-keep public class * extends android.view.View{
    *** get*();
    void set*(***);
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}
 
# 保持所有实现 Serializable 接口的类成员
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
 
 
# webView处理
-keepclassmembers class fqcn.of.javascript.interface.for.webview {
    public *;
}
-keepclassmembers class * extends android.webkit.webViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.webViewClient {
    public void *(android.webkit.webView, jav.lang.String);
}

-keep class com.iflytek.sparkchain.** {*;}
-keep class com.iflytek.sparkchain.**

# Gson相关keep规则
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

# 保持Gson相关类
-keep class com.google.gson.** { *; }
-keep class com.google.gson.annotations.** { *; }

# 保持使用了@SerializedName注解的字段
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# 保持实现了Serializable接口的类
-keep class * implements java.io.Serializable { *; }

# 保持Parcelable的所有类
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# R8 missing rules - 来自missing_rules.txt的建议
-dontwarn com.google.gson.annotations.SerializedName
