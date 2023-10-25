import 'package:shouz/Models/Event.dart';

import 'Style.dart';

class ExtensionEnumToValue {
  ExtensionEnumToValue();

  static String transformTypeVotesInfoLoadInCorrectValue(TypeVotesInfoLoad typeVotesInfoLoad, Event? event) {
    switch(typeVotesInfoLoad) {
      case TypeVotesInfoLoad.with_event:
        return event!.id;
      default:
        return '';
    }
  }
}