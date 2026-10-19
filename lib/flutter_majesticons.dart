/// Majesticons for Flutter: line and solid SVG icons, grouped by category.
///
/// ```dart
/// Majesticon(MajesticonsLine.airplane)
/// ```
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'src/majesticons.g.dart';

/// The SVG source of a Majesticons icon, as found in [MajesticonsLine] and
/// [MajesticonsSolid].
extension type const MajesticonData(String svg) {}

/// A Majesticons icon, sized and colored like Flutter's [Icon]: [size] and
/// [color] default to the ambient [IconTheme].
class Majesticon extends StatelessWidget {
  /// Creates an icon from [MajesticonsLine] or [MajesticonsSolid].
  const Majesticon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// The icon to draw, e.g. `MajesticonsLine.airplane`.
  final MajesticonData icon;

  /// Width and height of the icon. Defaults to [IconThemeData.size].
  final double? size;

  /// Color of the icon. Defaults to [IconThemeData.color].
  final Color? color;

  /// Label read by screen readers. The icon is excluded from semantics when
  /// null, as with [Icon].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = this.size ?? theme.size ?? 24;
    var color = this.color ?? theme.color!;
    final opacity = theme.opacity ?? 1;
    if (opacity != 1) color = color.withValues(alpha: color.a * opacity);

    // srcIn tints the picture at paint time, so each SVG is parsed only once
    // no matter how many colors it is drawn with.
    return SvgPicture.string(
      icon.svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
