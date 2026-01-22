## 1.0.0

* Initial release.

## 1.0.1

* Fix the issue can not use the plugin on a project that has version Kotlin lower than 1.6.10

## 1.0.2

* Change Minimum plugin require on iOS from iOS 10 to iOS 9.
* Fix the issue playback state on iOS does not work properly.

## 1.0.3

* Improve gesture on the time bar.

## 1.0.4

* Fix the issue can not build release with this plugin.

## 1.0.5

* Fix the issue playWhenReady not working on android.

## 1.0.6

* Add title header to bottom sheet.
* Fix the issue can not build with release mode.

## 1.0.7

* Upgrade Android Gradle Plugin to 8.11.1 and Gradle to 8.14.
* Upgrade Kotlin to 2.2.20.
* Migrate Android build configuration to Kotlin DSL (build.gradle.kts).
* Update minimum Android SDK to 24 and compile SDK to 36.
* Update Java compatibility to version 17.
* Update Flutter SDK requirement to ^3.10.7.
* Update dependencies: collection (^1.19.1), flutter_widget_from_html_core (^0.17.0), get (^4.7.3).
* Fix deprecated API usage: replace withOpacity with withValues, bodyText1 with bodyMedium.
* Fix dynamic type parameters with proper Object type.
* Replace hashValues with Object.hash.
* Fix BroadcastReceiver registration with ContextCompat.registerReceiver for Android 14+ compatibility.
* Remove kotlin-android-extensions plugin and migrate to kotlin-parcelize.
* Add proper ignore_for_file directives for linting.
* Code quality improvements and modernization via dart fix.