import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:simple_list_bloc/simple_list_bloc.dart';

// sample data set
List<DemoModel> locale = [
  DemoModel("af", "Afrikaans"),
  DemoModel("ar", "Arabic"),
  DemoModel("bn", "Bangla"),
  DemoModel("bs", "Bosnian"),
  DemoModel("bg", "Bulgarian"),
  DemoModel("ca", "Catalan"),
  DemoModel("zh", "中文"),
  DemoModel("hr", "Croatian"),
  DemoModel("cs", "Czech"),
  DemoModel("da", "Danish"),
  DemoModel("nl", "Dutch"),
  DemoModel("en", "English"),
  DemoModel("et", "Estonian"),
  DemoModel("fj", "Fijian"),
  DemoModel("fil", "Filipino"),
  DemoModel("fi", "Finnish"),
  DemoModel("fr", "French"),
  DemoModel("de", "German"),
  DemoModel("el", "Greek"),
  DemoModel("gu", "Gujarati"),
  DemoModel("ht", "Haitian_Creole"),
  DemoModel("he", "Hebrew"),
  DemoModel("hi", "Hindi"),
  DemoModel("mww", "Hmong Daw"),
  DemoModel("hu", "Hungarian"),
  DemoModel("is", "Icelandic"),
  DemoModel("id", "Indonesian"),
  DemoModel("ga", "Irish"),
  DemoModel("it", "Italian"),
  DemoModel("ja", "Japanese"),
  DemoModel("kn", "Kannada"),
  DemoModel("kk", "Kazakh"),
  DemoModel("sw", "Kiswahili"),
  DemoModel("ko", "Korean"),
  DemoModel("lv", "Latvian"),
  DemoModel("lt", "Lithuanian"),
  DemoModel("mg", "Malagasy"),
  DemoModel("ms", "Malay"),
  DemoModel("ml", "Malayalam"),
  DemoModel("mt", "Maltese"),
  DemoModel("mi", "Maori"),
  DemoModel("mr", "Marathi"),
  DemoModel("nb", "Norwegian"),
  DemoModel("fa", "Persian"),
  DemoModel("pl", "Polish"),
  DemoModel("pt", "Portuguese"),
  DemoModel("pa", "Punjabi"),
  DemoModel("otq", "Queretaro_Otomi"),
  DemoModel("ro", "Romanian"),
  DemoModel("ru", "Russian"),
  DemoModel("sm", "Samoan"),
  DemoModel("sr", "Serbian"),
  DemoModel("sk", "Slovak"),
  DemoModel("sl", "Slovenian"),
  DemoModel("es", "Spanish"),
  DemoModel("sv", "Swedish"),
  DemoModel("ty", "Tahitian"),
  DemoModel("ta", "Tamil"),
  DemoModel("te", "Telugu"),
  DemoModel("th", "Thai"),
  DemoModel("to", "Tongan"),
  DemoModel("tr", "Turkish"),
  DemoModel("uk", "Ukrainian"),
  DemoModel("ur", "Urdu"),
  DemoModel("vi", "Vietnamese"),
  DemoModel("cy", "Welsh"),
  DemoModel("yua", "Yucatec Maya"),
];

/// Sample Data model
///
/// [locale] unique locale code or entry's id
///
/// [text] language or text to display
///
/// [weight] used for sorting
class DemoModel extends Equatable {
  final String locale;
  final String language;
  DemoModel(this.locale, this.language);

  @override
  List<Object> get props => [locale];
}

/// List bloc to demostrate filter and pagination
/// view count = 20, event debounce = 50ms
class DemoListBloc extends ListBloc<DemoModel, String> {
  DemoListBloc(ListState<DemoModel, String> state) : super(state, viewCount: 20, debounce: 50, debug: true);

  @override
  Future<List<DemoModel>> fetchItems(filter, int skip, int count) async {
    /// delay to show loading indicator
    if (filter != null && filter.isNotEmpty) {
      // filter list
      List<DemoModel> filteredList = [];
      var f = filter.toLowerCase();
      for (var i = 0; i < locale.length; i++) {
        if (locale[i].language.toLowerCase().contains(f)) {
          filteredList.add(locale[i]);
        }
      }
      if (filteredList.length == 0) {
        return [];
      }
      // return filtered list according to skip + count page
      return filteredList.sublist(skip, min(filteredList.length, skip + count));
    }
    await Future.delayed(Duration(seconds: 1));
    // return list according to skip + count page
    return locale.sublist(skip, min(locale.length, skip + count));
  }
}
