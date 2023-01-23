import 'dart:async';
import 'package:conduit_core/conduit_core.dart';

class Migration4 extends Migration {
  @override
  Future upgrade() async {
    database.createTable(SchemaTable("notes", [
      SchemaColumn("id", ManagedPropertyType.bigInteger,
          isPrimaryKey: true,
          autoincrement: true,
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("name", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: true),
      SchemaColumn("content", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("createdDate", ManagedPropertyType.datetime,
          isPrimaryKey: false,
          autoincrement: false,
          defaultValue: "now()",
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("editedDate", ManagedPropertyType.datetime,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: false,
          isNullable: true,
          isUnique: false)
    ]));
    database.createTable(SchemaTable("categories", [
      SchemaColumn("id", ManagedPropertyType.bigInteger,
          isPrimaryKey: true,
          autoincrement: true,
          isIndexed: false,
          isNullable: false,
          isUnique: false),
      SchemaColumn("name", ManagedPropertyType.string,
          isPrimaryKey: false,
          autoincrement: false,
          isIndexed: true,
          isNullable: false,
          isUnique: true)
    ]));
    database.addColumn(
        "notes",
        SchemaColumn.relationship("category", ManagedPropertyType.bigInteger,
            relatedTableName: "categories",
            relatedColumnName: "id",
            rule: DeleteRule.cascade,
            isNullable: false,
            isUnique: false));
    database.deleteTable("posts");
    database.deleteTable("authors");
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
