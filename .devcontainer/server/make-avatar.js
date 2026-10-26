// Writes a generated avatar PNG: a diagonal two-hue gradient with a mirrored
// 5x5 pattern of rounded tiles, both derived from the seed text, so every
// invented user gets a distinct picture that is clearly not a photo.
//   node make-avatar.js <out.png> <seed> [size]
const fs = require('fs');
const zlib = require('zlib');

const [out, seed, sizeArg] = process.argv.slice(2);
const size = Number(sizeArg || 256);

function hash(text) {
  let h = 2166136261;
  for (const ch of text) h = Math.imul(h ^ ch.codePointAt(0), 16777619) >>> 0;
  return () => {
    h ^= h << 13; h >>>= 0;
    h ^= h >>> 17;
    h ^= h << 5; h >>>= 0;
    return h / 4294967296;
  };
}

function hsl(h, s, l) {
  const k = (n) => (n + h / 30) % 12;
  const a = s * Math.min(l, 1 - l);
  const f = (n) => l - a * Math.max(-1, Math.min(k(n) - 3, Math.min(9 - k(n), 1)));
  return [f(0), f(8), f(4)].map((v) => Math.round(v * 255));
}

const rnd = hash(seed);
const hue = Math.floor(rnd() * 360);
const from = hsl(hue, 0.65, 0.42);
const to = hsl((hue + 25 + rnd() * 25) % 360, 0.7, 0.58);

const grid = 5;
const cells = [];
for (let y = 0; y < grid; y++) {
  const row = [];
  for (let x = 0; x < 3; x++) row.push(rnd() > 0.45);
  cells.push([...row, row[1], row[0]]);
}

// Pattern sits in the middle 70 % so a round crop keeps it whole.
const pad = size * 0.15;
const cell = (size - 2 * pad) / grid;
const radius = cell * 0.28;
const gap = cell * 0.08;

function inTile(px, py) {
  const gx = Math.floor((px - pad) / cell);
  const gy = Math.floor((py - pad) / cell);
  if (gx < 0 || gy < 0 || gx >= grid || gy >= grid || !cells[gy][gx]) return false;
  const x0 = pad + gx * cell + gap, y0 = pad + gy * cell + gap;
  const x1 = x0 + cell - 2 * gap, y1 = y0 + cell - 2 * gap;
  const dx = Math.max(x0 + radius - px, 0, px - (x1 - radius));
  const dy = Math.max(y0 + radius - py, 0, py - (y1 - radius));
  return px >= x0 && px <= x1 && py >= y0 && py <= y1 && dx * dx + dy * dy <= radius * radius;
}

const samples = 4;
const rows = [];
for (let y = 0; y < size; y++) {
  const row = Buffer.alloc(1 + size * 3);
  for (let x = 0; x < size; x++) {
    const t = (x + y) / (2 * size);
    const bg = from.map((c, i) => c + (to[i] - c) * t);
    let cover = 0;
    for (let sy = 0; sy < samples; sy++) {
      for (let sx = 0; sx < samples; sx++) {
        if (inTile(x + (sx + 0.5) / samples, y + (sy + 0.5) / samples)) cover++;
      }
    }
    const a = (cover / (samples * samples)) * 0.88;
    bg.forEach((c, i) => row.writeUInt8(Math.round(c + (255 - c) * a), 1 + x * 3 + i));
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
fs.writeFileSync(out, Buffer.concat([
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  chunk('IHDR', ihdr),
  chunk('IDAT', zlib.deflateSync(Buffer.concat(rows))),
  chunk('IEND', Buffer.alloc(0)),
]));
