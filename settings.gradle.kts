// Redirect root Gradle sync to the android sub-project
include(":android")
project(":android").projectDir = file("android")
