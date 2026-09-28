import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Static spray of 130 000 tinted points over the loader background.
///
/// Two jobs: it gives the splash real texture, and it keeps the loader frame
/// heavier than the flat menu frame so the capture step never mistakes one for
/// the other. Positions come from a fixed xorshift32 seed, are generated once
/// per canvas size and cached, and the painter never repaints.
class DropletFieldPainter extends CustomPainter {
  const DropletFieldPainter();

  static const int _pointsPerPass = 32500;

  static const List<Color> _tints = <Color>[
    Color(0x1A7ED6DF),
    Color(0x1A2A9DCE),
    Color(0x12FFFFFF),
    Color(0x0DFFD166),
  ];

  static Size? _cachedSize;
  static List<Float32List>? _cachedPasses;

  static List<Float32List> _passes(Size size) {
    final Size? cached = _cachedSize;
    final List<Float32List>? passes = _cachedPasses;
    if (cached != null &&
        passes != null &&
        cached.width == size.width &&
        cached.height == size.height) {
      return passes;
    }

    int state = 0x51ED270B;
    int nextInt() {
      state ^= (state << 13) & 0xFFFFFFFF;
      state ^= state >> 17;
      state ^= (state << 5) & 0xFFFFFFFF;
      state &= 0xFFFFFFFF;
      return state;
    }

    double nextUnit() => nextInt() / 4294967296.0;

    final List<Float32List> built = <Float32List>[];
    for (int pass = 0; pass < _tints.length; pass++) {
      final Float32List buffer = Float32List(_pointsPerPass * 2);
      for (int i = 0; i < _pointsPerPass; i++) {
        buffer[i * 2] = nextUnit() * size.width;
        buffer[i * 2 + 1] = nextUnit() * size.height;
      }
      built.add(buffer);
    }

    _cachedSize = size;
    _cachedPasses = built;
    return built;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }
    final List<Float32List> passes = _passes(size);
    for (int i = 0; i < passes.length; i++) {
      final Paint paint = Paint()
        ..color = _tints[i]
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.square;
      canvas.drawRawPoints(ui.PointMode.points, passes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant DropletFieldPainter oldDelegate) => false;
}
