import 'dart:convert';
import 'dart:typed_data';

/// The part of MessagePack the Calls protocol uses: writing maps, strings,
/// unsigned integers and binary.
class PackWriter {
  final _bytes = BytesBuilder(copy: false);

  Uint8List takeBytes() => _bytes.takeBytes();

  void writeUint(int value) {
    if (value < 0) throw ArgumentError.value(value, 'value', 'negative');
    if (value < 0x80) {
      _bytes.addByte(value);
    } else if (value <= 0xff) {
      _bytes
        ..addByte(0xcc)
        ..addByte(value);
    } else if (value <= 0xffff) {
      _bytes
        ..addByte(0xcd)
        ..add(_bigEndian(value, 2));
    } else {
      _bytes
        ..addByte(0xce)
        ..add(_bigEndian(value, 4));
    }
  }

  void writeString(String value) {
    final bytes = utf8.encode(value);
    final n = bytes.length;
    if (n < 32) {
      _bytes.addByte(0xa0 | n);
    } else if (n <= 0xff) {
      _bytes
        ..addByte(0xd9)
        ..addByte(n);
    } else if (n <= 0xffff) {
      _bytes
        ..addByte(0xda)
        ..add(_bigEndian(n, 2));
    } else {
      _bytes
        ..addByte(0xdb)
        ..add(_bigEndian(n, 4));
    }
    _bytes.add(bytes);
  }

  void writeBin(List<int> value) {
    final n = value.length;
    if (n <= 0xff) {
      _bytes
        ..addByte(0xc4)
        ..addByte(n);
    } else if (n <= 0xffff) {
      _bytes
        ..addByte(0xc5)
        ..add(_bigEndian(n, 2));
    } else {
      _bytes
        ..addByte(0xc6)
        ..add(_bigEndian(n, 4));
    }
    _bytes.add(value);
  }

  void writeMapHeader(int entries) {
    if (entries < 16) {
      _bytes.addByte(0x80 | entries);
    } else {
      _bytes
        ..addByte(0xde)
        ..add(_bigEndian(entries, 2));
    }
  }

  static Uint8List _bigEndian(int value, int width) {
    final out = Uint8List(width);
    for (var i = width - 1; i >= 0; i--) {
      out[i] = value & 0xff;
      value >>= 8;
    }
    return out;
  }
}

/// Reads MessagePack values one after another from [bytes]; the one-byte
/// and the wider forms of a number read the same.
class PackReader {
  PackReader(this.bytes) : _data = ByteData.sublistView(bytes);

  final Uint8List bytes;
  final ByteData _data;
  var _at = 0;

  bool get atEnd => _at >= bytes.length;

  /// A map becomes a `Map<String, Object?>`, an array a `List<Object?>`,
  /// binary a [Uint8List], numbers `int` or `double`.
  Object? read() {
    final tag = _byte();
    if (tag < 0x80) return tag;
    if (tag >= 0xe0) return tag - 256;
    if (tag >= 0xa0 && tag <= 0xbf) return _string(tag & 0x1f);
    if (tag >= 0x80 && tag <= 0x8f) return _map(tag & 0x0f);
    if (tag >= 0x90 && tag <= 0x9f) return _array(tag & 0x0f);
    return switch (tag) {
      0xc0 => null,
      0xc2 => false,
      0xc3 => true,
      0xc4 => _bin(_uint(1)),
      0xc5 => _bin(_uint(2)),
      0xc6 => _bin(_uint(4)),
      0xca => _float(4),
      0xcb => _float(8),
      0xcc => _uint(1),
      0xcd => _uint(2),
      0xce => _uint(4),
      0xcf => _uint(8),
      0xd0 => _int(1),
      0xd1 => _int(2),
      0xd2 => _int(4),
      0xd3 => _int(8),
      0xd9 => _string(_uint(1)),
      0xda => _string(_uint(2)),
      0xdb => _string(_uint(4)),
      0xdc => _array(_uint(2)),
      0xdd => _array(_uint(4)),
      0xde => _map(_uint(2)),
      0xdf => _map(_uint(4)),
      _ => throw FormatException('Unsupported MessagePack tag $tag'),
    };
  }

  int _byte() {
    if (_at >= bytes.length) throw const FormatException('Truncated');
    return bytes[_at++];
  }

  void _need(int n) {
    if (_at + n > bytes.length) throw const FormatException('Truncated');
  }

  int _uint(int width) {
    _need(width);
    final v = switch (width) {
      1 => _data.getUint8(_at),
      2 => _data.getUint16(_at),
      4 => _data.getUint32(_at),
      _ => _data.getUint64(_at),
    };
    _at += width;
    return v;
  }

  int _int(int width) {
    _need(width);
    final v = switch (width) {
      1 => _data.getInt8(_at),
      2 => _data.getInt16(_at),
      4 => _data.getInt32(_at),
      _ => _data.getInt64(_at),
    };
    _at += width;
    return v;
  }

  double _float(int width) {
    _need(width);
    final v = width == 4 ? _data.getFloat32(_at) : _data.getFloat64(_at);
    _at += width;
    return v;
  }

  Uint8List _bin(int n) {
    _need(n);
    final out = Uint8List.sublistView(bytes, _at, _at + n);
    _at += n;
    return out;
  }

  String _string(int n) => utf8.decode(_bin(n), allowMalformed: true);

  List<Object?> _array(int n) => [for (var i = 0; i < n; i++) read()];

  Map<String, Object?> _map(int n) {
    final out = <String, Object?>{};
    for (var i = 0; i < n; i++) {
      final key = read();
      final value = read();
      if (key is String) out[key] = value;
    }
    return out;
  }
}
