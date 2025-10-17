# Contributing guide

This file outlines how you can contribute to `tex_to_speech_flutter`.
If you are new to contributing on GitHub, you might want to see the setup section below.

## Setting up your repo

### Fork the tex_to_speech_flutter repository

* Ensure you have configured an SSH key with GitHub; see [GitHub's directions][ssh key].
* Fork [this repository][repo] using the "Fork" button in the upper right corner of the GitHub page.
* Clone the forked repo: `git clone git@github.com:<your_github_user_name>/tex_to_speech_flutter.git`
* Navigate into the project: `cd tex_to_speech_flutter`
* Add this repo as a remote repository:
  `git remote add upstream git@github.com:simpleclub/tex_to_speech_flutter.git`
* Add [MathCAT](MathCAT) as a subtree repository:
  ```sh
  git remote add MathCAT-origin https://github.com/simpleclub-extended/MathCAT.git
  git subtree add --prefix third_party/MathCAT MathCAT-origin main --squash
  ```

### Create pull requests

* Fetch the latest repo state: `git fetch upstream`
* Create a feature branch: `git checkout upstream/main -b <name_of_your_branch>`
* Now, you can change the code necessary for your patch.

  Make sure that you bump the version in [`pubspec.yaml`][pubspec]. You **must** bump the Pubspec
  version when a new package version should be released and edit the [`CHANGELOG.md`][changelog]
  accordingly.
  The version format needs to follow Dart's versioning conventions. See [this article][versioning]
  for everything you need to know about that. Pay special attention when landing breaking changes.
* In case any Rust source code is modified, ensure to run `generate_update.sh` script afterwards and include any generated files in your commit.
* Commit your changes: `git commit -am "<commit_message>"`
* Push your changes: `git push origin <name_of_your_branch>`

After having followed these steps, you are ready to [create a pull request][create pr].
The GitHub interface makes this very easy by providing a button on your fork page that creates
a pull request with changes from a recently pushed to branch.
Alternatively, you can also use `git pull-request` via [GitHub hub][].

## Notes

* Always add tests or confirm that your code is working with current tests.
* Use `dart format . --fix` to format all code.
* Adhere to the lints, i.e. the warnings provided by Dart's linter based on the repo's lint rules.
  Run `flutter analyze` in order to ensure that you are not missing any warnings or errors.
* If you find something that is fundamentally flawed, please propose a better solution -
  we are open to complete revamps.

## Contributor License Agreement

We require contributors to sign our [Contributor License Agreement (CLA)][CLA].
In order for us to review and merge your code, please follow the link and sign the agreement.

[repo]: https://github.com/simpleclub/tex_to_speech_flutter
[pubspec]: https://github.com/simpleclub/tex_to_speech_flutter/blob/main/tex_to_speech/pubspec.yaml
[changelog]: https://github.com/simpleclub/tex_to_speech_flutter/blob/main/tex_to_speech/CHANGELOG.md
[create pr]: https://help.github.com/en/articles/creating-a-pull-request-from-a-fork
[GitHub hub]: https://hub.github.com
[ssh key]: https://help.github.com/articles/generating-ssh-keys
[CLA]: https://cla-assistant.io/simpleclub/
[versioning]: https://stackoverflow.com/questions/66201337/how-do-dart-package-versions-work-how-should-i-version-my-flutter-plugins/66201338#66201338
[MathCAT]: (https://github.com/simpleclub-extended/MathCAT)
