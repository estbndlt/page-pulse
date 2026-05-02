import '../entities/synced_document_metadata.dart';

abstract interface class SyncRepository {
  Future<void> pushDocumentMetadata(SyncedDocumentMetadata metadata);
  Future<List<SyncedDocumentMetadata>> pullDocumentMetadata();
}
