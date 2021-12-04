import 'package:analyzer/dart/element/element.dart';

class BasicModelContents {
  final String modelType;
  final ClassElement cls;
  final List<FieldElement> fields;

  BasicModelContents(ClassElement element, this.modelType)
      : cls = element,
        fields = element.fields {
    for (final field in fields)
      if (!field.isFinal)
        throw Exception(
          '$modelType can only applied to classes with all final fields. But ${element.name} is not final',
        );
  }
}
