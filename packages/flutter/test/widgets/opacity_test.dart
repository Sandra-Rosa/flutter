// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is run as part of a reduced test set in CI on Mac and Windows
// machines.
@Tags(<String>['reduced-test-set'])

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../rendering/mock_canvas.dart';
import 'semantics_tester.dart';

void main() {
  testWidgets('Opacity', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    // Opacity 1.0: Semantics and painting
    await tester.pumpWidget(
      const Opacity(
        opacity: 1.0,
        child: Text('a', textDirection: TextDirection.rtl),
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paints..paragraph());

    // Opacity 0.0: Nothing
    await tester.pumpWidget(
      const Opacity(
        opacity: 0.0,
        child: Text('a', textDirection: TextDirection.rtl),
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(),
    ));
    expect(find.byType(Opacity), paintsNothing);

    // Opacity 0.0 with semantics: Just semantics
    await tester.pumpWidget(
      const Opacity(
        opacity: 0.0,
        alwaysIncludeSemantics: true,
        child: Text('a', textDirection: TextDirection.rtl),
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paintsNothing);

    // Opacity 0.0 without semantics: Nothing
    await tester.pumpWidget(
      const Opacity(
        opacity: 0.0,
        alwaysIncludeSemantics: false,
        child: Text('a', textDirection: TextDirection.rtl),
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(),
    ));
    expect(find.byType(Opacity), paintsNothing);

    // Opacity 0.1: Semantics and painting
    await tester.pumpWidget(
      const Opacity(
        opacity: 0.1,
        child: Text('a', textDirection: TextDirection.rtl),
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paints..paragraph());

    // Opacity 0.1 without semantics: Still has semantics and painting
    await tester.pumpWidget(
      const Opacity(
        opacity: 0.1,
        alwaysIncludeSemantics: false,
        child: Text('a', textDirection: TextDirection.rtl),
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paints..paragraph());

    // Opacity 0.1 with semantics: Semantics and painting
    await tester.pumpWidget(
      const Opacity(
        opacity: 0.1,
        alwaysIncludeSemantics: true,
        child: Text('a', textDirection: TextDirection.rtl),
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paints..paragraph());

    semantics.dispose();
  });

  testWidgets('offset is correctly handled in Opacity', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List<Widget>.generate(10, (int index) {
                  return Opacity(
                    opacity: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                          color: Colors.blue,
                          height: 50,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('opacity_test.offset.png'),
    );
  });

  testWidgets('empty opacity does not crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      RepaintBoundary(child: Opacity(opacity: 0.5, child: Container())),
    );
    final Element element = find.byType(RepaintBoundary).first.evaluate().single;
    // The following line will send the layer to engine and cause crash if an
    // empty opacity layer is sent.
    final OffsetLayer offsetLayer = element.renderObject!.debugLayer! as OffsetLayer;
    await offsetLayer.toImage(const Rect.fromLTRB(0.0, 0.0, 1.0, 1.0));
  }, skip: isBrowser); // https://github.com/flutter/flutter/issues/49857
}
