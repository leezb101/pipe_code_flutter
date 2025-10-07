import 'package:dio/dio.dart';

import '../api_service_factory.dart';
import 'dio_document_service.dart';
import 'document_service.dart';

class DocumentServiceFactory {
  static DocumentService create() {
    final Dio dio = ApiServiceFactory.createBaseDio();
    return DioDocumentService(dio);
  }
}
