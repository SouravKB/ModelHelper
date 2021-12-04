import 'package:analyzer/dart/element/element.dart';
import 'package:model_annotations/model_annotations.dart';
import 'package:model_helper/src/util/basic_model_contents.dart';
import 'package:source_gen/source_gen.dart';

class CfsModelContents extends BasicModelContents {
  CfsModelContents(ClassElement element, String annotType) : super(element, annotType) {
    _extractDocumentKeyIndex();
  }

  static const _typeChecker = TypeChecker.fromRuntime(DocumentKey);
  FieldElement? docKey = null;

  void _extractDocumentKeyIndex() {
    fields.forEach((field) {
      if (_typeChecker.hasAnnotationOfExact(field)) {
        if (docKey != null)
          throw Exception('${modelType} can only contain a single document key');
        else if (!field.type.isDartCoreString)
          throw Exception('Document key ${field.name} can only be of type String');
        else
          docKey = field;
      }
    });
  }
}
