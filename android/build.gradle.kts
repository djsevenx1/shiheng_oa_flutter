allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    // 关键改动：给所有未声明 namespace 的第三方库注入 namespace。
    // AGP 8+ 强制要求每个 Android 模块都声明 namespace；
    // 一些老 Flutter 插件（amap_flutter_location 3.0.0、flutter_bmflocation 等）
    // 还没有适配，会在 Gradle 配置阶段直接失败。
    afterEvaluate {
        val ext = extensions.findByName("android")
        if (ext is com.android.build.gradle.LibraryExtension && ext.namespace == null) {
            ext.namespace = project.group.toString().ifEmpty { "flutter.plugin.${project.name}" }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
