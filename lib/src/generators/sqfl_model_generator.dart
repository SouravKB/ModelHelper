import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:model_annotations/model_annotations.dart';
import 'package:model_helper/src/util/sqfl_model_contents.dart';
import 'package:model_helper/src/util/string_extensions.dart';
import 'package:model_helper/src/util/type_extensions.dart';
import 'package:model_helper/src/util/type_suffix_extension.dart';
import 'package:source_gen/source_gen.dart';

class SqflModelGenerator extends GeneratorForAnnotation<SqflModel> {
  static const _annotType = "SqflModel";

  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, _) {
    if (element.kind != ElementKind.CLASS) {
      throw Exception(
          '$_annotType can only applied to classes. But ${element.name} is a ${element.kind}');
    }
    return _generateCode(SqflModelContents(element as ClassElement, _annotType));
  }

  String _generateCode(SqflModelContents model) {
    final code = StringBuffer();

    code.writeln('extension ${model.cls.name}Sqfl on ${model.cls.thisType} {');

    code.writeln(_tableFields(model));
    code.writeln(_toMapMethod(model));
    code.writeln(_fromMapMethod(model));

    code.writeln('}');
    return code.toString();
  }

  String _tableFields(SqflModelContents model) {
    final code = StringBuffer();

    code.writeln('  static const table${model.cls.name.capitalize()} = "${model.cls.name}";');

    model.fields.forEach((field) {
      field.colField = "col${field.name.capitalize()}";
      code.writeln('  static const ${field.colField} = "${field.name}";');

      code.writeln(
          '  static const typeOf${field.name.capitalize()} = "${_getSqflType(field.type)}";');
    });

    return code.toString();
  }

  String _toMapMethod(SqflModelContents model) {
    final code = StringBuffer();
    code.writeln('Map<String, Object?> toMap() => {');

    model.fields.forEach((field) {
      code.writeln('  ${field.colField}: ${_getToMapString(field.type, field.name)},');
    });

    code.writeln('};');
    return code.toString();
  }

  String _fromMapMethod(SqflModelContents model) {
    final code = StringBuffer();
    code.writeln(
        'static ${model.cls.thisType} fromMap(Map<String, Object?> map) => ${model.cls.thisType}(');

    model.fields.forEach((field) {
      final fieldName = 'map[${field.colField}]';
      code.writeln('  ${field.name}: ${_getFromMapString(field.type, fieldName)},');
    });

    code.writeln(');');
    return code.toString();
  }

  String _getSqflType(DartType type) {
    final nullability = type.nullabilitySuffix == NullabilitySuffix.none ? ' NOT NULL' : '';

    if (type.isDartCoreInt || type.isDartCoreBool || type.isDateTime) {
      return 'INTEGER' + nullability;
    }
    if (type.isDartCoreNum || type.isDartCoreDouble) {
      return 'REAL' + nullability;
    }
    if (type.isDartCoreString) {
      return 'TEXT' + nullability;
    }
    if (type.isUint8List) {
      return 'BLOB' + nullability;
    }
    throw Exception('Invalid type "$type" in class annotated with "CfsModel" annotation.');
  }

  String _getToMapString(DartType type, String field) {
    if (type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreNum ||
        type.isDartCoreString ||
        type.isUint8List) {
      return '$field';
    }
    if (type.isDartCoreBool) {
      return '$field ? 1 : 0';
    }
    if (type.isDateTime) {
      return '$field${type.nullSuffix}.millisecondsSinceEpoch';
    }
    throw Exception('Invalid type "$type" in class annotated with "CfsModel" annotation.');
  }

  String _getFromMapString(DartType type, String field) {
    if (type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreNum ||
        type.isDartCoreString ||
        type.isUint8List) {
      return '$field as $type';
    }
    if (type.isDartCoreBool) {
      return '$field == 1';
    }
    if (type.isDateTime) {
      if (type.nullabilitySuffix == NullabilitySuffix.none)
        return 'DateTime.fromMillisecondsSinceEpoch($field as int)';
      else
        return '$field != null ? DateTime.fromMillisecondsSinceEpoch($field as int) : null';
    }
    throw Exception('Invalid type "$type" in class annotated with "CfsModel" annotation.');
  }
}

var _colFields = <FieldElement, String>{};

extension _ColumnField on FieldElement {
  String get colField {
    return _colFields[this]!;
  }

  set colField(String col) {
    _colFields[this] = col;
  }
}
