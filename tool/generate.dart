// Generates lib/src/majesticons.g.dart from the upstream Majesticons repository.
//
//   dart run tool/generate.dart [tag]
//
// The SVGs come from a shallow git clone of the tag. Upstream has no
// categories, so they are read from the category pages of majesticons.com.
import 'dart:convert';
import 'dart:io';

const _repo = 'https://github.com/halfmage/majesticons';
const _rawBase = 'https://raw.githubusercontent.com/halfmage/majesticons';
const _site = 'https://majesticons.com';
const _defaultTag = 'v2.1.3';

/// Free icons that majesticons.com does not list under their repo name.
const _categoryOverrides = {
  'battery-full': 'interface',
  'battery-half': 'interface',
  'image-photography': 'photography',
  'leaf-3-angled': 'nature',
  'view-columns': 'layout',
  'view-rows': 'layout',
};

/// Identifiers a generated static member or enum value cannot use: Dart
/// reserved words plus members inherited from Object and Enum.
const _reserved = {
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
  'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
  'in', 'is', 'new', 'null', 'rethrow', 'return', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'var', 'void', 'while', 'with', //
  'hashCode', 'runtimeType', 'toString', 'noSuchMethod', 'values', 'index',
  'name',
};

Future<void> main(List<String> args) async {
  final tag = args.isEmpty ? _defaultTag : args.first;
  final tmp = await Directory.systemTemp.createTemp('majesticons_');
  try {
    final (line, solid) = await _cloneSvgs(tag, tmp);
    final categories = await _categorize(line.keys.toSet());
    final out = File.fromUri(
      Platform.script.resolve('../lib/src/majesticons.g.dart'),
    );
    out.parent.createSync(recursive: true);
    out.writeAsStringSync(_generate(tag, line, solid, categories));
    final fmt = await Process.run(Platform.resolvedExecutable, [
      'format',
      out.path,
    ]);
    if (fmt.exitCode != 0) _fail('dart format failed:\n${fmt.stderr}');
    stdout.writeln(
      'Wrote ${out.path}: ${line.length} icons x 2 styles, '
      '${categories.values.toSet().length} categories ($tag).',
    );
  } on StateError catch (e) {
    stderr.writeln('error: ${e.message}');
    exitCode = 1;
  } finally {
    await tmp.delete(recursive: true);
  }
}

Never _fail(String message) => throw StateError(message);

/// `airplane-flight-2` -> `airplaneFlight2`, `t-shirt` -> `tShirt`.
String dartName(String name) {
  final parts = name.split(RegExp('[^a-zA-Z0-9]+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) _fail('Cannot derive an identifier from "$name".');
  var id =
      parts.first.toLowerCase() +
      parts
          .skip(1)
          .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
          .join();
  if (RegExp('^[0-9]').hasMatch(id)) id = 'i$id';
  return _reserved.contains(id) ? '${id}Icon' : id;
}

/// `dartName` for every name, failing if two collapse into the same identifier.
Map<String, String> _identifiers(Iterable<String> names) {
  final ids = <String, String>{};
  for (final name in names) {
    final id = dartName(name);
    final clash = ids.entries.where((e) => e.value == id);
    if (clash.isNotEmpty) {
      _fail('"$name" and "${clash.first.key}" both map to `$id`.');
    }
    ids[name] = id;
  }
  return ids;
}

String _label(String slug) =>
    slug.split('-').map((p) => p[0].toUpperCase() + p.substring(1)).join(' ');

/// Returns `name -> svg` for the line and solid styles of [tag].
Future<(Map<String, String>, Map<String, String>)> _cloneSvgs(
  String tag,
  Directory tmp,
) async {
  final git = await Process.run('git', [
    'clone',
    '--quiet',
    '--depth',
    '1',
    '--branch',
    tag,
    _repo,
    tmp.path,
  ]);
  if (git.exitCode != 0) {
    _fail('git clone of $_repo@$tag failed:\n${git.stderr}');
  }

  Map<String, String> read(String dir, String suffix) => {
    for (final f in Directory('${tmp.path}/$dir').listSync().whereType<File>())
      if (f.path.endsWith(suffix))
        f.uri.pathSegments.last.substring(
          0,
          f.uri.pathSegments.last.length - suffix.length,
        ): f
            .readAsStringSync()
            .trim(),
  };

  final line = read('line', '-line.svg');
  final solid = read('solid', '.svg');
  final mismatch = line.keys
      .toSet()
      .difference(solid.keys.toSet())
      .followedBy(solid.keys.toSet().difference(line.keys.toSet()));
  if (line.isEmpty || mismatch.isNotEmpty) {
    _fail(
      'line/ and solid/ do not hold the same icons: ${mismatch.join(', ')}',
    );
  }
  for (final MapEntry(:key, :value) in [...line.entries, ...solid.entries]) {
    // Emitted as single-line raw strings.
    if (value.contains("'") || value.contains('\n')) {
      _fail('$key: SVG contains a quote or newline.');
    }
  }
  return (line, solid);
}

/// Returns `icon name -> category slug`, failing on icons without exactly one.
Future<Map<String, String>> _categorize(Set<String> icons) async {
  final client = HttpClient();
  try {
    Future<String> get(String path) async {
      final res = await (await client.getUrl(Uri.parse('$_site$path'))).close();
      if (res.statusCode != 200) {
        _fail('GET $_site$path returned ${res.statusCode}.');
      }
      return res.transform(utf8.decoder).join();
    }

    final slugs = {
      for (final m in RegExp(
        'categories/([a-z0-9-]+)',
      ).allMatches(await get('/categories')))
        m[1]!,
    };
    if (slugs.isEmpty) _fail('No categories found at $_site/categories.');

    final found = <String, Set<String>>{};
    await Future.wait(
      slugs.map((slug) async {
        for (final m in RegExp(
          'icons/([a-z0-9-]+)',
        ).allMatches(await get('/categories/$slug'))) {
          if (icons.contains(m[1])) (found[m[1]!] ??= {}).add(slug);
        }
      }),
    );

    final missing = <String>[], ambiguous = <String>[];
    final result = <String, String>{};
    for (final icon in icons) {
      final cats = found[icon] ?? {?_categoryOverrides[icon]};
      if (cats.isEmpty) {
        missing.add(icon);
      } else if (cats.length > 1) {
        ambiguous.add('$icon (${cats.join(', ')})');
      } else {
        result[icon] = cats.single;
      }
    }
    if (missing.isNotEmpty || ambiguous.isNotEmpty) {
      _fail(
        'Add an entry to _categoryOverrides for:\n'
        '  no category: ${missing.join(', ')}\n  several categories: ${ambiguous.join(', ')}',
      );
    }
    return result;
  } finally {
    client.close();
  }
}

String _generate(
  String tag,
  Map<String, String> line,
  Map<String, String> solid,
  Map<String, String> category,
) {
  final names = line.keys.toList()..sort();
  final ids = _identifiers(names);
  final slugs = category.values.toSet().toList()..sort();
  final slugIds = _identifiers(slugs);

  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Regenerate with: dart run tool/generate.dart')
    ..writeln(
      '// Source: $_repo @ $tag (MIT, Copyright (c) 2021 Gerrit Halfmann)',
    )
    ..writeln()
    ..writeln("part of '../flutter_majesticons.dart';")
    ..writeln()
    ..writeln('/// Icon categories, as grouped on majesticons.com.')
    ..writeln('enum MajesticonCategory {');
  for (final slug in slugs) {
    b.writeln("/// ${_label(slug)}\n${slugIds[slug]}('${_label(slug)}'),");
  }
  b
    ..writeln(';')
    ..writeln()
    ..writeln('const MajesticonCategory(this.label);')
    ..writeln()
    ..writeln('/// Human readable name of the category.')
    ..writeln('final String label;')
    ..writeln('}')
    ..writeln();

  for (final (cls, style, dir, suffix, svgs) in [
    ('MajesticonsLine', 'line', 'line', '-line', line),
    ('MajesticonsSolid', 'solid', 'solid', '', solid),
  ]) {
    b
      ..writeln('/// The ${names.length} Majesticons in the $style style.')
      ..writeln('///')
      ..writeln(
        '/// Pass them to [Majesticon]. Unused icons are tree-shaken from release builds.',
      )
      ..writeln('abstract final class $cls {');
    for (final n in names) {
      b
        ..writeln('/// `$n` in [MajesticonCategory.${slugIds[category[n]]}].')
        ..writeln('///')
        ..writeln('/// ![$n]($_rawBase/$tag/$dir/$n$suffix.svg)')
        ..writeln("static const ${ids[n]} = MajesticonData(r'${svgs[n]}');")
        ..writeln();
    }
    b
      ..writeln('}')
      ..writeln();
  }

  b
    ..writeln('/// An icon in both styles together with its category.')
    ..writeln('typedef MajesticonEntry = ({')
    ..writeln('String name,')
    ..writeln('MajesticonCategory category,')
    ..writeln('MajesticonData line,')
    ..writeln('MajesticonData solid,')
    ..writeln('});')
    ..writeln()
    ..writeln('/// Every icon with its category, for galleries and search.')
    ..writeln('///')
    ..writeln(
      '/// Referencing this list keeps **all** icons in your build. To ship only the',
    )
    ..writeln(
      '/// ones you use, reference [MajesticonsLine] and [MajesticonsSolid] directly.',
    )
    ..writeln('const List<MajesticonEntry> majesticons = [');
  for (final n in names) {
    b.writeln(
      "(name: '$n', category: MajesticonCategory.${slugIds[category[n]]}, "
      'line: MajesticonsLine.${ids[n]}, solid: MajesticonsSolid.${ids[n]}),',
    );
  }
  b.writeln('];');
  return b.toString();
}
