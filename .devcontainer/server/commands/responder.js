// Side services for the local test server, all on the loopback:
//   /shout <text>  slash command, replies in the channel
//   /lunch         slash command, opens an interactive dialog
//   /blocks <fmt>  slash command, posts interactive content as message
//                  attachments, Block Kit, Adaptive Cards or MM Blocks;
//                  their buttons and menus are answered on /blocks/action
//   /oauth/*       a fake GitLab that approves every login at once, so the
//                  mobile SSO flow can be exercised without a real provider
//   /llm/v1/*      a fake OpenAI-compatible model for the Agents plugin
//                  (llm.js)
const http = require('http');
const { handleLlm } = require('./llm');

const PORT = Number(process.env.PORT || 8066);
const SERVER = 'http://127.0.0.1:8065';
const ACTION_URL = `http://127.0.0.1:${PORT}/blocks/action`;
const OAUTH_USER = {
  id: 4711,
  username: 'sso-sam',
  login: 'sso-sam',
  email: 'sso-sam@example.test',
  name: 'Sam Singleton',
};

function readBody(req) {
  return new Promise((resolve) => {
    let data = '';
    req.on('data', (chunk) => (data += chunk));
    req.on('end', () => resolve(data));
  });
}

function parse(req, body) {
  const type = req.headers['content-type'] || '';
  if (type.includes('json')) return JSON.parse(body || '{}');
  return Object.fromEntries(new URLSearchParams(body));
}

function reply(res, status, payload) {
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
}

async function openDialog(triggerId, dialog) {
  const res = await fetch(`${SERVER}/api/v4/actions/dialogs/open`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ trigger_id: triggerId, url: `http://127.0.0.1:${PORT}/lunch/submit`, dialog }),
  });
  if (!res.ok) console.log('dialog open failed', res.status, await res.text());
}

const LUNCH_DIALOG = {
  callback_id: 'lunch',
  title: 'Lunch order',
  introduction_text: 'Pick something for the crew lunch.',
  elements: [
    { display_name: 'Dish', name: 'dish', type: 'text', placeholder: 'e.g. noodles', min_length: 2, max_length: 40 },
    { display_name: 'Size', name: 'size', type: 'select', options: [
      { text: 'Small', value: 's' }, { text: 'Regular', value: 'm' }, { text: 'Large', value: 'l' },
    ] },
    { display_name: 'Spicy', name: 'spicy', type: 'bool', placeholder: 'Make it spicy', optional: true },
    { display_name: 'Notes', name: 'notes', type: 'textarea', optional: true, help_text: 'Allergies, wishes' },
  ],
  submit_label: 'Order',
  notify_on_cancel: false,
};

// --- /blocks: one demo post per format -----------------------------------

// An action of a Block Kit, Adaptive Card or MM Blocks post; the server
// seals these into the post's mm_blocks_actions cookie.
const external = (action) => ({ type: 'external', url: ACTION_URL, context: { action } });

function attachmentDemo() {
  const integration = (action) => ({ url: ACTION_URL, context: { action } });
  const button = (id, name, action, extra = {}) => ({ id, name, type: 'button', integration: integration(action), ...extra });
  return {
    attachments: [{
      fallback: 'Release checklist',
      color: '#2389d7',
      pretext: 'The release checklist is ready for review.',
      author_name: 'Release Robot',
      title: 'Release 4.2 checklist',
      title_link: 'https://example.com/releases/4.2',
      text: 'Three of four steps are done. Approve to ship, or open the form.',
      fields: [
        { title: 'Branch', value: 'release-4.2', short: true },
        { title: 'Owner', value: '@carol', short: true },
        { title: 'Notes', value: 'Translations arrive on Thursday.', short: false },
      ],
      footer: 'Release Robot · checklist',
      actions: [
        button('approve', 'Approve', 'approve', { style: 'primary' }),
        button('ping', 'Ping me', 'ping'),
        button('form', 'Open form', 'dialog', { style: 'good' }),
        button('docs', 'Docs', 'goto'),
        { id: 'size', name: 'Pick a size', type: 'select', integration: integration('pick'),
          options: [{ text: 'Small', value: 'small' }, { text: 'Medium', value: 'medium' }, { text: 'Large', value: 'large' }] },
        { id: 'reviewer', name: 'Pick a reviewer', type: 'select', data_source: 'users', integration: integration('pick') },
        { id: 'room', name: 'Pick a channel', type: 'select', data_source: 'channels', integration: integration('pick') },
      ],
    }],
  };
}

function blockKitDemo() {
  const plain = (text) => ({ type: 'plain_text', text });
  return {
    blocks: [
      { type: 'header', text: plain('Morning stand-up') },
      { type: 'section', text: { type: 'mrkdwn', text: '**Today:** review the harbour map and fix the lantern bug.' },
        accessory: { type: 'button', text: plain('Ping me'), action_id: 'ping' } },
      { type: 'section', fields: [
        { type: 'mrkdwn', text: '**Done**\n4 tasks' },
        { type: 'mrkdwn', text: '**Open**\n2 tasks' },
      ] },
      { type: 'divider' },
      { type: 'actions', elements: [
        { type: 'button', text: plain('Approve'), action_id: 'approve', style: 'primary' },
        { type: 'button', text: plain('Decline'), action_id: 'decline', style: 'danger' },
        { type: 'static_select', action_id: 'mood', placeholder: plain('How do you feel?'),
          options: [{ text: plain('Rested'), value: 'rested' }, { text: plain('Busy'), value: 'busy' }] },
      ] },
    ],
    mm_blocks_actions: { ping: external('ping'), approve: external('approve'), decline: external('ping'), mood: external('pick') },
  };
}

function cardDemo() {
  return {
    cards: [{
      type: 'AdaptiveCard',
      version: '1.5',
      body: [
        { type: 'TextBlock', text: '**Boat rental request**' },
        { type: 'TextBlock', text: 'Dave asks for the small sailboat on Saturday.', isSubtle: true },
        { type: 'ColumnSet', columns: [
          { type: 'Column', width: 'stretch', items: [{ type: 'TextBlock', text: '**From**\n\nSaturday 09:00' }] },
          { type: 'Column', width: 'stretch', items: [{ type: 'TextBlock', text: '**To**\n\nSaturday 17:00' }] },
        ] },
        { type: 'Container', items: [{ type: 'TextBlock', text: 'Life jackets are in the shed.', size: 'Small' }] },
      ],
      actions: [
        { type: 'Action.Submit', id: 'approve', title: 'Approve', style: 'positive' },
        { type: 'Action.Submit', id: 'form', title: 'Open form' },
        { type: 'Action.Submit', id: 'decline', title: 'Decline', style: 'destructive' },
      ],
    }],
    mm_blocks_actions: { approve: external('approve'), form: external('dialog'), decline: external('ping') },
  };
}

function mmBlocksDemo() {
  return {
    mm_blocks: [
      { type: 'container', border: true, accent_color: 'primary', content: [
        { type: 'text', text: '### Lighthouse maintenance' },
        { type: 'text', text: 'The lamp needs a new bulb. [Ping me](mmaction://ping?from=text) or pick a slot.', is_subtle: true },
        { type: 'column_set', columns: [
          { type: 'column', width: 'stretch', items: [{ type: 'text', text: '**Slot**\n\nThursday 14:00' }] },
          { type: 'column', width: 'stretch', items: [{ type: 'text', text: '**Crew**\n\n2 people' }] },
        ] },
        { type: 'divider' },
        { type: 'collapsible', collapsed: true,
          header: [{ type: 'text', text: '**Checklist**' }],
          content: [{ type: 'text', text: '- Ladder\n- Gloves\n- Spare bulb' }] },
        { type: 'container', flow: 'horizontal', gap: 'small', content: [
          { type: 'button', text: 'Approve', action_id: 'approve', style: 'primary' },
          { type: 'button', text: 'Open form', action_id: 'form', style: 'good' },
          { type: 'button', text: 'Docs', action_id: 'docs' },
          { type: 'static_select', action_id: 'slot', placeholder: 'Other slot',
            options: [{ text: 'Friday 10:00', value: 'fri' }, { text: 'Monday 09:00', value: 'mon' }] },
        ] },
      ] },
    ],
    mm_blocks_actions: {
      ping: external('ping'), approve: external('approve'), form: external('dialog'),
      docs: { type: 'openURL', url: 'https://example.com/lighthouse' }, slot: external('pick'),
    },
  };
}

// The demo posts come from the seeded helper-bot, since only a bot's (or a
// webhook's) post may carry mm_blocks_actions. The responder signs in with
// the invented admin account of this test server to get the bot a token.
let bot;
async function asBot() {
  if (bot) return bot;
  const login = await fetch(`${SERVER}/api/v4/users/login`, {
    method: 'POST',
    body: JSON.stringify({ login_id: 'admin', password: 'matterleast' }),
  });
  const admin = { Authorization: `Bearer ${login.headers.get('token')}`, 'Content-Type': 'application/json' };
  const user = await (await fetch(`${SERVER}/api/v4/users/username/helper-bot`, { headers: admin })).json();
  const token = await (await fetch(`${SERVER}/api/v4/users/${user.id}/tokens`, {
    method: 'POST', headers: admin, body: JSON.stringify({ description: 'blocks demo' }),
  })).json();
  bot = { id: user.id, admin, auth: { Authorization: `Bearer ${token.token}`, 'Content-Type': 'application/json' } };
  return bot;
}

async function postAsBot(channelId, props) {
  const { id, admin, auth } = await asBot();
  await fetch(`${SERVER}/api/v4/channels/${channelId}/members`, {
    method: 'POST', headers: admin, body: JSON.stringify({ user_id: id }),
  });
  const res = await fetch(`${SERVER}/api/v4/posts`, {
    method: 'POST', headers: auth, body: JSON.stringify({ channel_id: channelId, message: '', props }),
  });
  return res.ok ? null : `${res.status} ${await res.text()}`;
}

const DEMOS = { attachment: attachmentDemo, blockkit: blockKitDemo, card: cardDemo, mmblocks: mmBlocksDemo };

// The click's query (from an mmaction:// link) arrives in the URL.
async function answerAction(body, query) {
  const action = (body.context || {}).action;
  const who = body.user_name ? `@${body.user_name}` : 'someone';
  switch (action) {
    case 'approve':
      return { update: { message: `:white_check_mark: Approved by ${who}.`, props: {} } };
    case 'ping': {
      const from = query.get('from') ? ` (from the ${query.get('from')})` : '';
      return { ephemeral_text: `Pong! Only you see this${from}.` };
    }
    case 'dialog':
      await openDialog(body.trigger_id, LUNCH_DIALOG);
      return {};
    case 'goto':
      return { goto_location: 'https://example.com/docs' };
    case 'pick': {
      const picked = body.selected_option || (body.context || {}).selected_option || '?';
      return { ephemeral_text: `You picked \`${picked}\`.` };
    }
    default:
      return { ephemeral_text: 'Unknown action.' };
  }
}

http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://127.0.0.1:${PORT}`);
  const body = parse(req, await readBody(req));
  console.log(req.method, url.pathname, body.command || body.callback_id || (body.context || {}).action || '');
  if (await handleLlm(url.pathname, body, res)) return;

  if (url.pathname === '/shout') {
    return reply(res, 200, {
      response_type: 'in_channel',
      text: body.text ? `**Shout:** ${body.text}` : 'Nothing to shout. Try `/shout hello`.',
    });
  }
  if (url.pathname === '/lunch') {
    await openDialog(body.trigger_id, LUNCH_DIALOG);
    return reply(res, 200, { response_type: 'ephemeral', text: 'Opening the lunch dialog…' });
  }
  if (url.pathname === '/lunch/submit') {
    const s = body.submission || {};
    if (!s.dish) return reply(res, 200, { errors: { dish: 'Tell us what to order.' } });
    return reply(res, 200, {});
  }
  if (url.pathname === '/blocks') {
    const demo = DEMOS[(body.text || '').trim()];
    if (!demo) {
      return reply(res, 200, {
        response_type: 'ephemeral',
        text: 'Try `/blocks attachment`, `/blocks blockkit`, `/blocks card` or `/blocks mmblocks`.',
      });
    }
    const failed = await postAsBot(body.channel_id, demo()).catch((e) => String(e));
    if (failed) console.log('demo post failed', failed);
    return reply(res, 200, failed ? { response_type: 'ephemeral', text: "helper-bot couldn't post here." } : {});
  }
  if (url.pathname === '/blocks/action') {
    return reply(res, 200, await answerAction(body, url.searchParams));
  }

  // Fake GitLab: the browser lands on /oauth/authorize and is sent straight
  // back with a code; the server then trades the code for a token and asks
  // for the user.
  if (url.pathname === '/oauth/authorize') {
    const back = new URL(url.searchParams.get('redirect_uri'));
    back.searchParams.set('code', 'fake-code');
    back.searchParams.set('state', url.searchParams.get('state') || '');
    res.writeHead(302, { Location: back.toString() });
    return res.end();
  }
  if (url.pathname === '/oauth/token') {
    return reply(res, 200, { access_token: 'fake-access-token', token_type: 'bearer', scope: 'read_user' });
  }
  if (url.pathname === '/api/v4/user') {
    return reply(res, 200, OAUTH_USER);
  }
  reply(res, 404, { text: 'unknown endpoint' });
}).listen(PORT, '127.0.0.1', () => console.log(`side services on ${PORT}`));
