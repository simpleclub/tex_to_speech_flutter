# Setup Notes

Here you can find notes about changes to the initial project scaffold to make it working as proper Flutter plugin.

## Including MathCAT config
Due to MathCAT configuration approach that is based on YAML files in external directory it is not easy to configure it programmatically. Therefore, `include-zip` feature of MathCAT crate was chosen to include MathCAT configuration files in the plugin package (basically as binary source code).
Unfortunately, there appear to be a problem with this approach caused by MathCAT development dependencies not including `deflate` feature of `zip` crate. To fix this issue it was necessary to add [`MathCAT` fork](https://github.com/simpleclub-extended/MathCAT) as subtree of this repository. Then the `deflate` feature was enabled in the forked repository.

## Packaging prebuilt packages for WASM
Because building for WASM requires special command to be called before Flutter app can be built it is necessary to build the WASM package and publish it to the package repository. This is a good candidate to be moved to CI.
To prepare WASM developer has to run `generate_update.sh` script to generate WASM package and then add it to the commit. The WASM binary and glue code are included in `tex_to_speech/pkg` and are published as assets of `tex_to_speech` plugin.
Because Flutter assets are accessible under special paths `assets/packages/<plugin_name>/` it was also necessary to update configuration of `flutter_rust_bridge_codegen` (see https://cjycode.com/flutter_rust_bridge/guides/custom/codegen/full-list for list of options) to set `default_external_library_loader_web_prefix` option to `assets/packages/tex_to_speech/pkg/`. This way the WASM binary can be correctly loaded by Flutter Web application.

## Continous Integration
1. The GitHub Action workflow was created following instructions from [this guide for cargokit](https://github.com/irondash/cargokit/blob/main/docs/precompiled_binaries.md). Please, note the cargokit source code is part of the repository - it was included by `flutter_rust_bridge_codegen create` command.
2. Windows was excluded from the workflow because we don't support Windows desktop applications yet.
3. Building for Android wasn't working correctly due to missing Android SDK and NDK not being installed by the example workflow from the guide. Adding step to install Android SDK and NDK solved the issue.
4. Step to install Rust toolchain was added in case it won't be installed automatically by `cargokit` command.
