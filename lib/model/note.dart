import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/category.dart';
import 'package:dart_backend/model/user.dart';

class Note extends ManagedObject<_Note> implements _Note {
  Map<String, dynamic> toJson() => asMap();
}

@Table(name: 'notes')
class _Note {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? name;
  String? number;
  @Column()
  String? content;
  double? summ;

  @Column(defaultValue: 'now()')
  DateTime? createdDate;
  @Column(nullable: true)
  DateTime? editedDate;

  @Relate(#notesList, isRequired: true, onDelete: DeleteRule.cascade)
  Category? category;

  @Relate(#notesList, isRequired: true, onDelete: DeleteRule.cascade)
  User? author;
}
