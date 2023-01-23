import 'package:conduit/conduit.dart';
import 'package:dart_backend/model/category.dart';

class Note extends ManagedObject<_Note> implements _Note {}

@Table(name: 'notes')
class _Note {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? name;
  @Column()
  String? content;

  @Column(defaultValue: 'now()', omitByDefault: true)
  DateTime? createdDate;
  @Column(nullable: true, omitByDefault: true)
  DateTime? editedDate;

  @Relate(#notesList, isRequired: true, onDelete: DeleteRule.cascade)
  Category? category;
}
