# Contributing to flutter_majesticons

Thanks for being here. `flutter_majesticons` is a small Flutter package that
turns the free [Majesticons](https://github.com/halfmage/majesticons) icons into
Dart constants. Most of its code is generated, and the guidelines below are
mostly about keeping it that way.

## Ground rules

These are the constraints the package is built around. A change that breaks one
of them will not be merged, however useful it is:

- **The icon artwork comes from upstream.** Icons are never drawn or edited
  here. Requests for new or different icons belong in
  [halfmage/majesticons](https://github.com/halfmage/majesticons).
- **Generated code is never edited by hand.** `lib/src/majesticons.g.dart` is
  produced by `tool/generate.dart`. Change the generator and regenerate.
- **Icons stay `const` and tree-shakeable.** Each icon is a `static const`, so a
  release build only contains the icons the app references.
- **The only dependency is `flutter_svg`.** A new dependency needs a strong
  reason.

## Getting set up

You need Flutter 3.35 or newer and `git`:

```sh
git clone https://github.com/Im-Fran/flutter_majesticons.git
cd flutter_majesticons
flutter pub get
(cd example && flutter pub get)
```

Everyday commands:

| Command | What it does |
| --- | --- |
| `dart format .` | Format the code |
| `flutter analyze` | Analyze the package and the example |
| `flutter test` | Run the tests |
| `dart run tool/generate.dart [tag]` | Regenerate the icons from an upstream tag (needs `git` and network) |
| `cd example && flutter run -d chrome` | Run the icon gallery |
| `dart pub publish --dry-run` | Check what would be published |

CI runs the format check, `flutter analyze`, `flutter test` and a publish dry
run, so all of them must pass before a PR can land.

## Where things live

```
lib/flutter_majesticons.dart    Majesticon widget and MajesticonData
lib/src/majesticons.g.dart      generated: icons, categories, majesticons list
tool/generate.dart              downloads the SVGs, categorizes them, generates the code
test/                           widget tests, the generated icons and the naming rules
example/                        web gallery of every icon, one tab per category
```

## Updating the icons

`dart run tool/generate.dart` clones the upstream tag, reads the category of
each icon from majesticons.com (the upstream repository has none), and rewrites
`lib/src/majesticons.g.dart`. The output is deterministic, so running it twice
produces no diff.

If it stops with a list of icons, those have no category (or more than one) on
majesticons.com. Add them to `_categoryOverrides` in `tool/generate.dart`.

## Branches and commits

Branch off `dev`, which is the default branch:

```sh
git checkout dev && git pull
git checkout -b feat/search-by-category
```

Commits follow [Conventional Commits](https://www.conventionalcommits.org),
written in the imperative. PRs are squash-merged, so the PR title becomes the
commit message:

```
feat: add a semanticLabel default for icon-only buttons
fix(tool): fail when two icons map to the same identifier
docs: explain how categories are resolved
```

Common types here: `feat`, `fix`, `refactor`, `docs`, `test`, `build`, `ci`,
`chore`.

## Opening a pull request

1. Make sure format, analysis and tests pass.
2. Push your branch and open a PR against `dev`.
3. Fill in the PR template, and attach screenshots for anything visual, in light
   and dark mode.
4. Keep the PR focused. Unrelated cleanups belong in their own PR.

## Releasing (maintainers)

1. Bump `version` in `pubspec.yaml` and add its entry to `CHANGELOG.md`, in a PR.
2. Tag the merge commit without a `v` prefix: `git tag 1.2.3 && git push origin 1.2.3`.
3. The tag runs CI and then waits for approval of the `pub.dev` environment.
   Approve it from the workflow run page to publish.

## Reporting bugs and requesting features

Use the [issue templates](https://github.com/Im-Fran/flutter_majesticons/issues/new/choose).
A minimal snippet that reproduces the problem, with the icon you used, is what
makes the difference between a guess and a fix.

Security vulnerabilities go through [SECURITY.md](SECURITY.md) instead, never a
public issue.

## Code of Conduct

Taking part in this project means following the
[Code of Conduct](CODE_OF_CONDUCT.md).
