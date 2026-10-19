import 'package:flutter/material.dart';
import 'package:flutter_majesticons/flutter_majesticons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/generate.dart' show dartName;

SvgPicture _picture(WidgetTester tester) =>
    tester.widget<SvgPicture>(find.byType(SvgPicture));

void main() {
  group('Majesticon', () {
    testWidgets('inherits size, color and opacity from IconTheme', (
      tester,
    ) async {
      await tester.pumpWidget(
        const IconTheme(
          data: IconThemeData(size: 40, color: Color(0xFF123456), opacity: 0.5),
          child: Majesticon(MajesticonsLine.airplane),
        ),
      );
      final picture = _picture(tester);
      expect(picture.width, 40);
      expect(picture.height, 40);
      expect(
        picture.colorFilter,
        ColorFilter.mode(
          const Color(0xFF123456).withValues(alpha: 0.5),
          BlendMode.srcIn,
        ),
      );
    });

    testWidgets('explicit size and color win over IconTheme', (tester) async {
      await tester.pumpWidget(
        const IconTheme(
          data: IconThemeData(size: 40, color: Color(0xFF123456)),
          child: Majesticon(
            MajesticonsSolid.airplane,
            size: 16,
            color: Color(0xFFFF0000),
          ),
        ),
      );
      final picture = _picture(tester);
      expect(picture.width, 16);
      expect(
        picture.colorFilter,
        const ColorFilter.mode(Color(0xFFFF0000), BlendMode.srcIn),
      );
    });

    testWidgets('is excluded from semantics unless labeled', (tester) async {
      await tester.pumpWidget(const Majesticon(MajesticonsLine.airplane));
      expect(_picture(tester).excludeFromSemantics, isTrue);

      await tester.pumpWidget(
        const Majesticon(MajesticonsLine.airplane, semanticLabel: 'Flights'),
      );
      expect(_picture(tester).excludeFromSemantics, isFalse);
      expect(_picture(tester).semanticsLabel, 'Flights');
    });
  });

  group('generated icons', () {
    test('cover every icon in both styles and every category', () {
      expect(majesticons, hasLength(380));
      expect(
        majesticons.map((e) => e.category).toSet(),
        MajesticonCategory.values.toSet(),
      );
    });

    testWidgets('all SVGs parse', (tester) async {
      await tester.runAsync(() async {
        for (final e in majesticons) {
          for (final icon in [e.line, e.solid]) {
            await SvgStringLoader(icon.svg).loadBytes(null);
          }
        }
      });
    });
  });

  group('dartName', () {
    test('converts kebab-case to lowerCamelCase', () {
      expect(dartName('airplane'), 'airplane');
      expect(dartName('airplane-flight-2'), 'airplaneFlight2');
      expect(dartName('t-shirt'), 'tShirt');
    });

    test('avoids leading digits and reserved names', () {
      expect(dartName('2g-circle'), 'i2gCircle');
      expect(dartName('class'), 'classIcon');
      expect(dartName('hash-code'), 'hashCodeIcon');
    });
  });
}
