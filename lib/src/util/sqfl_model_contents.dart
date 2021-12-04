import 'package:analyzer/dart/element/element.dart';
import 'package:model_helper/src/util/basic_model_contents.dart';

class SqflModelContents extends BasicModelContents {
  SqflModelContents(ClassElement element, String annotType) : super(element, annotType) {}
}
