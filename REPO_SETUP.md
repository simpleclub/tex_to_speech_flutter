# Repository Setup

Repository is using Git subtree to manage third-party dependencies sources.

## Details (by LLM)
### How it works:
- You pull the upstream repository’s content into a subdirectory of your main repo preserving history (squashed or full) with `git subtree`.
- After that the code is just part of your repo—no separate clone needed.

### Pros:
- Contributors just clone one repo (no submodule gotchas).
- History is preserved (if desired) and stays in a single graph.
- Updating from upstream is a single `git subtree pull`.
- Works even if tooling dislikes submodules.

### Cons:
- The foreign project’s commits intermix in your repo’s history (unless you squash).
- Pushing changes back to your fork/upstream requires subtree split steps.
- Repo grows in size.

### Setup & update:
```sh
# Add upstream (or your fork) as a remote
git remote add pkg-upstream https://github.com/original/author/pkg.git
git fetch pkg-upstream

# Add as subtree under third_party/pkg (full history)
git subtree add --prefix third_party/pkg pkg-upstream main --squash
# (--squash reduces noise; omit if you want full history)

# Make local modifications directly inside third_party/pkg, commit normally.

# To pull upstream updates later:
git fetch pkg-upstream
git subtree pull --prefix third_party/pkg pkg-upstream main --squash

# If you maintain a fork and want to push your changes back out:
git remote add pkg-fork https://github.com/yourorg/pkg.git
git subtree push --prefix third_party/pkg pkg-fork main
```

### Best when:
- You want everything in one repo with minimal contributor friction.
- Occasional upstream syncing; not pushing changes upstream daily.

## Actual commands used:

```sh
git remote add MathCAT-origin https://github.com/simpleclub-extended/MathCAT.git
git fetch MathCAT-origin
git subtree add --prefix third_party/MathCAT MathCAT-origin main --squash
```
