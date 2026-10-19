<div align="center">

# flutter_majesticons

**Majesticons for Flutter: 380 line and solid SVG icons, grouped by category and generated from the official repository.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

</div>

---

## Description

[Majesticons](https://majesticons.com) is a set of hand-drawn icons on a 24×24 grid. `flutter_majesticons` brings the free icons from the [halfmage/majesticons](https://github.com/halfmage/majesticons) repository to Flutter as ready-to-use constants and a `Majesticon` widget that behaves like Flutter's own `Icon`.

The code is not written by hand: `tool/generate.dart` downloads the SVGs from GitHub, groups them into the categories used on majesticons.com and generates every icon constant. Updating to a new upstream release is one command.

## Features

- **380 icons in two styles** — `MajesticonsLine` and `MajesticonsSolid`, 760 `const` icons in total.
- **Works like `Icon`** — `Majesticon` takes its size, color and opacity from the ambient `IconTheme`, and is excluded from semantics unless you give it a `semanticLabel`.
- **Tree-shakeable** — each icon is a `static const`, so only the icons you reference end up in a release build.
- **47 categories** — `MajesticonCategory` and the `majesticons` list let you build galleries and search without maintaining your own index.
- **Documented in the IDE** — every constant has a doc comment with its category and a preview image.
- **Regenerable** — one script rebuilds everything from any upstream tag.

## Requirements

- Flutter `>=3.35.0`
- Dart `^3.9.0`

Icons are rendered with [`flutter_svg`](https://pub.dev/packages/flutter_svg), which is pulled in automatically.

## Installation

```bash
flutter pub add flutter_majesticons
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_majesticons/flutter_majesticons.dart';

const Majesticon(MajesticonsLine.airplane);

const Majesticon(
  MajesticonsSolid.airplane,
  size: 32,
  color: Colors.red,
  semanticLabel: 'Flights',
);

IconButton(
  icon: const Majesticon(MajesticonsLine.search),
  onPressed: () {},
);
```

Without `size` or `color`, the icon uses the ambient `IconTheme`, so it follows the icon theme set by widgets such as `IconButton` and `AppBar`.

### Icon names

Icon names are the upstream file names in camelCase: `airplane-flight-2` is `MajesticonsLine.airplaneFlight2` and `t-shirt` is `MajesticonsSolid.tShirt`. Every icon exists in both styles with the same name.

### Browsing by category

`majesticons` is a list with every icon in both styles and its category:

```dart
final vehicles = majesticons.where((e) => e.category == MajesticonCategory.vehicles);

for (final e in vehicles) {
  print('${e.name} (${e.category.label})');
  // e.line and e.solid are ready to pass to Majesticon
}
```

> Referencing `majesticons` keeps **all** icons in your build, because the list points to every one of them. If you only need a few icons, reference them directly through `MajesticonsLine` and `MajesticonsSolid`.

The categories are: Arrows, Astronomy, Bags, Bookmarks, Books, Buildings, Calendar, Charts, Clipboard, Clothing, Clouds, Connectivity, Currency, Database, Development, Devices, Editor, Files, Finances, Folders, Food, Hands, Images, Interface, Interior, Layout, Mail, Maps, Math, Media, Medical, Messaging, Nature, Notes, Photography, Scans, Science, Security, Shopping, Tables, Telecom, Textboxes, Tickets, Time, Users, Vehicles and Video.

### Example app

[`example/`](example) is a gallery of every icon with one tab per category and a line/solid switch. It targets the web:

```bash
cd example
flutter run -d chrome
```

## Updating the icons

`lib/src/majesticons.g.dart` is generated. Do not edit it by hand; regenerate it instead:

```bash
dart run tool/generate.dart          # Majesticons v2.1.3
dart run tool/generate.dart v2.1.3   # any upstream tag
```

The script needs `git` and network access. It:

1. Clones the given tag of `halfmage/majesticons` and reads `line/` and `solid/`.
2. Reads the category of each icon from the category pages of majesticons.com, since the upstream repository has no categories.
3. Writes `lib/src/majesticons.g.dart` and formats it.

It fails with a list of names instead of guessing if an icon has no category, has more than one, or if two icons map to the same Dart identifier. For an icon missing from majesticons.com, add it to `_categoryOverrides` in `tool/generate.dart`.

## Tests

```bash
flutter test
```

The tests cover the widget (theme inheritance, explicit overrides, semantics), check that all 760 SVGs parse, and check the icon-to-identifier naming used by the generator.

## Contributing

Issues and pull requests are welcome. Icon artwork comes from upstream, so changes to the icons themselves belong in [halfmage/majesticons](https://github.com/halfmage/majesticons). Setup, commands and the pull request flow are in [CONTRIBUTING.md](.github/CONTRIBUTING.md), and everyone taking part follows the [Code of Conduct](.github/CODE_OF_CONDUCT.md).

## Security

Please report vulnerabilities privately instead of opening a public issue. See [SECURITY.md](.github/SECURITY.md).

## License

Distributed under the MIT license, see [LICENSE](LICENSE).

The icons are © Gerrit Halfmann, published under the MIT license in [halfmage/majesticons](https://github.com/halfmage/majesticons). This package only includes the 380 free icons from that repository; the full set at [majesticons.com](https://majesticons.com) is not included.

---

<div align="center">
  <a href="https://franciscosolis.cl">
    <img src="https://cdn.franciscosolis.cl/brand/svg/fs-mark.svg" alt="FranciscoSolis E.I.R.L." width="40" height="40">
  </a>
  <br>
  <sub>Built by <a href="https://franciscosolis.cl"><strong>FranciscoSolis E.I.R.L.</strong></a></sub>
  <br>
  <sub>© 2026 FranciscoSolis E.I.R.L. — MIT</sub>
</div>
