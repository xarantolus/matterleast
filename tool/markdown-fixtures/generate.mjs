// Parses every message in test/fixtures/markdown/corpus.json with the
// commonmark fork Mattermost's apps use and writes simplified trees to
// test/fixtures/markdown/expected.json, the shape test/markdown/differential
// compares against. Run: tool/markdown-fixtures/generate.sh
import {readFileSync, writeFileSync} from 'node:fs';
import {Parser} from '@mattermost/commonmark';

const [corpusPath, outPath] = process.argv.slice(2);
const corpus = JSON.parse(readFileSync(corpusPath, 'utf8'));
const BOLD = 1, ITALIC = 2, STRIKE = 4;
const task = /^ {0,3}\[( |x)\]\s/;

function children(node) {
  const out = [];
  for (let c = node.firstChild; c; c = c.next) out.push(c);
  return out;
}

function inlines(node, marks = 0, link = null, out = []) {
  for (const c of children(node)) {
    switch (c.type) {
      case 'text': case 'html_inline':
        out.push(['t', c.literal, marks, link]); break;
      case 'softbreak': out.push(['t', '\n', marks, link]); break;
      case 'linebreak': out.push(['br']); break;
      case 'strong': inlines(c, marks | BOLD, link, out); break;
      case 'emph': inlines(c, marks | ITALIC, link, out); break;
      case 'del': inlines(c, marks | STRIKE, link, out); break;
      case 'code': out.push(['code', c.literal, marks, link]); break;
      case 'link': inlines(c, marks, link ?? c.destination, out); break;
      case 'image': {
        const size = c.size ?? {};
        out.push(['img', c.destination, size.width ?? null, size.height ?? null]);
        break;
      }
      case 'at_mention': out.push(['mention', c.mentionName]); break;
      case 'channel_link': out.push(['channel', c.channelName]); break;
      case 'emoji': out.push(['emoji', c.emojiName]); break;
      case 'hashtag': out.push(['hashtag', c.hashtag]); break;
      case 'latex_inline': out.push(['math', c.latexCode]); break;
      default: out.push(['?' + c.type]);
    }
  }
  return out;
}

function merge(parts) {
  const out = [];
  for (const p of parts) {
    const last = out[out.length - 1];
    if (p[0] === 't' && last && last[0] === 't' && last[2] === p[2] && last[3] === p[3]) {
      last[1] += p[1];
    } else if (!(p[0] === 't' && p[1] === '')) {
      out.push([...p]);
    }
  }
  return out;
}

function blocks(node) {
  return children(node).map(block);
}

function item(node) {
  const content = blocks(node);
  const first = content[0];
  if (first && first.p && first.p[0] && first.p[0][0] === 't') {
    const m = task.exec(first.p[0][1]);
    if (m) {
      const rest = first.p[0][1].substring(m[0].length);
      const p = [...(rest ? [['t', rest, first.p[0][2], first.p[0][3]]] : []), ...first.p.slice(1)];
      return {checked: m[1] === 'x', blocks: [{p}, ...content.slice(1)]};
    }
  }
  return {checked: null, blocks: content};
}

function block(node) {
  switch (node.type) {
    case 'paragraph': return {p: merge(inlines(node))};
    case 'heading': return {h: node.level, c: merge(inlines(node))};
    case 'code_block': {
      const lang = (node.info ?? '').trim().split(/\s+/)[0] ?? '';
      return {code: lang, text: node.literal.replace(/\n$/, '')};
    }
    case 'html_block': return {p: [['t', node.literal.replace(/\n$/, ''), 0, null]]};
    case 'block_quote': return {quote: blocks(node)};
    case 'list': return {
      list: node.listType === 'ordered' ? 'ol' : 'ul',
      start: node.listType === 'ordered' ? node.listStart : 1,
      items: children(node).map(item),
    };
    case 'thematic_break': return {hr: true};
    case 'table': return {
      table: children(node).map((row) => children(row).map((cell) => merge(inlines(cell)))),
    };
    default: return {['?' + node.type]: true};
  }
}

const parser = new Parser({minimumHashtagLength: 3});
const expected = {};
for (const {name, text} of corpus) {
  expected[name] = blocks(parser.parse(text));
}
writeFileSync(outPath, JSON.stringify(expected, null, 1) + '\n');
console.log(`wrote ${Object.keys(expected).length} trees to ${outPath}`);
