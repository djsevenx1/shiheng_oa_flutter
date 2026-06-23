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

// 关键改动：用 gradle.beforeProject 钩子在每个 subproject 评估前注册
// afterEvaluate，避免 evaluationDependsOn(":app") 把项目先评估掉后
// 再注册 afterEvaluate 抛 "project is already evaluated" 的问题。
// AGP 8+ 强制要求每个 Android 模块都声明 namespace；
// 一些老 Flutter 插件（amap_flutter_location 3.0.0、flutter_bmflocation 等）
// 还没有适配，会在 Gradle 配置阶段直接失败。
gradle.beforeProject {
    project.afterEvaluate {
        val ext = project.extensions.findByName("android")
        if (ext is com.android.build.gradle.LibraryExtension && ext.namespace == null) {
            ext.namespace = "flutter.plugin.${project.name}"
        }
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
