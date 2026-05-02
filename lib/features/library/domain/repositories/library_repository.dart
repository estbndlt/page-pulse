import '../entities/book.dart';

abstract interface class LibraryRepository {
  Stream<List<Book>> watchBooks();
  Future<Book?> getBook(String id);
  Future<void> saveBook(Book book);
  Future<void> deleteBook(String id);
}
