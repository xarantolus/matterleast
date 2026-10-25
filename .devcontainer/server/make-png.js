// Writes a small PNG: a solid square of the given colour with a lighter inner
// square. Used for invented avatars, custom emoji and image attachments.
//   node make-png.js <out.png> <rrggbb> [size]
const fs = require('fs');
const zlib = require('zlib');

const [out, hex, sizeArg] = process.argv.slice(2);
const size = Number(sizeArg || 128);
const [r, g, b] = [0, 2, 4].map((i) => parseInt(hex.slice(i, i + 2), 16));
const inner = [r, g, b].map((c) => Math.min(255, c + 90));

const rows = [];
for (let y = 0; y < size; y++) {
  const row = Buffer.alloc(1 + size * 3);
  for (let x = 0; x < size; x++) {
    const edge = size / 4;
    const isInner = x > edge && x < size - edge && y > edge && y < size - edge;
    const [pr, pg, pb] = isInner ? inner : [r, g, b];
    row.writeUInt8(pr, 1 + x * 3);
    row.writeUInt8(pg, 2 + x * 3);
    row.writeUInt8(pb, 3 + x * 3);
  }
  rows.push(row);
}

const crcTable = Array.from({ length: 256 }, (_, n) => {
  let c = n;
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  return c >>> 0;
});
function crc32(buf) {
  let c = 0xffffffff;
  for (const byte of buf) c = crcTable[(c ^ byte) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}
function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const body = Buffer.concat([Buffer.from(type, 'ascii'), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(body));
  return Buffer.concat([len, body, crc]);
}

const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(size, 0);
ihdr.writeUInt32BE(size, 4);
ihdr.writeUInt8(8, 8); // bit depth
ihdr.writeUInt8(2, 9); // colour type: RGB
const png = Buffer.concat([
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  chunk('IHDR', ihdr),
  chunk('IDAT', zlib.deflateSync(Buffer.concat(rows))),
  chunk('IEND', Buffer.alloc(0)),
]);
fs.writeFileSync(out, png);
