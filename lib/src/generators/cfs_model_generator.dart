import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:model_annotations/model_annotations.dart';
import 'package:model_helper/src/util/cfs_model_contents.dart';
import 'package:model_helper/src/util/string_extensions.dart';
import 'package:model_helper/src/util/type_extensions.dart';
import 'package:model_helper/src/util/type_suffix_extension.dart';
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
    });

    return code.toString();
  }

  String _toMapMethod(CfsModelContents model) {
    final code = StringBuffer();
    code.writeln('Map<String, Object?> toMap() => {');

    model.fields.forEach((field) {
      code.writeln('  ${field.keyField}: ${_getToMapString(field.type, field.name)},');
    });

    code.writeln('};');
    return code.toString();
  }

  String _fromSnapshotMethod(CfsModelContents model) {
    final code = StringBuffer();
    code.writeln(
        'static ${model.cls.thisType} fromSnapshot(DocumentSnapshot<Map<String, Object?>> snap) => ${model.cls.thisType}(');

    model.fields.forEach((field) {
      if (field == model.docKey) {
        code.writeln('  ${field.name}: snap.id,');
      } else {
        final fieldName = 'snap[${field.keyField}]';
        code.writeln('  ${field.name}: ${_getFromSnapString(field.type, fieldName)},');
      }
    });

    code.writeln(');');
    return code.toString();
  }

  String _getToMapString(DartType type, String field) {
    if (type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreNum ||
        type.isDartCoreBool ||
        type.isDartCoreString ||
        type.isDartCoreList ||
        type.isDartCoreMap ||
        type.isUint8List ||
        type.isFireBlob ||
        type.isDateTime ||
        type.isFireTimestamp ||
        type.isFireGeoPoint) {
      return '$field';
    }
    throw Exception('Invalid type "$type" in class annotated with "CfsModel" annotation.');
  }

  String _getFromSnapString(DartType type, String field) {
    if (type.isDartCoreInt) {
      return '($field as num${type.nullSuffix})${type.nullSuffix}.toInt()';
    }
    if (type.isDartCoreDouble) {
      return '($field as num${type.nullSuffix})${type.nullSuffix}.toDouble()';
    }
    if (type.isDartCoreNum || type.isDartCoreBool || type.isDartCoreString) {
      return '$field as $type';
    }
    if (type.isDartCoreList) {
      final paramType = (type as ParameterizedType).typeArguments[0];
      return '($field as List${type.nullSuffix})${type.nullSuffix}.map((item) => ${_getFromSnapString(paramType, 'item')})${type.nullSuffix}.toList(growable: false)';
    }
    if (type.isDartCoreMap) {
      final paramType = (type as ParameterizedType).typeArguments[1];
      return '($field as Map${type.nullSuffix})${type.nullSuffix}.map((key, value) => MapEntry(key, ${_getFromSnapString(paramType, 'value')}))';
    }
    if (type.isUint8List) {
      return '($field as Blob${type.nullSuffix})${type.nullSuffix}.bytes';
    }
    if (type.isFireBlob) {
      return '$field as Blob${type.nullSuffix}';
    }
    if (type.isDateTime) {
      return '($field as Timestamp${type.nullSuffix})${type.nullSuffix}.toDate()';
    }
    if (type.isFireTimestamp) {
      return '$field as Timestamp${type.nullSuffix}';
    }
    if (type.isFireGeoPoint) {
      return '$field as GeoPoint${type.nullSuffix}';
    }
    throw Exception('Invalid type "$type" in class annotated with "CfsModel" annotation.');
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
