import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// A certificate the user picked to trust for a server, read far enough to
/// show them what it is before they confirm.
@immutable
class CaCertificate {
  const CaCertificate({
    required this.pem,
    required this.subject,
    required this.notBefore,
    required this.notAfter,
    required this.fingerprint,
  });

  /// Every certificate in the file, PEM encoded, as the TLS stack loads it.
  final String pem;

  /// The first certificate's subject, such as `CN=Example Root, O=Example`.
  final String subject;
  final DateTime notBefore;
  final DateTime notAfter;

  /// SHA-256 of the first certificate, colon-separated upper-case hex.
  final String fingerprint;
}

final _pemBlock = RegExp(
  r'-----BEGIN CERTIFICATE-----([\s\S]*?)-----END CERTIFICATE-----',
);

/// Reads a PEM file (one or more certificates) or a single DER certificate;
/// null when [bytes] is neither.
CaCertificate? parseCaCertificate(Uint8List bytes) {
  final ders = <Uint8List>[];
  final text = latin1.decode(bytes, allowInvalid: true);
  final blocks = _pemBlock.allMatches(text).toList();
  try {
    if (blocks.isNotEmpty) {
      for (final block in blocks) {
        ders.add(base64.decode(block[1]!.replaceAll(RegExp(r'\s'), '')));
      }
    } else {
      ders.add(bytes);
    }
    final first = _readCertificate(ders.first);
    return CaCertificate(
      pem: ders.map(_pemOf).join(),
      subject: first.subject,
      notBefore: first.notBefore,
      notAfter: first.notAfter,
      fingerprint: sha256
          .convert(ders.first)
          .bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(':'),
    );
  } on FormatException {
    return null;
  } on RangeError {
    return null;
  }
}

String _pemOf(Uint8List der) {
  final body = base64.encode(der);
  final lines = [
    for (var i = 0; i < body.length; i += 64)
      body.substring(i, i + 64 > body.length ? body.length : i + 64),
  ];
  return '-----BEGIN CERTIFICATE-----\n${lines.join('\n')}\n'
      '-----END CERTIFICATE-----\n';
}

({String subject, DateTime notBefore, DateTime notAfter}) _readCertificate(
  Uint8List der,
) {
  final certificate = _Der(der).read(0x30);
  if (certificate.end != der.length) {
    throw const FormatException('Trailing bytes');
  }
  final tbs = _Der(der, certificate.start, certificate.end).read(0x30);
  final fields = _Der(der, tbs.start, tbs.end);
  if (fields.peek == 0xa0) fields.read(0xa0);
  fields
    ..read(0x02) // serial
    ..read(0x30) // signature algorithm
    ..read(0x30); // issuer
  final validity = fields.read(0x30);
  final subject = fields.read(0x30);
  final times = _Der(der, validity.start, validity.end);
  return (
    subject: _name(der, subject),
    notBefore: _time(der, times.readAny()),
    notAfter: _time(der, times.readAny()),
  );
}

const _attributeNames = {
  '2.5.4.3': 'CN',
  '2.5.4.6': 'C',
  '2.5.4.7': 'L',
  '2.5.4.8': 'ST',
  '2.5.4.10': 'O',
  '2.5.4.11': 'OU',
};

String _name(Uint8List der, _Tlv name) {
  final parts = <String>[];
  final sets = _Der(der, name.start, name.end);
  while (!sets.done) {
    final set = sets.read(0x31);
    final pairs = _Der(der, set.start, set.end);
    while (!pairs.done) {
      final pair = pairs.read(0x30);
      final inner = _Der(der, pair.start, pair.end);
      final oidTlv = inner.read(0x06);
      final oid = _oid(der.sublist(oidTlv.start, oidTlv.end));
      final value = inner.readAny();
      final key = _attributeNames[oid];
      if (key == null) continue;
      final raw = der.sublist(value.start, value.end);
      parts.add('$key=${utf8.decode(raw, allowMalformed: true)}');
    }
  }
  return parts.reversed.join(', ');
}

String _oid(Uint8List bytes) {
  final parts = <int>[bytes[0] ~/ 40, bytes[0] % 40];
  var value = 0;
  for (final b in bytes.skip(1)) {
    value = (value << 7) | (b & 0x7f);
    if (b & 0x80 == 0) {
      parts.add(value);
      value = 0;
    }
  }
  return parts.join('.');
}

DateTime _time(Uint8List der, _Tlv tlv) {
  final s = ascii.decode(der.sublist(tlv.start, tlv.end));
  final digits = switch (tlv.tag) {
    0x17 => '${int.parse(s.substring(0, 2)) < 50 ? '20' : '19'}$s',
    0x18 => s,
    _ => throw const FormatException('Not a time'),
  };
  int at(int i, int n) => int.parse(digits.substring(i, i + n));
  return DateTime.utc(
    at(0, 4),
    at(4, 2),
    at(6, 2),
    at(8, 2),
    at(10, 2),
    at(12, 2),
  );
}

class _Tlv {
  const _Tlv(this.tag, this.start, this.end);
  final int tag;
  final int start;
  final int end;
}

/// Walks DER elements between [position] and [_end].
class _Der {
  _Der(this._bytes, [this.position = 0, int? end])
    : _end = end ?? _bytes.length;

  final Uint8List _bytes;
  int position;
  final int _end;

  bool get done => position >= _end;
  int get peek => _bytes[position];

  _Tlv read(int tag) {
    final tlv = readAny();
    if (tlv.tag != tag) throw const FormatException('Unexpected element');
    return tlv;
  }

  _Tlv readAny() {
    if (done) throw const FormatException('Too short');
    final tag = _bytes[position++];
    var length = _bytes[position++];
    if (length & 0x80 != 0) {
      final count = length & 0x7f;
      if (count == 0 || count > 4) throw const FormatException('Length');
      length = 0;
      for (var i = 0; i < count; i++) {
        length = (length << 8) | _bytes[position++];
      }
    }
    final start = position;
    position += length;
    if (position > _end) throw const FormatException('Too short');
    return _Tlv(tag, start, position);
  }
}
