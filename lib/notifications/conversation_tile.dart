import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// A round tile with the first letter of [title], for a conversation that
/// has no picture; its colour comes from the title, so it stays the same.
Future<Uint8List?> conversationTile(String title, {int size = 144}) async {
  try {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final half = size / 2;
    canvas.drawCircle(
      ui.Offset(half, half),
      half,
      ui.Paint()..color = tileColor(title),
    );
    final letter = TextPainter(
      text: TextSpan(
        text: tileLetter(title),
        style: TextStyle(
          color: const ui.Color(0xFFFFFFFF),
          fontSize: size * 0.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    letter.paint(
      canvas,
      ui.Offset(half - letter.width / 2, half - letter.height / 2),
    );
    final image = await recorder.endRecording().toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  } on Object {
    return null;
  }
}

/// The letter a tile shows: the first letter or digit of [title], capital.
String tileLetter(String title) {
  final match = RegExp(r'[\p{L}\p{N}]', unicode: true).firstMatch(title);
  return (match?.group(0) ?? '#').toUpperCase();
}

/// One of a few dark, evenly spread colours picked by [title].
ui.Color tileColor(String title) {
  var hash = 0;
  for (final unit in title.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return ui.Color(_tileColors[hash % _tileColors.length]);
}

const _tileColors = [
  0xFF00796B,
  0xFF1565C0,
  0xFF6A1B9A,
  0xFFC2185B,
  0xFFE65100,
  0xFF455A64,
  0xFF2E7D32,
  0xFF8D6E63,
];
