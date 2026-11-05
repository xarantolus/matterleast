// The second test server's public port. Passes everything through to the
// server behind it, WebSockets included, and only adds the GitLab sign-in
// to the client config: Team Edition hides it without a licence, although
// the server runs the GitLab flow fine. The server's SiteURL is this port,
// so the SSO callback names the address the app knows.
const http = require('http');
const net = require('net');

function startSsoProxy(publicPort, serverPort) {
  const proxy = http.createServer((req, res) => {
    const headers = { ...req.headers };
    const isConfig = req.url.startsWith('/api/v4/config/client');
    if (isConfig) delete headers['accept-encoding'];
    const upstream = http.request(
      { host: '127.0.0.1', port: serverPort, method: req.method, path: req.url, headers },
      (answer) => {
        if (!isConfig || answer.statusCode !== 200) {
          res.writeHead(answer.statusCode, answer.headers);
          answer.pipe(res);
          return;
        }
        let data = '';
        answer.setEncoding('utf8');
        answer.on('data', (chunk) => (data += chunk));
        answer.on('end', () => {
          const config = JSON.parse(data);
          config.EnableSignUpWithGitLab = 'true';
          const body = JSON.stringify(config);
          const out = { ...answer.headers, 'content-length': Buffer.byteLength(body) };
          delete out.etag;
          res.writeHead(200, out);
          res.end(body);
        });
      },
    );
    upstream.on('error', () => {
      res.writeHead(502);
      res.end();
    });
    req.pipe(upstream);
  });

  proxy.on('upgrade', (req, socket, head) => {
    const upstream = net.connect(serverPort, '127.0.0.1', () => {
      const lines = [`${req.method} ${req.url} HTTP/1.1`];
      for (let i = 0; i < req.rawHeaders.length; i += 2) {
        lines.push(`${req.rawHeaders[i]}: ${req.rawHeaders[i + 1]}`);
      }
      upstream.write(lines.join('\r\n') + '\r\n\r\n');
      if (head.length) upstream.write(head);
      upstream.pipe(socket);
      socket.pipe(upstream);
    });
    upstream.on('error', () => socket.destroy());
    socket.on('error', () => upstream.destroy());
  });

  proxy.listen(publicPort, '127.0.0.1', () =>
    console.log(`SSO proxy on ${publicPort} for the server on ${serverPort}`),
  );
}

module.exports = { startSsoProxy };
