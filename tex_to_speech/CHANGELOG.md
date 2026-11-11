## UPCOMING RELEASE
* Update Tokio to 1.54.1 and rebuild the web binary.

## 0.0.7
* Gradle 9 support: Cargokit runs its build tool through injected `ExecOperations` instead of the removed `Project.exec`.
* Update the core Rust lockfile to use `zip` 9.0.5, fixing GHSA-m665-v7pm-7grj.

## 0.0.6
* Strict CSP policy support
  * `flutter_rust_bridge` update (*2.14.0-priv.1* - custom fork of *2.14.0-beta.2*)
  * `MathCAT` update (`main` fork with `zip` crate update)

## 0.0.4

* 16KB alignment in Android prebuilt binaries

## 0.0.3

* Conversion improvements.

## 0.0.2

* Improved WASM performance

## 0.0.1

* Initial implementation of `tex_to_speech`.
  * Provides a basic API to convert TeX to spoken text in **German only**.
