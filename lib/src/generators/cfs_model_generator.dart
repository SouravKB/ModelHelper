import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:model_annotations/model_annotations.dart';
import 'package:model_helper/src/util/cfs_model_contents.dart';
import 'package:model_helper/src/util/string_extensions.dart';
import 'package:model_helper/src/util/type_extensions.dart';
import 'package:source_gen/source_gen.dart';

class CfsModelGenerator extends GeneratorForAnnotation<CfsModel> {
  static const _annotType = "CfsModel";

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, _) {
    if (element.kind != ElementKind.CLASS) {
      throw Exception(
          '$_annotType can only applied to classes. But ${element.name} is a ${element.kind}');
    }
    return _generateCode(CfsModelContents(element as ClassElement, _annotType));
  }

  String _generateCode(CfsModelContents model) {
    final code = StringBuffer();

    code.writeln('extension ${model.cls.name}Cfs on ${model.cls.thisType} {');

    code.writeln(_documentFields(model));
    code.writeln(_toMapMethod(model));
    code.writeln(_fromSnapshotMethod(model));

    code.writeln('}');
    return code.toString();
  }

  String _documentFields(CfsModelContents model) {
    final code = StringBuffer();

    code.writeln('  static const doc${model.cls.name.capitalize()} = "${model.cls.name}";');

    model.fields.forEach((field) {
      field.keyField = "key${field.name.capitalize()}";
      code.writeln('  static const ${field.keyField} = "${field.name}";');

      if (!field.type.isValidType())
        throw Exception('${model.modelType} cannot contain variable of type ${field.type}');
    });

    return code.toString();
  }

  String _toMapMethod(CfsModelContents model) {
    final code = StringBuffer();
    code.writeln('Map<String, Object?> toMap() => {');

    model.fields.forEach((field) {
      code.writeln('  ${field.keyField}: ${field.name},');
    });

    code.writeln('};');
    return code.toString();
  }

  String _fromSnapshotMethod(CfsModelContents model) {
    final code = StringBuffer();
    code.writeln(
        'static ${model.cls.thisType} fromSnapshot(DocumentSnapshot<Map<String, Object?>> snap) => ${model.cls.thisType}(');

    model.fields.forEach((field) {
      if (field == model.docKey)
        code.writeln('  ${field.name}: snap.id,');
      else if (field.type.isDartCoreInt) if (field.type.nullabilitySuffix.index == 2)
        code.writeln('  ${field.name}: (snap[${field.keyField}] as num).toInt(),');
      else
        code.writeln('  ${field.name}: (snap[${field.keyField}] as num?)?.toInt(),');
      else if (field.type.isDartCoreDouble) if (field.type.nullabilitySuffix.index == 2)
        code.writeln('  ${field.name}: (snap[${field.keyField}] as num).toDouble(),');
      else
        code.writeln('  ${field.name}: (snap[${field.keyField}] as num?)?.toDouble(),');
      else
        code.writeln('  ${field.name}: snap[${field.keyField}] as ${field.type},');
    });

    code.writeln(');');
    return code.toString();
  }
}

extension _ValidTypes on DartType {
  bool isValidType() {
    return isDartCoreNum ||
        isDartCoreInt ||
        isDartCoreDouble ||
        isDartCoreBool ||
        isDartCoreString ||
        isDartCoreList ||
        isDartCoreMap ||
        isUint8List ||
        isDateTime;
  }
}

var _keyFields = <FieldElement, String>{};

extension _KeyField on FieldElement {
  String get keyField {
    return _keyFields[this]!;
  }

  set keyField(String key) {
    _keyFields[this] = key;
  }
}
