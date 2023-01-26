import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/note.dart';

class Category extends ManagedObject<_Category> implements _Category {
  Map<String, dynamic> toJson() => asMap();
}

@Table(name: 'categories')
class _Category {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? name;

  ManagedSet<Note>? notesList;
}
