class SyncedDocumentMetadata {
  const SyncedDocumentMetadata({
    required this.id,
    required this.localDocumentId,
    required this.title,
    required this.updatedAt,
  });

  final String id;
  final String localDocumentId;
  final String title;
  final DateTime updatedAt;
}
