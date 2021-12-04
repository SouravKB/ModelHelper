import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:model_annotations/model_annotations.dart';
import 'package:model_helper/src/util/sqfl_model_contents.dart';
import 'package:model_helper/src/util/string_extensions.dart';
import 'package:model_helper/src/util/type_extensions.dart';
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

      if (!field.type.isValidType())
        throw Exception('${model.modelType} cannot contain variable of type ${field.type}');

      String sqflType;
      if (field.type.isDartCoreInt || field.type.isDartCoreBool)
        sqflType = 'INTEGER';
      else if (field.type.isDartCoreNum || field.type.isDartCoreDouble)
        sqflType = 'REAL';
      else if (field.type.isDartCoreString || field.type.isDateTime)
        sqflType = 'TEXT';
      else if (field.type.isUint8List)
        sqflType = 'BLOB';
      else
        throw Exception('This should never execute!');

      if (field.type.nullabilitySuffix.index == 2) // NullabilitySuffix.none(2);
        sqflType += ' NOT NULL';

      code.writeln('  static const typeOf${field.name.capitalize()} = "${sqflType}";');
    });

    return code.toString();
  }

  String _toMapMethod(SqflModelContents model) {
    final code = StringBuffer();
    code.writeln('Map<String, Object?> toMap() => {');

    model.fields.forEach((field) {
      if (field.type.isDartCoreBool)
        code.writeln('  ${field.colField}: ${field.name} ? 1 : 0,');
      else if (field.type.isDateTime) if (field.type.nullabilitySuffix.index == 2)
        code.writeln('  ${field.colField}: ${field.name}.toIso8601String(),');
      else
        code.writeln('  ${field.colField}: ${field.name}?.toIso8601String(),');
      else
        code.writeln('  ${field.colField}: ${field.name},');
    });

    code.writeln('};');
    return code.toString();
  }

  String _fromMapMethod(SqflModelContents model) {
    final code = StringBuffer();
    code.writeln(
        'static ${model.cls.thisType} fromMap(Map<String, Object?> map) => ${model.cls.thisType}(');

    model.fields.forEach((field) {
      if (field.type.isDartCoreBool)
        code.writeln('  ${field.name}: map[${field.colField}] == 1,');
      else if (field.type.isDateTime)
        code.writeln('  ${field.name}: DateTime.parse(map[${field.colField}] as String),');
      else
        code.writeln('  ${field.name}: map[${field.colField}] as ${field.type},');
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
        isUint8List ||
        isDateTime;
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
