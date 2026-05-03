# Random Stuff for Dev

## For cleaning up

Run this to clean up gradle:

```bash
cd android; ./gradlew clean; cd ..
```

Run this to clean up the flutter environment:

```bash
fvm flutter clean; fvm flutter pub get
```

## Issues

When running:

```bash
fvm flutter build apk
```

The `Isar` package just gets errors. As of now, this is not yet fixed.

Some fixes include:

`AndroidManifest.xml` (Before)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="dev.isar.isar_flutter_libs" />
```

`AndroidManifest.xml` (After)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    />
```

`build.gradle` (Add one line)

```gradle
...
android {
    namespace "com.isar.isar_flutter_libs"
    ...
}
...
```

Do note, that this only fixes namespace issues.

## Official Fixes

I've managed to build the apk, and the fix for the issues with Isar is the following:

Go to `android\build.gradle.kts` and modify it to look like this:

```kts
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
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            project.extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                compileSdkVersion(36)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    project.plugins.withId("com.android.library") {
        project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            if (namespace == null) {
                namespace = project.group.toString()
            }
        }
    }
}
```

This fix was this:

```kts
subprojects {
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            project.extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                compileSdkVersion(36)
            }
        }
    }
}
```
