// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTagline => 'Sua enciclopédia de cinema';

  @override
  String get splashLoading => 'Preparando sua programação…';

  @override
  String get menuOpenTooltip => 'Abrir menu';

  @override
  String get menuCloseTooltip => 'Fechar menu';

  @override
  String get menuSectionExplore => 'Explorar';

  @override
  String get menuSectionPreferences => 'Preferências';

  @override
  String get menuCurrentRegion => 'Região atual';

  @override
  String get navHome => 'Início';

  @override
  String get navCategories => 'Categorias';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navSettings => 'Configurações';

  @override
  String get searchTooltip => 'Pesquisar';

  @override
  String get searchFieldLabel => 'Pesquisar filmes';

  @override
  String get searchClearTooltip => 'Limpar pesquisa';

  @override
  String get searchEmptyHint => 'Digite o título de um filme';

  @override
  String searchNoResults(String query) {
    return 'Nenhum filme encontrado para “$query”';
  }

  @override
  String get featuredTitle => 'Destaques';

  @override
  String get nowPlayingTitle => 'Em cartaz';

  @override
  String get upcomingTitle => 'Em breve';

  @override
  String get upcomingSubtitle => 'Neste mês';

  @override
  String get popularTitle => 'Populares';

  @override
  String get topRatedTitle => 'Mais bem avaliados';

  @override
  String get topRatedSubtitle => 'De todos os tempos';

  @override
  String get carouselPrevious => 'Filme anterior';

  @override
  String get carouselNext => 'Próximo filme';

  @override
  String carouselPosition(String current, String total) {
    return '$current de $total';
  }

  @override
  String get carouselTripleTapHint =>
      'Toque três vezes em uma seta para ir ao primeiro ou ao último filme';

  @override
  String get carouselJumpedFirst => 'Primeiro filme';

  @override
  String get carouselJumpedLast => 'Último filme';

  @override
  String get localizedTitleLabel => 'Título localizado';

  @override
  String get originalTitleLabel => 'Título original';

  @override
  String get releaseDateLabel => 'Estreia';

  @override
  String get releaseDateUnknown => 'A confirmar';

  @override
  String votesCount(String count) {
    return '$count votos';
  }

  @override
  String ratingSemantics(String rating) {
    return 'Avaliação: $rating de 10';
  }

  @override
  String get certificationLabel => 'Classificação indicativa';

  @override
  String get certificationUnavailable => 'Classificação indisponível';

  @override
  String get certificationLoading => 'Carregando classificação…';

  @override
  String get certificationError =>
      'Não foi possível carregar a classificação. Toque para tentar novamente.';

  @override
  String get viewDetails => 'Ver detalhes';

  @override
  String get overviewTitle => 'Sinopse';

  @override
  String get overviewUnavailable => 'Nenhuma sinopse disponível neste idioma.';

  @override
  String get genresTitle => 'Gêneros';

  @override
  String get castTitle => 'Elenco';

  @override
  String get castEmpty => 'Nenhuma informação de elenco.';

  @override
  String get loaderPleaseWait => 'Aguarde, por favor';

  @override
  String get loaderLoading => 'Carregando…';

  @override
  String get loaderMessage1 => 'Carregando filmes';

  @override
  String get loaderMessage2 => 'Comprando pipoca';

  @override
  String get loaderMessage3 => 'Carregando populares';

  @override
  String get loaderMessage4 => 'Ligando para minha namorada';

  @override
  String get loaderMessage5 => 'Quase lá…';

  @override
  String get loaderMessage6 => 'Está demorando mais do que o esperado :(';

  @override
  String get errorLoadMovies => 'Não foi possível carregar os filmes';

  @override
  String get errorLoadMovie => 'Não foi possível carregar este filme';

  @override
  String get errorConnection =>
      'Verifique sua conexão com a internet e tente novamente.';

  @override
  String get errorUnauthorized =>
      'A chave do TMDB está ausente no arquivo .env ou é inválida.';

  @override
  String get errorServer => 'O serviço de filmes está indisponível no momento.';

  @override
  String get errorGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get favoritesEmptyTitle => 'Você ainda não tem favoritos';

  @override
  String get favoritesEmptyMessage =>
      'Os filmes que você marcar como favoritos aparecerão aqui.';

  @override
  String get categoriesEmptyTitle => 'Em breve';

  @override
  String get categoriesEmptyMessage =>
      'Estamos preparando a navegação por categorias.';

  @override
  String get goHome => 'Ir para o início';

  @override
  String get settingsHeadline => 'Seu cinema, seu idioma';

  @override
  String get settingsDescription =>
      'Escolha um país para definir o idioma do aplicativo, a programação regional do TMDB e as classificações indicativas.';

  @override
  String get settingsRegionSection => 'REGIÃO E IDIOMA';

  @override
  String get settingsInfoNote =>
      'O país define a região de consulta do TMDB, o idioma de todo o aplicativo e o sistema de classificação. Sua escolha é salva automaticamente neste dispositivo.';

  @override
  String get settingsSelected => 'Selecionado';

  @override
  String settingsRegionChanged(String country) {
    return 'Região atualizada: $country';
  }

  @override
  String settingsRatingSystem(String system) {
    return 'Classificação $system';
  }

  @override
  String get regionMX => 'México';

  @override
  String get regionUS => 'Estados Unidos';

  @override
  String get regionDE => 'Alemanha';

  @override
  String get regionFR => 'França';

  @override
  String get regionKR => 'Coreia do Sul';

  @override
  String get regionJP => 'Japão';

  @override
  String get regionBR => 'Brasil';

  @override
  String get regionEG => 'Egito';
}
