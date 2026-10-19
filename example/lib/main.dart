import 'package:flutter/material.dart';
import 'package:flutter_majesticons/flutter_majesticons.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Majesticons',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const Gallery(),
    );
  }
}

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  bool _solid = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: MajesticonCategory.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Majesticons'),
          actions: [
            const Text('Solid'),
            Switch(
              value: _solid,
              onChanged: (value) => setState(() => _solid = value),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final c in MajesticonCategory.values) Tab(text: c.label),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final category in MajesticonCategory.values)
              _CategoryGrid(
                entries: majesticons.where((e) => e.category == category),
                solid: _solid,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.entries, required this.solid});

  final Iterable<MajesticonEntry> entries;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final items = entries.toList();
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 128,
        mainAxisExtent: 96,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final e = items[i];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Majesticon(
              solid ? e.solid : e.line,
              size: 32,
              semanticLabel: e.name,
            ),
            const SizedBox(height: 8),
            Text(
              e.name,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
