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

extension FireBlobType on DartType {
  bool get isFireBlob {
    switch (this.toString()) {
      case 'Blob':
      case 'Blob?':
      case 'Blob*':
        return true;
      default:
        return false;
    }
  }
}

extension FireGeoPointType on DartType {
  bool get isFireGeoPoint {
    switch (this.toString()) {
      case 'GeoPoint':
      case 'GeoPoint?':
      case 'GeoPoint*':
        return true;
      default:
        return false;
    }
  }
}

extension FireTimestampType on DartType {
  bool get isFireTimestamp {
    switch (this.toString()) {
      case 'Timestamp':
      case 'Timestamp?':
      case 'Timestamp*':
        return true;
      default:
        return false;
    }
  }
}
