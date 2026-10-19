import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;
import 'youtube_embed_config.dart';

Widget buildExternalVideoIframe({
  required Uri embedUrl,
  required Uri watchUrl,
  required String title,
  required String providerName,
  required int retryToken,
  required bool isMuted,
  required VoidCallback onDocumentLoad,
  required VoidCallback onDocumentError,
}) {
  final videoId = embedUrl.pathSegments.isNotEmpty
      ? embedUrl.pathSegments.last
      : '';
  final playerUrl = providerName == 'YouTube'
      ? embedUrl.replace(
          queryParameters: {
            'autoplay': '1',
            'mute': isMuted ? '1' : '0',
            'controls': '0',
            'enablejsapi': '1',
            'cc_load_policy': '0',
            'iv_load_policy': '3',
            'fs': '0',
            'loop': '1',
            'playlist': videoId, // necesario para que el loop funcione
            'playsinline': '1',
            'rel': '0',
            'origin': youtubeEmbedOrigin,
          },
        )
      : embedUrl;

  return HtmlElementView.fromTagName(
    // El iframe de YouTube conserva su identidad al alternar mute.
    key: ValueKey(providerName == 'YouTube'
        ? 'youtube:$videoId:$retryToken'
        : playerUrl.toString()),
    tagName: 'div',
    onElementCreated: (element) {
      final container = element as web.HTMLDivElement;
      // pointer-events:none deja pasar el scroll y los gestos a Flutter
      container.style.cssText = 'width:100%;height:100%;background:#000;';

      final player =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      player.src = playerUrl.toString();
      player.title = title;
      player.referrerPolicy = 'strict-origin-when-cross-origin';
      player.setAttribute(
        'allow',
        'autoplay; encrypted-media; picture-in-picture; fullscreen',
      );
      player.style.cssText = 'width:100%;height:100%;border:0;';
      player.addEventListener('load', ((web.Event _) => onDocumentLoad()).toJS);
      player.addEventListener(
        'error',
        ((web.Event _) => onDocumentError()).toJS,
      );
      container.appendChild(player);
    },
  );
}
