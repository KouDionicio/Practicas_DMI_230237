import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'external_video_iframe_stub.dart'
    if (dart.library.js_interop) 'external_video_iframe_web.dart'
    as iframe;

class ExternalVideoPlayer extends StatefulWidget {
  const ExternalVideoPlayer({super.key, required this.video});

  final ExternalVideo video;

  @override
  State<ExternalVideoPlayer> createState() => _ExternalVideoPlayerState();
}

class _ExternalVideoPlayerState extends State<ExternalVideoPlayer> {
  WebViewController? _controller;
  Uri? _embedUrl;
  Uri? _watchUrl;
  String? _error;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    final validation = _validateUrls(widget.video);
    if (validation.error != null) {
      _error = validation.error;
      return;
    }
    _embedUrl = validation.embedUrl;
    _watchUrl = validation.watchUrl;

    if (kIsWeb) return;

    if (!_supportsNativeWebView) {
      _error = 'El reproductor está disponible en Chrome, Android e iOS.';
      return;
    }

    unawaited(_initializeNativePlayer());
  }

  Future<void> _initializeNativePlayer() async {
    try {
      final controller = WebViewController();
      _controller = controller;
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(
                () => _error = 'No se pudo cargar el reproductor oficial.',
              );
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null &&
                uri.scheme == 'https' &&
                uri.port == 443 &&
                uri.userInfo.isEmpty &&
                _allowedNavigationHost(
                  widget.video.source,
                  uri.host,
                  peerTubeHost: widget.video.embedUrl.host,
                )) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );
      await controller.loadRequest(_embedUrl!);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo inicializar el reproductor oficial.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && !kIsWeb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No se pudo abrir el reproductor oficial: $_error'),
              if (_watchUrl != null && _controller != null)
                TextButton(
                  onPressed: _openOriginalVideo,
                  child: Text('Abrir en ${_providerName(widget.video.source)}'),
                ),
            ],
          ),
        ),
      );
    }
    if (kIsWeb) {
      final embedUrl = _embedUrl;
      if (embedUrl == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudo abrir el reproductor oficial: '
              '${_error ?? 'La URL de inserción no es válida.'}',
            ),
          ),
        );
      }
      return Stack(
        children: [
          Positioned.fill(
            child: iframe.buildExternalVideoIframe(
              embedUrl: embedUrl,
              watchUrl: widget.video.watchUrl,
              title: widget.video.title,
              providerName: _providerName(widget.video.source),
              onDocumentLoad: () {
                // An iframe load event does not verify cross-origin playback.
                if (mounted) setState(() => _progress = 100);
              },
              onDocumentError: () {
                if (mounted) {
                  setState(() {
                    _progress = 100;
                    _error = 'El navegador no pudo cargar la página del reproductor.';
                  });
                }
              },
            ),
          ),
          if (_progress < 100)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
          if (_error != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '$_error Si el proveedor bloquea la inserción, '
                    'usa el enlace debajo del reproductor.',
                  ),
                ),
              ),
            ),
        ],
      );
    }
    final controller = _controller;
    if (controller == null) {
      return const Center(
        child: Text('No se pudo inicializar el reproductor.'),
      );
    }
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: WebViewWidget(controller: controller)),
              if (_progress < 100)
                LinearProgressIndicator(value: _progress / 100),
            ],
          ),
        ),
        TextButton(
          onPressed: _openOriginalVideo,
          child: Text('Abrir en ${_providerName(widget.video.source)}'),
        ),
      ],
    );
  }

  Future<void> _openOriginalVideo() async {
    final controller = _controller;
    final watchUrl = _watchUrl;
    if (controller == null || watchUrl == null) return;
    try {
      await controller.loadRequest(watchUrl);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo abrir el video en el sitio del proveedor.',
        );
      }
    }
  }

  bool get _supportsNativeWebView =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  static ({String? error, Uri? embedUrl, Uri? watchUrl}) _validateUrls(
    ExternalVideo video,
  ) {
    final embedUrl = video.embedUrl;
    if (embedUrl.scheme != 'https' ||
        embedUrl.port != 443 ||
        embedUrl.userInfo.isNotEmpty ||
        embedUrl.hasFragment ||
        !_allowedEmbedHost(video.source, embedUrl.host)) {
      return (
        error:
            'El reproductor debe usar HTTPS y el host oficial del proveedor.',
        embedUrl: null,
        watchUrl: null,
      );
    }
    final embedVideoId = switch (video.source) {
      VideoSource.local => null,
      VideoSource.youtube => _capture(
        RegExp(r'^/embed/([A-Za-z0-9_-]{1,128})$'),
        embedUrl.path,
      ),
      VideoSource.vimeo => _capture(
        RegExp(r'^/video/([0-9]+)$'),
        embedUrl.path,
      ),
      VideoSource.peertube => _peerTubePathId(embedUrl, 'embed'),
    };
    final entityVideoId = _capture(
      RegExp(switch (video.source) {
        VideoSource.local => r'^$',
        VideoSource.youtube => r'^youtube:([A-Za-z0-9_-]{1,128})$',
        VideoSource.vimeo => r'^vimeo:([0-9]{1,128})$',
        VideoSource.peertube =>
          r'^peertube:([0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12})$',
      }),
      video.id,
    );
    final videoId = embedVideoId;
    if (embedVideoId == null ||
        videoId == null ||
        entityVideoId != videoId ||
        (video.source != VideoSource.peertube &&
            !RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(videoId)) ||
        embedUrl.hasQuery) {
      return (
        error: 'La ruta no corresponde al reproductor oficial del proveedor.',
        embedUrl: null,
        watchUrl: null,
      );
    }

    final watchUrl = video.watchUrl;
    if (watchUrl.scheme != 'https' ||
        watchUrl.port != 443 ||
        watchUrl.userInfo.isNotEmpty ||
        watchUrl.hasFragment ||
        !_validWatchUrl(video.source, watchUrl, videoId, embedUrl: embedUrl)) {
      return (
        error: 'El enlace alternativo del video no es válido.',
        embedUrl: null,
        watchUrl: null,
      );
    }
    return (error: null, embedUrl: embedUrl, watchUrl: watchUrl);
  }

  static String? _capture(RegExp pattern, String value) =>
      pattern.firstMatch(value)?.group(1);

  static String? _peerTubePathId(Uri uri, String route) {
    final segments = uri.pathSegments;
    if (segments.length < 3 ||
        segments[segments.length - 3] != 'videos' ||
        segments[segments.length - 2] != route) {
      return null;
    }
    final id = segments.last;
    return RegExp(r'^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')
            .hasMatch(id)
        ? id
        : null;
  }

  static bool _validWatchUrl(
    VideoSource source,
    Uri uri,
    String videoId, {
    required Uri embedUrl,
  }) => switch (source) {
    VideoSource.youtube => _validYouTubeWatchUrl(uri, videoId),
    VideoSource.vimeo =>
      (uri.host == 'vimeo.com' ||
              uri.host == 'www.vimeo.com' ||
              uri.host == 'player.vimeo.com') &&
          uri.path == '/$videoId',
    VideoSource.peertube =>
      uri.host.toLowerCase() == embedUrl.host.toLowerCase() &&
          uri.port == embedUrl.port &&
          _validPeerTubeWatchPath(uri, embedUrl, videoId),
    VideoSource.local => false,
  };

  static bool _validYouTubeWatchUrl(Uri uri, String videoId) {
    final host = uri.host.toLowerCase();
    final normalizedPath = uri.path;
    final queryVideoId = uri.queryParameters['v'];

    if (host == 'youtu.be') {
      final segments = uri.pathSegments;
      return segments.length == 1 && segments.first == videoId;
    }

    if (host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com') {
      if (normalizedPath == '/watch' && queryVideoId == videoId) {
        return true;
      }
      if (normalizedPath == '/shorts/$videoId') {
        return true;
      }
      if (normalizedPath == '/embed/$videoId') {
        return true;
      }
    }

    return false;
  }

  static bool _allowedEmbedHost(VideoSource source, String host) =>
      switch (source) {
        VideoSource.youtube => host == 'www.youtube.com',
        VideoSource.vimeo => host == 'player.vimeo.com',
        VideoSource.peertube => host.isNotEmpty,
        VideoSource.local => false,
      };

  static bool _validPeerTubeWatchPath(
    Uri watchUrl,
    Uri embedUrl,
    String videoId,
  ) {
    final watchSegments = watchUrl.pathSegments;
    final embedSegments = embedUrl.pathSegments;
    if (embedSegments.length < 3) return false;
    final prefixLength = embedSegments.length - 3;
    if (watchSegments.length < prefixLength + 2) return false;
    for (var index = 0; index < prefixLength; index++) {
      if (watchSegments[index] != embedSegments[index]) return false;
    }
    final watchPath = watchSegments.skip(prefixLength).toList();
    if (watchPath.length == 3) {
      return watchPath[0] == 'videos' &&
          watchPath[1] == 'watch' &&
          watchPath[2] == videoId;
    }
    return watchPath.length == 2 &&
        watchPath[0] == 'w' &&
        RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(watchPath[1]);
  }

  static bool _allowedNavigationHost(
    VideoSource source,
    String host, {
    required String peerTubeHost,
  }) => switch (source) {
    VideoSource.youtube =>
      host == 'www.youtube.com' ||
          host == 'youtube.com' ||
          host == 'm.youtube.com' ||
          host == 'youtu.be',
    VideoSource.vimeo =>
      host == 'player.vimeo.com' ||
          host == 'vimeo.com' ||
          host == 'www.vimeo.com',
    VideoSource.peertube => host.toLowerCase() == peerTubeHost.toLowerCase(),
    VideoSource.local => false,
  };

  static String _providerName(VideoSource source) => switch (source) {
    VideoSource.local => 'Archivo local',
    VideoSource.youtube => 'YouTube',
    VideoSource.vimeo => 'Vimeo',
    VideoSource.peertube => 'PeerTube',
  };
}
