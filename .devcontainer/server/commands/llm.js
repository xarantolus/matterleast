// A fake OpenAI-compatible chat completions endpoint for the Agents plugin
// (server.sh agents points its "Local echo" service here). Everything it says
// is canned and invented; it never calls out.
//
//   a message containing "ask me" asks the user a question (AskUserQuestion,
//                                 waits for the user's answer in the app)
//   a message containing "tool"   asks to run another tool it is offered
//                                 (CreateFile runs at once), then answers
//                                 with what the tool returned
//   a message containing "think"  streams a reasoning summary first
//   a message containing "long"   streams a long answer, slow enough to Stop
//   a message containing "slow"   waits 8 s before the first word, like a
//                                 provider that is slow to connect
//   a message containing "fail"   answers HTTP 500 (the plugin shows its
//                                 "error occurred" text); "fail midway"
//                                 streams a few words, then drops the stream;
//                                 "fail hang up" closes the connection
//                                 without an answer; "fail auth" answers 401
//   anything else                 a short canned answer, streamed word by word

const SHORT = 'Here is a short answer from the **local echo** agent. ' +
  'It streams word by word so the app can show text as it arrives:\n\n' +
  '- first point\n- second point\n\nThat is all for now.';

const LONG = Array.from({ length: 12 }, (_, i) =>
  `Paragraph ${i + 1}: the lighthouse keeper counts the ships that pass the harbour ` +
  'and writes each one into the logbook, with the hour, the wind and the colour of the sails.',
).join('\n\n');

const REASONING = 'The reader asked a question. I should answer briefly, in a friendly tone, and list two points.';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function lastUser(messages) {
  for (let i = messages.length - 1; i >= 0; i--) {
    if (messages[i].role === 'user') return messages[i];
  }
  return null;
}

function text(content) {
  if (typeof content === 'string') return content;
  if (Array.isArray(content)) return content.map((c) => c.text || '').join(' ');
  return '';
}

// What to answer: a tool call, or text (with optional reasoning first).
function plan(body) {
  const messages = body.messages || [];
  const last = messages[messages.length - 1] || {};
  const asked = text((lastUser(messages) || {}).content).toLowerCase();
  const tools = body.tools || [];
  console.log('llm: tools offered', tools.map((t) => t.function.name).join(', '));
  if (last.role === 'tool') {
    const result = text(last.content).slice(0, 200);
    return { text: `The tool answered \`${result.replace(/[\n`]/g, ' ')}\`. That settles it.` };
  }
  if (asked.includes('ask me') && tools.some((t) => t.function.name === 'AskUserQuestion')) {
    return {
      tool: {
        name: 'AskUserQuestion',
        arguments: JSON.stringify({
          question: 'Which light should the keeper switch on tonight?',
          options: [
            { label: 'Red', description: 'Harbour entrance, port side' },
            { label: 'Green', description: 'Harbour entrance, starboard side' },
          ],
          multi_select: false,
          allow_free_form: false,
        }),
      },
    };
  }
  if (asked.includes('tool') && tools.length > 0) {
    const tool = tools.find((t) => t.function.name !== 'AskUserQuestion') || tools[0];
    const props = (tool.function.parameters || {}).properties || {};
    const args = {};
    for (const [key, p] of Object.entries(props)) {
      args[key] = {
        number: 1, integer: 1, boolean: false, array: [], object: {},
      }[p.type] ?? (/name/i.test(key) ? 'lighthouse-notes.txt' : 'Invented notes from the local echo agent.');
    }
    return { tool: { name: tool.function.name, arguments: JSON.stringify(args) } };
  }
  // Conversation titles; plugin 2.x asks for them streamed.
  if (!body.stream || asked.startsWith('write a short title')) {
    return { text: 'Lighthouse chat' };
  }
  if (asked.includes('summar')) {
    return {
      text: '**Summary**\n\n- The crew talked about the evening shift.\n' +
        '- Someone asked who reviews the release notes.\n- No decisions are open.',
    };
  }
  if (asked.includes('fail')) {
    if (asked.includes('midway')) return { text: SHORT, dropAfter: 6 };
    if (asked.includes('hang up')) return { hangUp: true };
    return { status: asked.includes('auth') ? 401 : 500 };
  }
  return {
    delay: asked.includes('slow') ? 8000 : 0,
    text: asked.includes('long') ? LONG : SHORT,
    reasoning: asked.includes('think') ? REASONING : null,
    pace: asked.includes('long') ? 120 : 60,
  };
}

function chunk(res, model, delta, finish = null) {
  res.write(`data: ${JSON.stringify({
    id: 'chatcmpl-local',
    object: 'chat.completion.chunk',
    created: Math.floor(Date.now() / 1000),
    model,
    choices: [{ index: 0, delta, finish_reason: finish }],
  })}\n\n`);
}

async function stream(res, model, answer) {
  if (answer.delay) await sleep(answer.delay);
  res.writeHead(200, { 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache' });
  let closed = false;
  res.on('close', () => { closed = true; });
  chunk(res, model, { role: 'assistant', content: '' });
  if (answer.tool) {
    chunk(res, model, {
      tool_calls: [{ index: 0, id: `call_${Date.now()}`, type: 'function', function: answer.tool }],
    });
    chunk(res, model, {}, 'tool_calls');
  } else {
    if (answer.reasoning) {
      for (const word of answer.reasoning.split(/(?<= )/)) {
        if (closed) return;
        chunk(res, model, { reasoning_content: word });
        await sleep(40);
      }
    }
    for (const [i, word] of answer.text.split(/(?<= )/).entries()) {
      if (closed) return;
      if (i === answer.dropAfter) {
        res.destroy();
        return;
      }
      chunk(res, model, { content: word });
      await sleep(answer.pace || 30);
    }
    chunk(res, model, {}, 'stop');
  }
  res.write('data: [DONE]\n\n');
  res.end();
}

function complete(res, model, answer) {
  const message = answer.tool
    ? { role: 'assistant', content: null, tool_calls: [{ id: `call_${Date.now()}`, type: 'function', function: answer.tool }] }
    : { role: 'assistant', content: answer.text };
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    id: 'chatcmpl-local',
    object: 'chat.completion',
    created: Math.floor(Date.now() / 1000),
    model,
    choices: [{ index: 0, message, finish_reason: answer.tool ? 'tool_calls' : 'stop' }],
    usage: { prompt_tokens: 10, completion_tokens: 10, total_tokens: 20 },
  }));
}

// Handles /llm/v1/*; returns false for other paths.
async function handleLlm(path, body, res) {
  if (!path.startsWith('/llm/v1/')) return false;
  if (path === '/llm/v1/models') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ object: 'list', data: [{ id: 'local-echo', object: 'model' }] }));
    return true;
  }
  if (path === '/llm/v1/chat/completions') {
    const answer = plan(body);
    if (answer.hangUp) {
      res.socket.destroy();
      return true;
    }
    if (answer.status) {
      res.writeHead(answer.status, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: { message: 'the local echo model failed on purpose' } }));
      return true;
    }
    const model = body.model || 'local-echo';
    if (body.stream) await stream(res, model, answer);
    else complete(res, model, answer);
    return true;
  }
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: { message: 'unknown endpoint' } }));
  return true;
}

module.exports = { handleLlm };
