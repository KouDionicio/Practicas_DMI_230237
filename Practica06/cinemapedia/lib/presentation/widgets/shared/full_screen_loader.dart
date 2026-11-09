import 'package:flutter/material.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/l10n/app_localizations.dart';


class FullScreenLoader extends StatefulWidget {
  const FullScreenLoader({super.key});

  @override
  State<FullScreenLoader> createState() => _FullScreenLoaderState();
}

class _FullScreenLoaderState extends State<FullScreenLoader> {

  Stream<String>? _messages;
  String? _messagesLocale;

  Stream<String> getLoadingMessages( AppLocalizations l10n ) {
    final messages = <String>[
      l10n.loaderMessage1,
      l10n.loaderMessage2,
      l10n.loaderMessage3,
      l10n.loaderMessage4,
      l10n.loaderMessage5,
      l10n.loaderMessage6,
    ];

    return Stream.periodic( const Duration(milliseconds: 1200), (step) {
      return messages[step];
    }).take(messages.length);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // El stream se crea una sola vez (y de nuevo solo si cambia el idioma),
    // para que los mensajes no vuelvan a empezar en cada reconstrucción.
    final l10n = context.l10n;
    if ( _messagesLocale != l10n.localeName ) {
      _messagesLocale = l10n.localeName;
      _messages = getLoadingMessages(l10n);
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.loaderPleaseWait),
          const SizedBox(height: 10),
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 10),

          StreamBuilder(
            stream: _messages,
            builder: (context, snapshot) {
              if ( !snapshot.hasData ) return Text(l10n.loaderLoading);

              return Text( snapshot.data!, textAlign: TextAlign.center );
            },
          ),
        ],
      ),
    );
  }
}
