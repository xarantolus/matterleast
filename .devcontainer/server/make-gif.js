// Writes a small animated GIF that blinks between two colours, for a GIF
// attachment in the seed.
//   node make-gif.js <out.gif> <rrggbb> <rrggbb> [size]
const fs = require('fs');

const [out, a, b, sizeArg] = process.argv.slice(2);
const size = Number(sizeArg || 96);
const rgb = (hex) => [0, 2, 4].map((i) => parseInt(hex.slice(i, i + 2), 16));

// Two-colour palette; each frame is filled with one index. The LZW stream
// sends a clear code before every 250 literals so codes stay 9 bits wide
// and need no dictionary.
function frame(index) {
  const codes = [];
  for (let i = 0; i < size * size; i++) {
    if (i % 250 === 0) codes.push(256);
    codes.push(index);
  }
  codes.push(257);
  const bytes = [];
  let acc = 0;
  let bits = 0;
  for (const code of codes) {
    acc |= code << bits;
    bits += 9;
    while (bits >= 8) {
      bytes.push(acc & 0xff);
      acc >>= 8;
      bits -= 8;
    }
  }
  if (bits > 0) bytes.push(acc & 0xff);
  const blocks = [];
  for (let i = 0; i < bytes.length; i += 255) {
    const chunk = bytes.slice(i, i + 255);
    blocks.push(chunk.length, ...chunk);
  }
  return [
    0x21, 0xf9, 4, 0, 50, 0, 0, 0, // 0.5 s per frame
    0x2c, 0, 0, 0, 0, size & 0xff, size >> 8, size & 0xff, size >> 8, 0,
    8, ...blocks, 0,
  ];
}

const header = [
  ...Buffer.from('GIF89a'),
  size & 0xff, size >> 8, size & 0xff, size >> 8,
  0xf7, 0, 0, // global palette of 256 entries
];
const palette = new Array(256 * 3).fill(0);
palette.splice(0, 6, ...rgb(a), ...rgb(b));
const loop = [0x21, 0xff, 11, ...Buffer.from('NETSCAPE2.0'), 3, 1, 0, 0, 0];
fs.writeFileSync(
  out,
  Buffer.from([...header, ...palette, ...loop, ...frame(0), ...frame(1), 0x3b]),
);
