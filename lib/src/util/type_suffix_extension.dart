import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

extension NullSuffix on DartType {
  String get nullSuffix {
    switch (nullabilitySuffix) {
      case NullabilitySuffix.question:
      case NullabilitySuffix.star:
        return '?';
      case NullabilitySuffix.none:
        return '';
    }
  }
}
