# Development environment

How to set up a machine to build and run the ApexGuide app for Android. iOS builds run on a GitHub Actions macOS runner (DEC-006).

---

## Versions

| Tool | Version | Why |
| --- | --- | --- |
| Flutter | 3.38.10 (Dart 3.10.9) | Newest that runs on macOS 12; pinned by DEC-012 until a macOS 14+ machine is available |
| JDK | 21 (Temurin) | Used by Gradle for Android builds |
| Android SDK command-line tools | latest | Android Studio is not required |
| Android platform and build-tools | android-36, build-tools 36.0.0 | Installed with `sdkmanager`; Gradle downloads the NDK and CMake on the first build |
| Emulator system image | `system-images;android-34;google_apis;x86_64` | The Android 16 Play Store image is too heavy for the 2016 MacBook Pro (ISS-007) |

Dart 3.11 and later refuse to start on macOS older than 14 ("VM initialization failed: Current Mac OS X version 12.0 is lower than minimum supported version 14.0"). On a macOS 14+ machine, follow DEC-012's upgrade notes instead of installing 3.38.10.

---

## Install Flutter

Download the x64 (Intel) or arm64 (Apple silicon) archive from the [Flutter SDK archive](https://docs.flutter.dev/install/archive) and check its SHA-256 against the value listed there.

```bash
mkdir -p ~/development && cd ~/development
curl -fLO https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.38.10-stable.zip
shasum -a 256 flutter_macos_3.38.10-stable.zip
# x64: b7056ba00082b9b814415e7516287bb94633c1108838bfe10f8f665307b99afa
unzip -q flutter_macos_3.38.10-stable.zip && rm flutter_macos_3.38.10-stable.zip
```

Add Flutter and the Android tools to `~/.zshrc`:

```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$HOME/development/flutter/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
```

Then, in a new terminal:

```bash
flutter --disable-analytics
flutter config --android-sdk "$ANDROID_HOME"
flutter config --jdk-dir="$(/usr/libexec/java_home -v 21)"
flutter --version   # Flutter 3.38.10, Dart 3.10.9
```

---

## Android SDK and emulator

The SDK lives in `~/Library/Android/sdk` with the command-line tools in `cmdline-tools/latest`. `sdkmanager` prints a deprecation notice pointing to the new `android` CLI but still works.

```bash
sdkmanager --install "emulator" "platforms;android-36" "system-images;android-34;google_apis;x86_64"
flutter doctor --android-licenses
```

Create the emulator. The small screen, host GPU and disabled audio keep it usable on the 2016 MacBook Pro:

```bash
echo no | avdmanager create avd -n apexguide_pixel -k "system-images;android-34;google_apis;x86_64" -d pixel_7
```

Then set these values in `~/.android/avd/apexguide_pixel.avd/config.ini`:

```ini
hw.ramSize=2048
hw.cpu.ncore=2
hw.lcd.width=720
hw.lcd.height=1280
hw.lcd.density=320
hw.gpu.mode=host
hw.keyboard=yes
hw.audioInput=no
hw.audioOutput=no
```

Start it with:

```bash
emulator -avd apexguide_pixel -no-boot-anim -no-audio &
```

After a cold boot the emulator spends several minutes on background work and may show "System UI isn't responding". Choose Wait; it becomes responsive once that work is done. Later boots resume from the quick-boot snapshot. A physical Android phone (Android 7.0 or later, USB debugging on) is faster on this machine.

---

## Check

```bash
flutter doctor -v
```

Expected: Flutter and Android toolchain pass with all Android licenses accepted. Xcode and CocoaPods fail on macOS 12; that is expected.

The first `flutter build apk` or `flutter run` takes about 8 minutes because Gradle downloads its dependencies, the NDK and CMake. Later builds are much faster.
