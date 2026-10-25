// Side services for the local test server, all on the loopback:
//   /shout <text>  slash command, replies in the channel
//   /lunch         slash command, opens an interactive dialog
//   /oauth/*       a fake GitLab that approves every login at once, so the
//                  mobile SSO flow can be exercised without a real provider
const http = require('http');

const PORT = 8066;
const SERVER = 'http://127.0.0.1:8065';
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

async function openDialog(triggerId) {
  const dialog = {
    trigger_id: triggerId,
    url: `http://127.0.0.1:${PORT}/lunch/submit`,
    dialog: {
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
    },
  };
  const res = await fetch(`${SERVER}/api/v4/actions/dialogs/open`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(dialog),
  });
  if (!res.ok) console.log('dialog open failed', res.status, await res.text());
}

http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://127.0.0.1:${PORT}`);
  const body = parse(req, await readBody(req));
  console.log(req.method, url.pathname, body.command || body.callback_id || '');

  if (url.pathname === '/shout') {
    return reply(res, 200, {
      response_type: 'in_channel',
      text: body.text ? `**Shout:** ${body.text}` : 'Nothing to shout. Try `/shout hello`.',
    });
  }
  if (url.pathname === '/lunch') {
    await openDialog(body.trigger_id);
    return reply(res, 200, { response_type: 'ephemeral', text: 'Opening the lunch dialog…' });
  }
  if (url.pathname === '/lunch/submit') {
    const s = body.submission || {};
    if (!s.dish) return reply(res, 200, { errors: { dish: 'Tell us what to order.' } });
    return reply(res, 200, {});
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
