// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTagline => '당신의 영화 백과사전';

  @override
  String get splashLoading => '영화 목록을 준비하고 있어요…';

  @override
  String get menuOpenTooltip => '메뉴 열기';

  @override
  String get menuCloseTooltip => '메뉴 닫기';

  @override
  String get menuSectionExplore => '둘러보기';

  @override
  String get menuSectionPreferences => '환경 설정';

  @override
  String get menuCurrentRegion => '현재 지역';

  @override
  String get navHome => '홈';

  @override
  String get navCategories => '카테고리';

  @override
  String get navFavorites => '즐겨찾기';

  @override
  String get navSettings => '설정';

  @override
  String get searchTooltip => '검색';

  @override
  String get searchFieldLabel => '영화 검색';

  @override
  String get searchClearTooltip => '검색어 지우기';

  @override
  String get searchEmptyHint => '영화 제목을 입력하세요';

  @override
  String searchNoResults(String query) {
    return '‘$query’에 대한 영화를 찾지 못했어요';
  }

  @override
  String get featuredTitle => '추천작';

  @override
  String get nowPlayingTitle => '현재 상영작';

  @override
  String get upcomingTitle => '개봉 예정';

  @override
  String get upcomingSubtitle => '이번 달';

  @override
  String get popularTitle => '인기 영화';

  @override
  String get topRatedTitle => '최고 평점';

  @override
  String get topRatedSubtitle => '역대';

  @override
  String get carouselPrevious => '이전 영화';

  @override
  String get carouselNext => '다음 영화';

  @override
  String carouselPosition(String current, String total) {
    return '$total편 중 $current번째';
  }

  @override
  String get carouselTripleTapHint => '화살표를 세 번 누르면 첫 번째 또는 마지막 영화로 이동해요';

  @override
  String get carouselJumpedFirst => '첫 번째 영화';

  @override
  String get carouselJumpedLast => '마지막 영화';

  @override
  String get localizedTitleLabel => '현지화 제목';

  @override
  String get originalTitleLabel => '원제';

  @override
  String get releaseDateLabel => '개봉';

  @override
  String get releaseDateUnknown => '미정';

  @override
  String votesCount(String count) {
    return '$count표';
  }

  @override
  String ratingSemantics(String rating) {
    return '평점: 10점 만점에 $rating점';
  }

  @override
  String get certificationLabel => '관람 등급';

  @override
  String get certificationUnavailable => '관람 등급 정보 없음';

  @override
  String get certificationLoading => '관람 등급을 불러오는 중…';

  @override
  String get certificationError => '관람 등급을 불러오지 못했어요. 눌러서 다시 시도하세요.';

  @override
  String get viewDetails => '상세 정보 보기';

  @override
  String get overviewTitle => '줄거리';

  @override
  String get overviewUnavailable => '이 언어로 된 줄거리가 없어요.';

  @override
  String get genresTitle => '장르';

  @override
  String get castTitle => '출연진';

  @override
  String get castEmpty => '출연진 정보가 없어요.';

  @override
  String get loaderPleaseWait => '잠시만 기다려 주세요';

  @override
  String get loaderLoading => '불러오는 중…';

  @override
  String get loaderMessage1 => '영화를 불러오는 중';

  @override
  String get loaderMessage2 => '팝콘 사는 중';

  @override
  String get loaderMessage3 => '인기 영화를 불러오는 중';

  @override
  String get loaderMessage4 => '여자친구에게 전화하는 중';

  @override
  String get loaderMessage5 => '거의 다 됐어요…';

  @override
  String get loaderMessage6 => '예상보다 오래 걸리고 있어요 :(';

  @override
  String get errorLoadMovies => '영화를 불러오지 못했어요';

  @override
  String get errorLoadMovie => '이 영화를 불러오지 못했어요';

  @override
  String get errorConnection => '인터넷 연결을 확인한 후 다시 시도해 주세요.';

  @override
  String get errorUnauthorized => 'TMDB 키가 .env 파일에 없거나 올바르지 않아요.';

  @override
  String get errorServer => '지금은 영화 서비스를 이용할 수 없어요.';

  @override
  String get errorGeneric => '문제가 발생했어요. 다시 시도해 주세요.';

  @override
  String get retry => '다시 시도';

  @override
  String get favoritesEmptyTitle => '아직 즐겨찾기가 없어요';

  @override
  String get favoritesEmptyMessage => '즐겨찾기한 영화가 여기에 표시돼요.';

  @override
  String get goHome => '홈으로 이동';

  @override
  String get favoriteAdd => '즐겨찾기에 추가';

  @override
  String get favoriteRemove => '즐겨찾기에서 삭제';

  @override
  String favoriteAdded(String title) {
    return '‘$title’을(를) 즐겨찾기에 추가했어요';
  }

  @override
  String favoriteRemoved(String title) {
    return '‘$title’을(를) 즐겨찾기에서 삭제했어요';
  }

  @override
  String get undo => '실행 취소';

  @override
  String favoritesCount(String count) {
    return '영화 $count편';
  }

  @override
  String get categoriesHint => '장르를 선택하세요';

  @override
  String get categoryEmpty => '이 지역에는 이 장르의 영화가 없어요.';

  @override
  String get errorLoadGenres => '카테고리를 불러오지 못했어요';

  @override
  String get settingsHeadline => '나의 영화, 나의 언어';

  @override
  String get settingsDescription =>
      '국가를 선택하면 앱 언어, TMDB 지역 상영 정보, 관람 등급이 함께 바뀌어요.';

  @override
  String get settingsRegionSection => '지역 및 언어';

  @override
  String get settingsInfoNote =>
      '국가에 따라 TMDB 조회 지역, 앱 전체 언어, 등급 체계가 결정돼요. 선택한 내용은 이 기기에 자동으로 저장돼요.';

  @override
  String get settingsSelected => '선택됨';

  @override
  String settingsRegionChanged(String country) {
    return '지역이 변경되었어요: $country';
  }

  @override
  String settingsRatingSystem(String system) {
    return '등급: $system';
  }

  @override
  String get regionMX => '멕시코';

  @override
  String get regionUS => '미국';

  @override
  String get regionDE => '독일';

  @override
  String get regionFR => '프랑스';

  @override
  String get regionKR => '대한민국';

  @override
  String get regionJP => '일본';

  @override
  String get regionBR => '브라질';

  @override
  String get regionEG => '이집트';
}
