import assert from 'node:assert/strict';
import { afterEach, test } from 'node:test';
import { createVimeoServer } from './server.js';

const servers = [];

async function startServer(options) {
  const server = createVimeoServer(options);
  servers.push(server);
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const address = server.address();
  return `http://127.0.0.1:${address.port}`;
}

afterEach(async () => {
  await Promise.all(
    servers.splice(0).map(
      (server) =>
        new Promise((resolve, reject) => {
          server.close((error) => (error ? reject(error) : resolve()));
        }),
    ),
  );
});

test('health check works without loading or exposing credentials', async () => {
  const baseUrl = await startServer({ env: {} });
  const response = await fetch(`${baseUrl}/health`);
  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'ok' });
});

test('allows the configured localhost origin in development', async () => {
  const baseUrl = await startServer({ env: { NODE_ENV: 'development' } });
  const response = await fetch(`${baseUrl}/health`, {
    headers: { Origin: 'http://localhost:5173' },
  });
  assert.equal(response.status, 200);
  assert.equal(
    response.headers.get('access-control-allow-origin'),
    'http://localhost:5173',
  );
  assert.equal(response.headers.get('vary'), 'Origin');
});

test('requires an exact HTTPS origin allowlist in production', async () => {
  const baseUrl = await startServer({
    env: {
      NODE_ENV: 'production',
      CORS_ALLOWED_ORIGINS: 'https://toktik.example',
    },
  });
  const allowed = await fetch(`${baseUrl}/health`, {
    headers: { Origin: 'https://toktik.example' },
  });
  assert.equal(allowed.status, 200);
  assert.equal(
    allowed.headers.get('access-control-allow-origin'),
    'https://toktik.example',
  );

  const denied = await fetch(`${baseUrl}/health`, {
    headers: { Origin: 'https://untrusted.example' },
  });
  assert.equal(denied.status, 403);
  assert.equal(denied.headers.has('access-control-allow-origin'), false);
});

test('Vimeo search uses the environment token and returns only mapped data', async () => {
  let upstreamRequest;
  const baseUrl = await startServer({
    env: { VIMEO_ACCESS_TOKEN: 'test-token' },
    fetchImpl: async (url, options) => {
      upstreamRequest = { url, options };
      return Response.json({
        data: [
          {
            uri: '/videos/42',
            name: 'A clip',
            description: 'Description',
            pictures: {
              sizes: [{ link: 'https://img.example/42.jpg', width: 100 }],
            },
            private_secret: 'must not be returned',
          },
        ],
      });
    },
  });

  const response = await fetch(
    `${baseUrl}/api/vimeo/search?query=${encodeURIComponent('a clip')}`,
  );
  assert.equal(response.status, 200);
  assert.equal(upstreamRequest.url.hostname, 'api.vimeo.com');
  assert.equal(upstreamRequest.url.pathname, '/videos');
  assert.equal(upstreamRequest.url.searchParams.get('query'), 'a clip');
  assert.equal(
    upstreamRequest.options.headers.Authorization,
    'Bearer test-token',
  );
  assert.deepEqual(await response.json(), {
    data: [
      {
        uri: '/videos/42',
        name: 'A clip',
        description: 'Description',
        pictures: { sizes: [{ link: 'https://img.example/42.jpg' }] },
      },
    ],
  });
});

test('missing token returns a configuration error without calling Vimeo', async () => {
  let called = false;
  const baseUrl = await startServer({
    env: {},
    fetchImpl: async () => {
      called = true;
      return Response.json({ data: [] });
    },
  });

  const response = await fetch(`${baseUrl}/api/vimeo/search?query=hello`);
  assert.equal(response.status, 503);
  assert.equal(called, false);
  assert.match(await response.text(), /VIMEO_ACCESS_TOKEN/);
});

test('invalid query is rejected before requesting Vimeo', async () => {
  let called = false;
  const baseUrl = await startServer({
    env: { VIMEO_ACCESS_TOKEN: 'test-token' },
    fetchImpl: async () => {
      called = true;
      return Response.json({ data: [] });
    },
  });

  const response = await fetch(`${baseUrl}/api/vimeo/search?query=`);
  assert.equal(response.status, 400);
  assert.equal(called, false);
});

test('oversized query is rejected before requesting Vimeo', async () => {
  let called = false;
  const baseUrl = await startServer({
    env: { VIMEO_ACCESS_TOKEN: 'test-token' },
    fetchImpl: async () => {
      called = true;
      return Response.json({ data: [] });
    },
  });

  const response = await fetch(
    `${baseUrl}/api/vimeo/search?query=${'a'.repeat(101)}`,
  );
  assert.equal(response.status, 400);
  assert.equal(called, false);
});

test('authentication failures are forwarded without leaking upstream details', async () => {
  const baseUrl = await startServer({
    env: { VIMEO_ACCESS_TOKEN: 'test-token' },
    fetchImpl: async () =>
      new Response('sensitive upstream body', { status: 401 }),
  });

  const response = await fetch(`${baseUrl}/api/vimeo/search?query=hello`);
  assert.equal(response.status, 401);
  assert.deepEqual(await response.json(), {
    error: { message: 'Vimeo rechazó la autorización del backend.' },
  });
});

test('rate limits pass only a numeric retry-after hint', async () => {
  const baseUrl = await startServer({
    env: { VIMEO_ACCESS_TOKEN: 'test-token' },
    fetchImpl: async () =>
      new Response('sensitive upstream body', {
        status: 429,
        headers: { 'Retry-After': '30' },
      }),
  });

  const response = await fetch(`${baseUrl}/api/vimeo/search?query=hello`);
  assert.equal(response.status, 429);
  assert.equal(response.headers.get('retry-after'), '30');
  assert.deepEqual(await response.json(), {
    error: { message: 'No se pudo consultar Vimeo.' },
  });
});

test('malformed Vimeo collections return a gateway error', async () => {
  const baseUrl = await startServer({
    env: { VIMEO_ACCESS_TOKEN: 'test-token' },
    fetchImpl: async () => Response.json({ data: null }),
  });

  const response = await fetch(`${baseUrl}/api/vimeo/search?query=hello`);
  assert.equal(response.status, 502);
});
