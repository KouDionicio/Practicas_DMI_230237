// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTagline => 'موسوعتك السينمائية';

  @override
  String get splashLoading => 'جارٍ تجهيز قائمة أفلامك…';

  @override
  String get menuOpenTooltip => 'فتح القائمة';

  @override
  String get menuCloseTooltip => 'إغلاق القائمة';

  @override
  String get menuSectionExplore => 'استكشاف';

  @override
  String get menuSectionPreferences => 'التفضيلات';

  @override
  String get menuCurrentRegion => 'المنطقة الحالية';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get searchTooltip => 'بحث';

  @override
  String get searchFieldLabel => 'ابحث عن أفلام';

  @override
  String get searchClearTooltip => 'مسح البحث';

  @override
  String get searchEmptyHint => 'اكتب عنوان فيلم';

  @override
  String searchNoResults(String query) {
    return 'لم نعثر على أفلام لـ «$query»';
  }

  @override
  String get featuredTitle => 'أفلام مميزة';

  @override
  String get nowPlayingTitle => 'يُعرض الآن';

  @override
  String get upcomingTitle => 'قريبًا';

  @override
  String get upcomingSubtitle => 'هذا الشهر';

  @override
  String get popularTitle => 'الأكثر شعبية';

  @override
  String get topRatedTitle => 'الأعلى تقييمًا';

  @override
  String get topRatedSubtitle => 'على الإطلاق';

  @override
  String get carouselPrevious => 'الفيلم السابق';

  @override
  String get carouselNext => 'الفيلم التالي';

  @override
  String carouselPosition(String current, String total) {
    return '$current من $total';
  }

  @override
  String get carouselTripleTapHint =>
      'انقر على السهم ثلاث مرات للانتقال إلى الفيلم الأول أو الأخير';

  @override
  String get carouselJumpedFirst => 'الفيلم الأول';

  @override
  String get carouselJumpedLast => 'الفيلم الأخير';

  @override
  String get localizedTitleLabel => 'العنوان المحلي';

  @override
  String get originalTitleLabel => 'العنوان الأصلي';

  @override
  String get releaseDateLabel => 'تاريخ الإصدار';

  @override
  String get releaseDateUnknown => 'لم يُحدَّد بعد';

  @override
  String votesCount(String count) {
    return 'عدد الأصوات: $count';
  }

  @override
  String ratingSemantics(String rating) {
    return 'التقييم: $rating من 10';
  }

  @override
  String get certificationLabel => 'التصنيف العمري';

  @override
  String get certificationUnavailable => 'التصنيف العمري غير متوفر';

  @override
  String get certificationLoading => 'جارٍ تحميل التصنيف العمري…';

  @override
  String get certificationError =>
      'تعذّر تحميل التصنيف العمري. انقر لإعادة المحاولة.';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get overviewTitle => 'نبذة';

  @override
  String get overviewUnavailable => 'لا تتوفر نبذة بهذه اللغة.';

  @override
  String get genresTitle => 'الأنواع';

  @override
  String get castTitle => 'طاقم التمثيل';

  @override
  String get castEmpty => 'لا تتوفر معلومات عن طاقم التمثيل.';

  @override
  String get loaderPleaseWait => 'يُرجى الانتظار';

  @override
  String get loaderLoading => 'جارٍ التحميل…';

  @override
  String get loaderMessage1 => 'جارٍ تحميل الأفلام';

  @override
  String get loaderMessage2 => 'نشتري الفشار';

  @override
  String get loaderMessage3 => 'جارٍ تحميل الأفلام الشائعة';

  @override
  String get loaderMessage4 => 'أتصل بصديقتي';

  @override
  String get loaderMessage5 => 'اقتربنا…';

  @override
  String get loaderMessage6 => 'يستغرق هذا وقتًا أطول من المتوقع :(';

  @override
  String get errorLoadMovies => 'تعذّر تحميل الأفلام';

  @override
  String get errorLoadMovie => 'تعذّر تحميل هذا الفيلم';

  @override
  String get errorConnection => 'تحقّق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get errorUnauthorized => 'مفتاح TMDB مفقود من ملف ‎.env أو غير صالح.';

  @override
  String get errorServer => 'خدمة الأفلام غير متاحة حاليًا.';

  @override
  String get errorGeneric => 'حدث خطأ ما. يُرجى المحاولة مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get favoritesEmptyTitle => 'لا توجد مفضلة بعد';

  @override
  String get favoritesEmptyMessage =>
      'ستظهر هنا الأفلام التي تضيفها إلى المفضلة.';

  @override
  String get goHome => 'الانتقال إلى الرئيسية';

  @override
  String get favoriteAdd => 'إضافة إلى المفضلة';

  @override
  String get favoriteRemove => 'إزالة من المفضلة';

  @override
  String favoriteAdded(String title) {
    return 'تمت إضافة «$title» إلى المفضلة';
  }

  @override
  String favoriteRemoved(String title) {
    return 'تمت إزالة «$title» من المفضلة';
  }

  @override
  String get undo => 'تراجع';

  @override
  String favoritesCount(String count) {
    return 'عدد الأفلام: $count';
  }

  @override
  String get categoriesHint => 'اختر نوعًا';

  @override
  String get categoryEmpty => 'لا توجد أفلام من هذا النوع في منطقتك.';

  @override
  String get errorLoadGenres => 'تعذّر تحميل الفئات';

  @override
  String get settingsHeadline => 'سينماك بلغتك';

  @override
  String get settingsDescription =>
      'اختر دولة لضبط لغة التطبيق وقائمة أفلام TMDB الإقليمية والتصنيفات العمرية.';

  @override
  String get settingsRegionSection => 'المنطقة واللغة';

  @override
  String get settingsInfoNote =>
      'تحدّد الدولة منطقة البحث في TMDB ولغة التطبيق بالكامل ونظام التصنيف العمري. يُحفظ اختيارك تلقائيًا على هذا الجهاز.';

  @override
  String get settingsSelected => 'محدد';

  @override
  String settingsRegionChanged(String country) {
    return 'تم تحديث المنطقة: $country';
  }

  @override
  String settingsRatingSystem(String system) {
    return 'التصنيف: $system';
  }

  @override
  String get regionMX => 'المكسيك';

  @override
  String get regionUS => 'الولايات المتحدة';

  @override
  String get regionDE => 'ألمانيا';

  @override
  String get regionFR => 'فرنسا';

  @override
  String get regionKR => 'كوريا الجنوبية';

  @override
  String get regionJP => 'اليابان';

  @override
  String get regionBR => 'البرازيل';

  @override
  String get regionEG => 'مصر';
}
