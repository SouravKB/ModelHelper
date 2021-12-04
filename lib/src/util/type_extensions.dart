import 'package:analyzer/dart/element/type.dart';

extension BlobType on DartType {
  bool get isUint8List {
    switch (this.toString()) {
      case 'Uint8List':
      case 'Uint8List?':
      case 'Uint8List*':
        return true;
      default:
        return false;
    }
  }
}

extension DateTimeType on DartType {
  bool get isDateTime {
    switch (this.toString()) {
      case 'DateTime':
      case 'DateTime?':
      case 'DateTime*':
        return true;
      default:
        return false;
    }
  }
}
