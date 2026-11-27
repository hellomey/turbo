# Android release signing

`app/build.gradle.kts` signs release builds with the release keystore when one is available, and otherwise falls
back to the debug key (so `flutter run --release` works on any machine). It looks for, in order:

1. `apps/mobile/android/key.properties` (local builds; git-ignored), with `storeFile`, `storePassword`, `keyAlias`,
   `keyPassword`.
2. Environment variables `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
   `ANDROID_KEY_PASSWORD` (CI).

`.github/workflows/android-beta.yml` decodes the keystore from GitHub secrets when all four exist, and the release
notes then say "Signing: release keystore". Without them the notes keep the debug-key warning.

## One-time setup (founder)

The keystore is the app's identity. Lose it and installed apps can never be updated by a new APK; leak it and anyone
can ship an "update". Create it once, on your own machine.

1. Create the keystore (JDK `keytool`; answer the name prompts with the company or your name):

   ```sh
   keytool -genkeypair -v -keystore heymey-release.jks -storetype JKS \
     -keyalg RSA -keysize 4096 -validity 10000 -alias heymey
   ```

   Use a long random password. With JKS, use the same password for the store and the key.

2. Back it up: the `.jks` file and both passwords in a password manager, plus one offline copy. Never commit it.

3. Base64 it for GitHub (one line, no wrapping):

   ```sh
   base64 -w0 heymey-release.jks > heymey-release.jks.b64     # Linux / Git Bash
   base64 -i heymey-release.jks | tr -d '\n' > heymey-release.jks.b64   # macOS
   ```

4. In GitHub, `hellomey/turbo` → Settings → Secrets and variables → Actions → New repository secret, add:

   | Secret | Value |
   | --- | --- |
   | `ANDROID_KEYSTORE_BASE64` | contents of `heymey-release.jks.b64` |
   | `ANDROID_KEYSTORE_PASSWORD` | store password |
   | `ANDROID_KEY_ALIAS` | `heymey` |
   | `ANDROID_KEY_PASSWORD` | key password |

   Or with the CLI: `gh secret set ANDROID_KEYSTORE_BASE64 < heymey-release.jks.b64` (and the other three
   interactively). Delete the `.b64` file afterwards.

5. Run the `android-beta` workflow (Actions → android-beta → Run workflow) and check the release notes say
   "Signing: release keystore".

## Switching from the debug key

Android refuses to update an app signed with a different key. Testers who installed a debug-signed beta must uninstall
it once before installing the first release-signed APK (their local guest progress on that phone is lost; synced
accounts are not). Tell testers before the switch.

## Local release build (optional)

Create `apps/mobile/android/key.properties` (git-ignored):

```properties
storeFile=/absolute/path/to/heymey-release.jks
storePassword=...
keyAlias=heymey
keyPassword=...
```
