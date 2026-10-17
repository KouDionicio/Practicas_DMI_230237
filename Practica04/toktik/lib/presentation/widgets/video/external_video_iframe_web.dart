import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

Widget buildExternalVideoIframe({
  required Uri embedUrl,
  required Uri watchUrl,
  required String title,
  required String providerName,
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
            'controls': '1',
            'loop': '1',
            'playlist': videoId, // necesario para que el loop funcione
            'playsinline': '1',
            'rel': '0',
          },
        )
      : embedUrl;

  return HtmlElementView.fromTagName(
    // al cambiar mute cambia la URL y se recrea el iframe
    key: ValueKey(playerUrl.toString()),
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
