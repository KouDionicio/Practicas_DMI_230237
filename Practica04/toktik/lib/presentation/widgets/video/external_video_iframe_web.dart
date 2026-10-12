import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

Widget buildExternalVideoIframe({
  required Uri embedUrl,
  required Uri watchUrl,
  required String title,
  required String providerName,
  required VoidCallback onDocumentLoad,
  required VoidCallback onDocumentError,
}) {
  return HtmlElementView.fromTagName(
    tagName: 'div',
    onElementCreated: (element) {
      final container = element as web.HTMLDivElement;
      container.style.cssText =
          'display:flex;flex-direction:column;width:100%;height:100%;'
          'background:#000;';

      final player =
          web.document.createElement('iframe') as web.HTMLIFrameElement;
      player.src = embedUrl.toString();
      player.title = title;
      player.referrerPolicy = 'strict-origin-when-cross-origin';
      player.setAttribute(
        'allow',
        'autoplay; encrypted-media; picture-in-picture; fullscreen',
      );
      player.setAttribute('allowfullscreen', '');
      player.style.cssText = 'flex:1;width:100%;min-height:0;border:0;';
      player.addEventListener('load', ((web.Event _) => onDocumentLoad()).toJS);
      player.addEventListener(
        'error',
        ((web.Event _) => onDocumentError()).toJS,
      );

      final fallback = web.document.createElement('a') as web.HTMLAnchorElement;
      fallback.href = watchUrl.toString();
      fallback.target = '_blank';
      fallback.rel = 'noopener noreferrer';
      fallback.textContent = '¿No se reproduce? Abrir $providerName';
      fallback.style.cssText =
          'display:flex;align-items:center;justify-content:center;'
          'height:44px;box-sizing:border-box;color:#fff;background:#111;'
          'font:14px sans-serif;text-decoration:none;';

      container.appendChild(player);
      container.appendChild(fallback);
    },
  );
}
