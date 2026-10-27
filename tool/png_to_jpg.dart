// Converts a PNG to a JPEG, but leaves an existing JPEG alone when the new
// screenshot looks the same (JPEG noise is ignored):
//   dart run tool/png_to_jpg.dart <in.png> <out.jpg> [quality]
// Prints "changed" or "unchanged".
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _channelTolerance = 40;
const _changedShare = 0.001;

void main(List<String> args) {
  final image = img.decodePng(File(args[0]).readAsBytesSync());
  if (image == null) {
    stderr.writeln('not a PNG: ${args[0]}');
    exit(1);
  }
  final quality = args.length > 2 ? int.parse(args[2]) : 85;
  final out = File(args[1]);
  if (out.existsSync()) {
    final old = img.decodeJpg(out.readAsBytesSync());
    if (old != null && _looksSame(old, image)) {
      stdout.writeln('unchanged');
      return;
    }
  }
  out.writeAsBytesSync(img.encodeJpg(image, quality: quality));
  stdout.writeln('changed');
}

bool _looksSame(img.Image a, img.Image b) {
  if (a.width != b.width || a.height != b.height) return false;
  var different = 0;
  for (final pa in a) {
    final pb = b.getPixel(pa.x, pa.y);
    final delta = math.max(
      (pa.r - pb.r).abs(),
      math.max((pa.g - pb.g).abs(), (pa.b - pb.b).abs()),
    );
    if (delta > _channelTolerance) different++;
  }
  return different / (a.width * a.height) <= _changedShare;
}
