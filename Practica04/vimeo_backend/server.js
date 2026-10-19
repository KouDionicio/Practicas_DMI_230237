import 'dotenv/config';
import { createServer } from 'node:http';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const VIMEO_API_URL = 'https://api.vimeo.com/videos';
const VIMEO_FIELDS = 'uri,name,description,pictures.sizes.link';
const MAX_QUERY_LENGTH = 100;
const REQUEST_TIMEOUT_MS = 15_000;

function corsHeaders(origin, env) {
  if (origin === undefined) return {};

  let parsedOrigin;
  try {
    parsedOrigin = new URL(origin);
  } catch {
    return null;
  }
  if (
    parsedOrigin.origin !== origin ||
    (parsedOrigin.protocol !== 'https:' && parsedOrigin.protocol !== 'http:')
  ) {
    return null;
  }

  const configuredOrigins = new Set(
    (env.CORS_ALLOWED_ORIGINS ?? '')
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean),
  );
  const isLocalDevelopmentOrigin =
    env.NODE_ENV !== 'production' &&
    parsedOrigin.protocol === 'http:' &&
    ['localhost', '127.0.0.1', '[::1]'].includes(parsedOrigin.hostname);
  if (
    !(parsedOrigin.protocol === 'https:' && configuredOrigins.has(origin)) &&
    !isLocalDevelopmentOrigin
  ) {
    return null;
  }

  return {
    'Access-Control-Allow-Origin': origin,
    Vary: 'Origin',
  };
}

function sendJson(response, statusCode, payload, cors = {}, extraHeaders = {}) {
  response.writeHead(statusCode, {
    ...cors,
    ...extraHeaders,
    'Cache-Control': 'no-store',
    'Content-Type': 'application/json; charset=utf-8',
    'X-Content-Type-Options': 'nosniff',
  });
  response.end(JSON.stringify(payload));
}

function safeErrorMessage(statusCode) {
  if (statusCode === 401 || statusCode === 403) {
    return 'Vimeo rechazó la autorización del backend.';
  }
  return 'No se pudo consultar Vimeo.';
}

function mapVideo(video) {
  if (
    video === null ||
    typeof video !== 'object' ||
    typeof video.uri !== 'string' ||
    !/^\/videos\/[A-Za-z0-9_-]+$/.test(video.uri)
  ) {
    return null;
  }

  const pictures = video.pictures;
  const sizes =
    pictures !== null && typeof pictures === 'object' ? pictures.sizes : null;
  const mappedSizes = Array.isArray(sizes)
    ? sizes
        .filter((size) => size !== null && typeof size === 'object')
        .map((size) => ({
          link: typeof size.link === 'string' ? size.link : '',
        }))
    : [];

  return {
    uri: video.uri,
    name: typeof video.name === 'string' ? video.name : '',
    description: typeof video.description === 'string' ? video.description : '',
    pictures: { sizes: mappedSizes },
  };
}

export function createVimeoServer({ env = process.env, fetchImpl = fetch } = {}) {
  return createServer(async (request, response) => {
    const cors = corsHeaders(request.headers.origin, env);
    if (cors === null) {
      sendJson(response, 403, {
        error: { message: 'El origen no está permitido.' },
      });
      return;
    }

    const send = (statusCode, payload, extraHeaders) =>
      sendJson(response, statusCode, payload, cors, extraHeaders);
    const requestUrl = new URL(request.url ?? '/', 'http://localhost');

    if (request.method === 'OPTIONS') {
      response.writeHead(204, {
        ...cors,
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      });
      response.end();
      return;
    }

    if (request.method === 'GET' && requestUrl.pathname === '/health') {
      send(200, { status: 'ok' });
      return;
    }

    if (
      request.method !== 'GET' ||
      requestUrl.pathname !== '/api/vimeo/search'
    ) {
      send(404, { error: { message: 'Ruta no encontrada.' } });
      return;
    }

    const query = requestUrl.searchParams.get('query')?.trim() ?? '';
    if (query.length === 0 || query.length > MAX_QUERY_LENGTH) {
      send(400, {
        error: {
          message: `La consulta debe tener entre 1 y ${MAX_QUERY_LENGTH} caracteres.`,
        },
      });
      return;
    }

    const token = env.VIMEO_ACCESS_TOKEN?.trim();
    if (token === undefined || token.length === 0) {
      send(503, {
        error: { message: 'El backend no tiene VIMEO_ACCESS_TOKEN configurado.' },
      });
      return;
    }

    const upstreamUrl = new URL(VIMEO_API_URL);
    upstreamUrl.searchParams.set('query', query);
    const requestedPage = Number.parseInt(requestUrl.searchParams.get('page') ?? '1', 10);
    const page = Number.isInteger(requestedPage) && requestedPage > 0 ? requestedPage : 1;
    upstreamUrl.searchParams.set('per_page', '25');
    upstreamUrl.searchParams.set('page', String(page));
    upstreamUrl.searchParams.set('fields', VIMEO_FIELDS);

    let upstream;
    try {
      upstream = await fetchImpl(upstreamUrl, {
        headers: {
          Accept: 'application/vnd.vimeo.*+json;version=3.4',
          Authorization: `Bearer ${token}`,
        },
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });
    } catch {
      send(502, {
        error: { message: 'No se pudo conectar con Vimeo.' },
      });
      return;
    }

    if (!upstream.ok) {
      const retryAfter = upstream.headers.get('retry-after');
      const retryHeaders =
        upstream.status === 429 && /^\d+$/.test(retryAfter ?? '')
          ? { 'Retry-After': retryAfter }
          : undefined;
      send(upstream.status, {
        error: { message: safeErrorMessage(upstream.status) },
      }, retryHeaders);
      return;
    }

    let payload;
    try {
      payload = await upstream.json();
    } catch {
      send(502, {
        error: { message: 'Vimeo devolvió una respuesta JSON no válida.' },
      });
      return;
    }

    if (!Array.isArray(payload?.data)) {
      send(502, {
        error: { message: 'Vimeo devolvió una colección no válida.' },
      });
      return;
    }

    send(200, {
      data: payload.data.map(mapVideo).filter((video) => video !== null),
    });
  });
}

if (
  process.argv[1] !== undefined &&
  import.meta.url === pathToFileURL(resolve(process.argv[1])).href
) {
  const host = process.env.HOST || '127.0.0.1';
  const rawPort = process.env.PORT || '8787';
  const port = Number(rawPort);
  if (
    !/^\d+$/.test(rawPort) ||
    !Number.isInteger(port) ||
    port < 1 ||
    port > 65535
  ) {
    throw new Error('PORT debe ser un puerto TCP entre 1 y 65535.');
  }

  createVimeoServer().listen(port, host, () => {
    console.log(`TokTik Vimeo backend escuchando en http://${host}:${port}`);
  });
}
