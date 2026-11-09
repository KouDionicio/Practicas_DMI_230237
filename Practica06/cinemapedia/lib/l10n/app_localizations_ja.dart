// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTagline => 'あなたの映画百科事典';

  @override
  String get splashLoading => '上映作品を準備しています…';

  @override
  String get menuOpenTooltip => 'メニューを開く';

  @override
  String get menuCloseTooltip => 'メニューを閉じる';

  @override
  String get menuSectionExplore => '探す';

  @override
  String get menuSectionPreferences => '環境設定';

  @override
  String get menuCurrentRegion => '現在の地域';

  @override
  String get navHome => 'ホーム';

  @override
  String get navCategories => 'カテゴリー';

  @override
  String get navFavorites => 'お気に入り';

  @override
  String get navSettings => '設定';

  @override
  String get searchTooltip => '検索';

  @override
  String get searchFieldLabel => '映画を検索';

  @override
  String get searchClearTooltip => '検索をクリア';

  @override
  String get searchEmptyHint => '映画のタイトルを入力してください';

  @override
  String searchNoResults(String query) {
    return '「$query」に一致する映画は見つかりませんでした';
  }

  @override
  String get featuredTitle => '注目作品';

  @override
  String get nowPlayingTitle => '上映中';

  @override
  String get upcomingTitle => '近日公開';

  @override
  String get upcomingSubtitle => '今月';

  @override
  String get popularTitle => '人気作品';

  @override
  String get topRatedTitle => '高評価';

  @override
  String get topRatedSubtitle => '歴代';

  @override
  String get carouselPrevious => '前の映画';

  @override
  String get carouselNext => '次の映画';

  @override
  String carouselPosition(String current, String total) {
    return '$total作品中$current番目';
  }

  @override
  String get carouselTripleTapHint => '矢印を3回タップすると最初または最後の映画に移動します';

  @override
  String get carouselJumpedFirst => '最初の映画';

  @override
  String get carouselJumpedLast => '最後の映画';

  @override
  String get localizedTitleLabel => 'ローカライズ版タイトル';

  @override
  String get originalTitleLabel => '原題';

  @override
  String get releaseDateLabel => '公開日';

  @override
  String get releaseDateUnknown => '未定';

  @override
  String votesCount(String count) {
    return '$count票';
  }

  @override
  String ratingSemantics(String rating) {
    return '評価: 10点中$rating点';
  }

  @override
  String get certificationLabel => '年齢区分';

  @override
  String get certificationUnavailable => '年齢区分の情報なし';

  @override
  String get certificationLoading => '年齢区分を読み込み中…';

  @override
  String get certificationError => '年齢区分を読み込めませんでした。タップして再試行してください。';

  @override
  String get viewDetails => '詳細を見る';

  @override
  String get overviewTitle => 'あらすじ';

  @override
  String get overviewUnavailable => 'この言語のあらすじはありません。';

  @override
  String get genresTitle => 'ジャンル';

  @override
  String get castTitle => 'キャスト';

  @override
  String get castEmpty => 'キャスト情報はありません。';

  @override
  String get loaderPleaseWait => 'しばらくお待ちください';

  @override
  String get loaderLoading => '読み込み中…';

  @override
  String get loaderMessage1 => '映画を読み込み中';

  @override
  String get loaderMessage2 => 'ポップコーンを購入中';

  @override
  String get loaderMessage3 => '人気作品を読み込み中';

  @override
  String get loaderMessage4 => '彼女に電話中';

  @override
  String get loaderMessage5 => 'もうすぐです…';

  @override
  String get loaderMessage6 => '思ったより時間がかかっています :(';

  @override
  String get errorLoadMovies => '映画を読み込めませんでした';

  @override
  String get errorLoadMovie => 'この映画を読み込めませんでした';

  @override
  String get errorConnection => 'インターネット接続を確認して、もう一度お試しください。';

  @override
  String get errorUnauthorized => 'TMDBキーが.envファイルにないか、無効です。';

  @override
  String get errorServer => '現在、映画サービスを利用できません。';

  @override
  String get errorGeneric => '問題が発生しました。もう一度お試しください。';

  @override
  String get retry => '再試行';

  @override
  String get favoritesEmptyTitle => 'お気に入りはまだありません';

  @override
  String get favoritesEmptyMessage => 'お気に入りに追加した映画がここに表示されます。';

  @override
  String get categoriesEmptyTitle => '準備中';

  @override
  String get categoriesEmptyMessage => 'カテゴリー別の閲覧機能を準備しています。';

  @override
  String get goHome => 'ホームへ';

  @override
  String get settingsHeadline => 'あなたの映画を、あなたの言語で';

  @override
  String get settingsDescription => '国を選ぶと、アプリの言語、TMDBの地域別ラインナップ、年齢区分が切り替わります。';

  @override
  String get settingsRegionSection => '地域と言語';

  @override
  String get settingsInfoNote =>
      '国の設定によって、TMDBの検索地域、アプリ全体の言語、年齢区分の基準が決まります。選択内容はこの端末に自動で保存されます。';

  @override
  String get settingsSelected => '選択中';

  @override
  String settingsRegionChanged(String country) {
    return '地域を変更しました: $country';
  }

  @override
  String settingsRatingSystem(String system) {
    return '区分: $system';
  }

  @override
  String get regionMX => 'メキシコ';

  @override
  String get regionUS => 'アメリカ合衆国';

  @override
  String get regionDE => 'ドイツ';

  @override
  String get regionFR => 'フランス';

  @override
  String get regionKR => '韓国';

  @override
  String get regionJP => '日本';

  @override
  String get regionBR => 'ブラジル';

  @override
  String get regionEG => 'エジプト';
}
