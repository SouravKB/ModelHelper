library model_helper;

import 'package:build/build.dart';
import 'package:model_helper/src/generators/sqfl_model_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder sqflHelperBuilder(BuilderOptions options) =>
    SharedPartBuilder([SqflModelGenerator()], 'sqfl_helper');
