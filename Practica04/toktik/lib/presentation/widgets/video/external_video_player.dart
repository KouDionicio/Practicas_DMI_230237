import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'peertube_media_resolver.dart';
import 'external_video_iframe_stub.dart'
    if (dart.library.js_interop) 'external_video_iframe_web.dart'
    as iframe;
import 'youtube_embed_config.dart';

final Set<String> _unembeddableYouTubeVideoIds = <String>{};

class ExternalVideoPlayer extends StatefulWidget {
  const ExternalVideoPlayer({
    super.key,
    required this.video,
    this.isActive = true,
    this.shouldLoad = true,
    this.isMuted = true,
    this.onDoubleTap,
    this.onYouTubeUnembeddable,
  });

  final ExternalVideo video;
  final bool isActive;
  final bool shouldLoad;
  final bool isMuted;
  final VoidCallback? onDoubleTap;
  final ValueChanged<String>? onYouTubeUnembeddable;

  static bool canEmbedYouTube(String videoId) =>
      !_unembeddableYouTubeVideoIds.contains(videoId);

  @override
  State<ExternalVideoPlayer> createState() => _ExternalVideoPlayerState();
}

class _ExternalVideoPlayerState extends State<ExternalVideoPlayer> {
  WebViewController? _controller;
  VideoPlayerController? _videoController;
  Uri? _embedUrl;
  Uri? _watchUrl;
  String? _error;
  int _progress = 0;
  bool _isLoading = false;
  bool _isPlaying = true;
  bool _isReady = false;
  Timer? _startupTimer;
  Timer? _preloadTimer;
  int _webRetryToken = 0;
  Stopwatch? _youtubeStartupWatch;
  bool _loggedYoutubeReady = false;

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

    if (widget.video.source == VideoSource.youtube &&
        !ExternalVideoPlayer.canEmbedYouTube(
          widget.video.id.substring('youtube:'.length),
        )) {
      _error = 'Este video no permite reproducción embebida.';
      return;
    }

    if (!widget.shouldLoad ||
        (widget.video.source != VideoSource.youtube && !widget.isActive)) {
      return;
    }
    if (widget.isActive) {
      _startReadyTimeout();
      if (!kIsWeb) unawaited(_initializePlayer());
    } else if (widget.video.source == VideoSource.youtube && !kIsWeb) {
      _scheduleYouTubePreload();
    }
  }

  Future<void> _initializePlayer() async {
    if (_controller != null || _videoController != null) return;
    if (widget.video.source == VideoSource.youtube &&
        !ExternalVideoPlayer.canEmbedYouTube(
          widget.video.id.substring('youtube:'.length),
        )) {
      if (mounted) setState(() => _error = 'Este video no permite reproducción embebida.');
      return;
    }
    _isReady = false;
    if (widget.isActive) _startReadyTimeout();
    if (!_supportsNativeWebView) {
      _error = 'El reproductor está disponible en Chrome, Android e iOS.';
      if (mounted) setState(() {});
      return;
    }

    if (widget.video.source == VideoSource.peertube) {
      await _initializePeerTubePlayer();
    } else {
      await _initializeNativePlayer();
    }
  }

  @override
  void didUpdateWidget(covariant ExternalVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.id != widget.video.id) {
      _releasePlayers();
      _error = null;
      _initializeUrls();
      if (widget.shouldLoad && !kIsWeb) unawaited(_initializePlayer());
      return;
    }
    if (oldWidget.shouldLoad && !widget.shouldLoad) {
      _preloadTimer?.cancel();
      unawaited(_pauseBeforeRelease());
      _releasePlayers();
      return;
    }
    if (!oldWidget.shouldLoad && widget.shouldLoad && !kIsWeb) {
      if (widget.video.source == VideoSource.youtube && !widget.isActive) {
        _scheduleYouTubePreload();
      } else {
        unawaited(_initializePlayer());
      }
      return;
    }
    if (!oldWidget.isActive && widget.isActive && !kIsWeb) {
      _preloadTimer?.cancel();
      _startReadyTimeout();
      final controller = _controller;
      if (controller != null && widget.video.source == VideoSource.youtube) {
        unawaited(controller.runJavaScript('toktikActivate();'));
      } else {
        unawaited(_initializePlayer());
      }
    } else if (oldWidget.isActive && !widget.isActive) {
      unawaited(_pauseBeforeRelease());
      if (widget.video.source != VideoSource.youtube || !widget.shouldLoad) {
        _releasePlayers();
      } else if (_controller != null) {
        unawaited(_controller!.runJavaScript('toktikPausePlayback();'));
      }
    }
    if (oldWidget.isMuted != widget.isMuted &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      unawaited(_videoController!.setVolume(widget.isMuted ? 0 : 1));
    }
    if (oldWidget.isMuted != widget.isMuted &&
        _controller != null &&
        (widget.video.source == VideoSource.youtube ||
            widget.video.source == VideoSource.vimeo)) {
      unawaited(_setWebViewMuted(widget.isMuted));
    }
  }

  void _initializeUrls() {
    final validation = _validateUrls(widget.video);
    _embedUrl = validation.embedUrl;
    _watchUrl = validation.watchUrl;
    _error = validation.error;
  }

  Future<void> _initializeNativePlayer() async {
    try {
      if (widget.video.source == VideoSource.youtube) {
        _youtubeStartupWatch = Stopwatch()..start();
        _loggedYoutubeReady = false;
      }
      final controller = WebViewController();
      _controller = controller;
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      if (widget.video.source == VideoSource.youtube &&
          defaultTargetPlatform == TargetPlatform.android &&
          controller.platform is AndroidWebViewController) {
        await (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }
      if (widget.video.source == VideoSource.youtube ||
          widget.video.source == VideoSource.vimeo) {
        await controller.addJavaScriptChannel(
          'TokTikPlayerReady',
          onMessageReceived: (_) {
            _startupTimer?.cancel();
            _reportYouTubeReady();
            if (mounted) setState(() => _isReady = true);
          },
        );
        if (widget.video.source == VideoSource.youtube) {
          await controller.addJavaScriptChannel(
            'TokTikPlayerState',
            onMessageReceived: (message) {
              if (!mounted) return;
              final state = message.message;
              if (state == 'playing') {
                _startupTimer?.cancel();
                _reportYouTubeReady();
                setState(() { _isReady = true; _isPlaying = true; });
              } else if (state == 'paused') {
                setState(() => _isPlaying = false);
              } else if (state == 'ready') {
                _startupTimer?.cancel();
                _reportYouTubeReady();
                setState(() => _isReady = true);
              }
            },
          );
        }
        await controller.addJavaScriptChannel(
          'TokTikPlayerError',
          onMessageReceived: (message) {
            if (!mounted) return;
            if (widget.video.source == VideoSource.youtube) {
              debugPrint('YouTube ${widget.video.id} error=${message.message} baseUrl/origin=$youtubeEmbedOrigin');
              _startupTimer?.cancel();
              final code = RegExp(r'\b(152|101|150|153)\b')
                  .firstMatch(message.message)
                  ?.group(1);
              if (code != null) {
                debugPrint('YouTube ${widget.video.id} non-embeddable code=$code baseUrl/origin=$youtubeEmbedOrigin');
                final id = widget.video.id.substring('youtube:'.length);
                _unembeddableYouTubeVideoIds.add(id);
                widget.onYouTubeUnembeddable?.call(id);
              }
            }
            setState(
              () => _error =
                  '${_providerName(widget.video.source)} no pudo '
                  'insertar este video (${_providerErrorMessage(widget.video.source, message.message)}).',
            );
          },
        );
      }
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              if (widget.video.source == VideoSource.youtube) {
                debugPrint('YouTube ${widget.video.id} WebView error=${error.errorCode} baseUrl/origin=$youtubeEmbedOrigin');
              }
              setState(
                () => _error =
                    'WebView informó error ${error.errorCode}: '
                    '${error.description}. URL: '
                    '${_displayUrl(error.url)}',
              );
            }
          },
          onHttpError: (error) {
            final statusCode = error.response?.statusCode;
            final requestUrl = error.request?.uri;
            if (widget.video.source == VideoSource.youtube &&
                requestUrl?.host == 'www.youtube.com' &&
                requestUrl?.path == '/api/timedtext') {
              debugPrint('YouTube ${widget.video.id} ignored captions HTTP $statusCode baseUrl/origin=$youtubeEmbedOrigin');
              return;
            }
            if (statusCode != null && requestUrl != null && mounted) {
              if (widget.video.source == VideoSource.youtube) {
                _startupTimer?.cancel();
                debugPrint('YouTube ${widget.video.id} HTTP error: $statusCode');
              }
              setState(
                () => _error =
                    'HTTP $statusCode al cargar '
                    '${_displayUrl(requestUrl.toString())} '
                    'en ${_providerName(widget.video.source)}.',
              );
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            final secureUrl =
                uri != null &&
                uri.scheme == 'https' &&
                uri.port == 443 &&
                uri.userInfo.isEmpty;
            if (secureUrl &&
                (!request.isMainFrame ||
                    _allowedNavigationHost(
                      widget.video.source,
                      uri.host,
                      peerTubeHost: widget.video.embedUrl.host,
                    ))) {
              return NavigationDecision.navigate;
            }
            if (request.isMainFrame && mounted) {
              setState(
                () => _error =
                    'Se bloqueó una navegación no permitida '
                    'por ${_providerName(widget.video.source)}: '
                    '${_displayUrl(request.url)}.',
              );
            }
            return NavigationDecision.prevent;
          },
        ),
      );
      if (widget.video.source == VideoSource.youtube ||
          widget.video.source == VideoSource.vimeo) {
        await controller.loadHtmlString(
          _providerIframeHtml(
            widget.video.source,
            _embedUrl!,
            isMuted: widget.isMuted,
            isActive: widget.isActive,
          ),
          baseUrl: widget.video.source == VideoSource.youtube
              ? youtubeEmbedOrigin
              : 'https://player.vimeo.com',
        );
      } else {
        await controller.loadRequest(_embedUrl!);
      }
      _isPlaying = true;
    } catch (exception) {
      if (mounted) {
        setState(
          () => _error =
              'No se pudo inicializar WebView: $exception. '
              'URL: ${_displayUrl(_embedUrl?.toString())}',
        );
      }
    }
  }

  Future<void> _initializePeerTubePlayer() async {
    final embedUrl = _embedUrl;
    if (embedUrl == null) return;
    setState(() => _isLoading = true);
    VideoPlayerController? controller;
    Uri? mediaUrl;
    try {
      final videoId = widget.video.id.substring('peertube:'.length);
      mediaUrl = await PeerTubeMediaResolver().resolve(embedUrl, videoId);
      controller = VideoPlayerController.networkUrl(mediaUrl);
      _videoController = controller;
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.isMuted ? 0 : 1);
      await controller.play();
      _startupTimer?.cancel();
      if (mounted) setState(() { _isLoading = false; _isReady = true; });
    } catch (exception) {
      final playerError = controller?.value.errorDescription;
      await controller?.dispose();
      if (identical(_videoController, controller)) _videoController = null;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error =
              'No se pudo reproducir PeerTube: $exception'
              '${playerError == null ? '' : ' ($playerError)'}. '
              'URL del medio: ${_displayUrl(mediaUrl?.toString() ?? embedUrl.toString())}';
        });
      }
    }
  }

  static String _providerIframeHtml(
    VideoSource source,
    Uri embedUrl, {
    required bool isMuted,
    required bool isActive,
  }) {
    final playerUrl = switch (source) {
      // CAMBIO: parámetros para que se vea como Short (sin controles, en loop).
      // Ya no es const porque 'playlist' usa el ID del video.
      VideoSource.youtube => embedUrl.replace(
        queryParameters: {
          'playsinline': '1',
          'rel': '0',
          'enablejsapi': '1',
          'controls': '0',
          'cc_load_policy': '0',
          'iv_load_policy': '3',
          'fs': '0',
          'loop': '1',
          'playlist': embedUrl.pathSegments.last,
          'modestbranding': '1',
          'origin': youtubeEmbedOrigin,
        },
      ),
      VideoSource.vimeo => embedUrl.replace(
        queryParameters: const {'playsinline': '1', 'dnt': '1'},
      ),
      VideoSource.local || VideoSource.peertube => embedUrl,
    };

    final playerScript = switch (source) {
      VideoSource.youtube =>
        '''
<script>
  var toktikPlayer;
  var toktikReady = false;
  var toktikMuted = $isMuted;
  var toktikPlaying = true;
  function onYouTubeIframeAPIReady() {
    toktikPlayer = new YT.Player('toktik-player', {
      videoId: '${embedUrl.pathSegments.last}',
      playerVars: {
        playsinline: 1,
        origin: '$youtubeEmbedOrigin',
        controls: 0,
        rel: 0,
        cc_load_policy: 0,
        fs: 0
      },
      events: {
        onReady: function(event) {
          toktikReady = true;
          TokTikPlayerReady.postMessage('ready');
          try { event.target.unloadModule('captions'); event.target.unloadModule('cc'); } catch (_) {}
          if (toktikMuted) event.target.mute(); else event.target.unMute();
          if (toktikPlaying && $isActive) event.target.playVideo();
          else { event.target.pauseVideo(); event.target.cueVideoById('${embedUrl.pathSegments.last}'); }
        },
        onError: function(event) {
          TokTikPlayerError.postMessage(String(event.data));
        },
        onStateChange: function(event) {
          if (event.data === YT.PlayerState.PLAYING) TokTikPlayerState.postMessage('playing');
          else if (event.data === YT.PlayerState.PAUSED) TokTikPlayerState.postMessage('paused');
          else if (event.data === YT.PlayerState.BUFFERING) TokTikPlayerState.postMessage('buffering');
        }
      }
    });
  }
  function toktikSetMuted(value) {
    toktikMuted = value;
    if (!toktikReady) return;
    if (value) toktikPlayer.mute(); else toktikPlayer.unMute();
  }
  function toktikTogglePlayback() {
    toktikPlaying = !toktikPlaying;
    if (!toktikReady) return;
    if (toktikPlaying) toktikPlayer.playVideo(); else toktikPlayer.pauseVideo();
    return toktikPlaying;
  }
  function toktikPausePlayback() {
    toktikPlaying = false;
    if (toktikReady) toktikPlayer.pauseVideo();
  }
  function toktikActivate() {
    toktikPlaying = true;
    if (toktikReady) toktikPlayer.playVideo();
  }
</script>
<script src="https://www.youtube.com/iframe_api"></script>
''',
      VideoSource.vimeo =>
        '''
<script src="https://player.vimeo.com/api/player.js"></script>
<script>
  var toktikPlayer;
  var toktikReady = false;
  var toktikMuted = $isMuted;
  var toktikPlaying = true;
  window.addEventListener('load', function() {
    toktikPlayer = new Vimeo.Player(document.getElementById('toktik-player'));
    toktikPlayer.ready().then(function() {
      toktikReady = true;
      TokTikPlayerReady.postMessage('ready');
      toktikPlayer.setMuted(toktikMuted);
      if (toktikPlaying) toktikPlayer.play(); else toktikPlayer.pause();
    }).catch(function(error) {
      TokTikPlayerError.postMessage(error.name + ': ' + error.message);
    });
  });
  function toktikSetMuted(value) {
    toktikMuted = value;
    if (toktikReady) toktikPlayer.setMuted(value);
  }
  function toktikTogglePlayback() {
    toktikPlaying = !toktikPlaying;
    if (!toktikReady) return toktikPlaying;
    if (toktikPlaying) toktikPlayer.play(); else toktikPlayer.pause();
    return toktikPlaying;
  }
  function toktikPausePlayback() {
    toktikPlaying = false;
    if (toktikReady) toktikPlayer.pause();
  }
</script>
''',
      VideoSource.local || VideoSource.peertube => '',
    };

    return '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <meta name="referrer" content="strict-origin-when-cross-origin">
  <style>
    html, body { margin: 0; width: 100%; height: 100%; overflow: hidden; background: #000; }
    iframe { display: block; width: 100%; height: 100%; border: 0; }
  </style>
  $playerScript
</head>
<body>
  ${source == VideoSource.vimeo ? '<iframe id="toktik-player" src="${_escapeHtml(playerUrl.toString())}" title="Vimeo player" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>' : '<div id="toktik-player" title="${_escapeHtml(source.name)} player"></div>'}
</body>
</html>
''';
  }

  static String _escapeHtml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  void _releasePlayers() {
    _preloadTimer?.cancel();
    _preloadTimer = null;
    _startupTimer?.cancel();
    _startupTimer = null;
    _controller = null;
    final videoController = _videoController;
    _videoController = null;
    if (videoController != null) {
      unawaited(videoController.pause().catchError((_) {}));
      unawaited(videoController.dispose());
    }
    _isLoading = false;
    _progress = 0;
    _isReady = false;
  }

  void _scheduleYouTubePreload() {
    _preloadTimer?.cancel();
    _preloadTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted && widget.shouldLoad && !widget.isActive) {
        unawaited(_initializePlayer());
      }
    });
  }

  Future<void> _pauseBeforeRelease() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.runJavaScript(
        'if (typeof toktikPausePlayback === "function") toktikPausePlayback();',
      );
    } catch (_) {
      // Releasing the WebView still terminates its player when JS is unavailable.
    }
  }

  void _startReadyTimeout() {
    _startupTimer?.cancel();
    _startupTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_isReady && widget.isActive) {
        if (widget.video.source == VideoSource.youtube) {
          debugPrint('YouTube ${widget.video.id} error=ready-timeout baseUrl/origin=$youtubeEmbedOrigin');
        }
        setState(() => _error = 'El reproductor tardó demasiado en iniciar.');
      }
    });
  }

  void _reportYouTubeReady() {
    if (widget.video.source != VideoSource.youtube || _loggedYoutubeReady) return;
    _loggedYoutubeReady = true;
    final elapsed = _youtubeStartupWatch?.elapsedMilliseconds;
    debugPrint('YouTube ${widget.video.id} ready in ${elapsed ?? 0}ms baseUrl/origin=$youtubeEmbedOrigin');
    _youtubeStartupWatch?.stop();
  }

  Future<void> _retry() async {
    _releasePlayers();
    if (mounted) {
      setState(() {
        _error = null;
        _isReady = false;
        _progress = 0;
        if (kIsWeb && widget.video.source == VideoSource.youtube) {
          _webRetryToken++;
          _startReadyTimeout();
        }
      });
    }
    if (widget.isActive && !kIsWeb) await _initializePlayer();
  }

  Future<void> _toggleWebViewPlayback() async {
    final videoController = _videoController;
    if (videoController != null && videoController.value.isInitialized) {
      setState(() => _isPlaying = !_isPlaying);
      if (_isPlaying) {
        await videoController.play();
      } else {
        await videoController.pause();
      }
      return;
    }
    final controller = _controller;
    if (controller == null) return;
    setState(() => _isPlaying = !_isPlaying);
    try {
      await controller.runJavaScript(
        'if (typeof toktikTogglePlayback === "function") '
        'toktikTogglePlayback();',
      );
    } catch (exception) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo cambiar la reproducción: $exception',
        );
      }
    }
  }

  Future<void> _setWebViewMuted(bool muted) async {
    try {
      await _controller?.runJavaScript(
        'if (typeof toktikSetMuted === "function") toktikSetMuted($muted);',
      );
    } catch (exception) {
      if (mounted) {
        setState(() => _error = 'No se pudo cambiar el sonido: $exception');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.video.source == VideoSource.youtube && widget.shouldLoad
          ? _buildThumbnailLoader()
          : const SizedBox.expand();
    }
    if (_error != null &&
        !kIsWeb &&
        widget.video.source == VideoSource.youtube) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
          ),
          const ColoredBox(color: Color.fromARGB(140, 0, 0, 0)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No se pudo abrir el reproductor de YouTube: $_error',
                      textAlign: TextAlign.center),
                  if (!ExternalVideoPlayer.canEmbedYouTube(
                    widget.video.id.substring('youtube:'.length),
                  ))
                    TextButton(onPressed: _openYouTube, child: const Text('Abrir en YouTube'))
                  else
                    TextButton(onPressed: _retry, child: const Text('Reintentar')),
                ],
              ),
            ),
          ),
        ],
      );
    }
    if (_error != null && !kIsWeb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No se pudo abrir el reproductor oficial: $_error'),
              if (_watchUrl != null &&
                  (widget.video.source != VideoSource.peertube ||
                      _controller != null))
                TextButton(
                  onPressed: _openOriginalVideo,
                  child: Text('Abrir en ${_providerName(widget.video.source)}'),
                ),
              TextButton(onPressed: _retry, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }
    if (kIsWeb &&
        widget.video.source == VideoSource.youtube &&
        !ExternalVideoPlayer.canEmbedYouTube(
          widget.video.id.substring('youtube:'.length),
        )) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
          ),
          Center(
            child: TextButton(
              onPressed: _openYouTube,
              child: const Text('Abrir en YouTube'),
            ),
          ),
        ],
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
              isMuted: widget.isMuted,
              embedUrl: embedUrl,
              watchUrl: widget.video.watchUrl,
              title: widget.video.title,
              providerName: _providerName(widget.video.source),
              retryToken: _webRetryToken,
              onDocumentLoad: () {
                // An iframe load event does not verify cross-origin playback.
                _startupTimer?.cancel();
                if (mounted) setState(() { _progress = 100; _isReady = true; });
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
              child: IgnorePointer(child: LinearProgressIndicator()),
            ),
          _buildThumbnailLoader(),
          if (_error != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  // CAMBIO: ya no existe el enlace debajo del reproductor.
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                    '$_error Si el proveedor bloquea la inserción, '
                    'desliza al siguiente video.',
                      ),
                      if (widget.video.source == VideoSource.youtube)
                        TextButton(onPressed: _retry, child: const Text('Reintentar')),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final videoController = _videoController;
    if (videoController != null && videoController.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: videoController.value.size.width,
                height: videoController.value.size.height,
                child: VideoPlayer(videoController),
              ),
            ),
          ),
          _buildThumbnailLoader(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleWebViewPlayback,
            onDoubleTap: widget.onDoubleTap,
            child: const ColoredBox(color: Colors.transparent),
          ),
          if (!_isPlaying)
            const Center(
              child: IgnorePointer(
                child: Icon(Icons.play_arrow, size: 76, color: Colors.white),
              ),
            ),
        ],
      );
    }
    final controller = _controller;
    if (controller == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se pudo inicializar el reproductor de '
              '${_providerName(widget.video.source)}. '
              'URL: ${_displayUrl(_embedUrl?.toString())}',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Volver al feed local'),
            ),
          ],
        ),
      );
    }
    return _buildNativeWebView(controller);
  }

  Widget _buildNativeWebView(WebViewController controller) => Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: Colors.black),
      Positioned.fill(
        child: IgnorePointer(child: WebViewWidget(controller: controller)),
      ),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleWebViewPlayback,
        onDoubleTap: widget.onDoubleTap,
        child: const ColoredBox(color: Colors.transparent),
      ),
      if (!_isPlaying)
        const Center(
          child: IgnorePointer(
            child: Icon(Icons.play_arrow, size: 76, color: Colors.white),
          ),
        ),
      if (_progress < 100)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: LinearProgressIndicator(value: _progress / 100),
          ),
        ),
      _buildThumbnailLoader(),
    ],
  );

  Widget _buildThumbnailLoader() => SizedBox.expand(
    child: IgnorePointer(
      child: AnimatedOpacity(
        opacity: _isReady && widget.isActive ? 0 : 1,
        duration: const Duration(milliseconds: 250),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_thumbnailUrl.isNotEmpty)
              Image.network(
                _thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
              )
            else
              const ColoredBox(color: Colors.black),
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    ),
  );

  String get _thumbnailUrl {
    if (widget.video.source == VideoSource.youtube) {
      final id = widget.video.id.substring('youtube:'.length);
      return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    }
    return widget.video.thumbnailUrl;
  }

  Future<void> _openOriginalVideo() async {
    final controller = _controller;
    final watchUrl = _watchUrl;
    if (controller == null || watchUrl == null) return;
    try {
      await controller.loadRequest(watchUrl);
    } catch (exception) {
      if (mounted) {
        setState(
          () => _error =
              'No se pudo abrir ${_displayUrl(watchUrl.toString())}: '
              '$exception',
        );
      }
    }
  }

  Future<void> _openYouTube() async {
    final id = widget.video.id.substring('youtube:'.length);
    final uri = Uri.https('www.youtube.com', '/watch', {'v': id});
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
        setState(() => _error = 'No se pudo abrir YouTube en este dispositivo.');
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'No se pudo abrir YouTube: $error');
    }
  }

  @override
  void dispose() {
    _releasePlayers();
    super.dispose();
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

  static String _providerErrorMessage(VideoSource source, String code) {
    if (source == VideoSource.youtube && code.startsWith('152')) {
      return 'error $code: YouTube rechazó la configuración de identidad del '
          'reproductor incrustado. Comprueba que la WebView envíe un origen y '
          'referer coherentes; no es un error de la API key de búsqueda.';
    }
    if (source == VideoSource.youtube && (code == '101' || code == '150')) {
      return 'error $code: el propietario no permite insertar el video.';
    }
    if (source == VideoSource.youtube && code == '100') {
      return 'error $code: el video no existe, es privado o fue retirado.';
    }
    return 'error $code';
  }

  static String _displayUrl(String? rawUrl) {
    if (rawUrl == null) return '(URL no disponible)';
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return '(URL inválida)';
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
    ).toString();
  }
}
