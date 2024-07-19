import 'package:path/path.dart' as P;
import 'package:sqflite/sqflite.dart';
import 'package:virtualcard_holder/models/contactmodel.dart';

class db_vcard {
  final String _createTableContact = '''create table $tableContact(
  $tblContactColId integer primary key autoincrement,
  $tblContactColName text,
  $tblContactColMobile text,
  $tblContactColEmail text,
  $tblContactColAddress text,
  $tblContactColCompany text,
  $tblContactColDesignation text,
  $tblContactColWebsite text,
  $tblContactColImage text,
  $tblContactColFavorite integer)''';

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    final dbPath = P.join(root, 'contact.db');
    return openDatabase(dbPath, version: 2, onCreate: (db, version) {
      db.execute(_createTableContact);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion == 1) {
        await db.execute('alter table $tableContact rename to ${'contact_old'}');
        await db.execute(_createTableContact);
        final rows = await db.query('contact_old');
        for (var row in rows) {
          await db.insert(tableContact, row);
        }
        await db.execute('drop table if exists ${'contact_old'}');
      }
    });
  }

  Future<int> insertContact(ContactModel contactModel) async {
    final db = await _open();
    return db.insert(tableContact, contactModel.toMap());
  }

  Future<List<ContactModel>> getAllContacts() async {
    final db = await _open();
    final mapList = await db.query(tableContact);
    return List.generate(mapList.length, (index) => ContactModel.fromMap(mapList[index]));
  }

  Future<ContactModel> getContactById(int id) async {
    final db = await _open();
    final mapList = await db.query(tableContact, where: '$tblContactColId = ?', whereArgs: [id]);
    return ContactModel.fromMap(mapList.first);
  }

  Future<List<ContactModel>> getAllFavoriteContacts() async {
    final db = await _open();
    final mapList = await db.query(tableContact, where: '$tblContactColFavorite = ?', whereArgs: [1]);
    return List.generate(mapList.length, (index) => ContactModel.fromMap(mapList[index]));
  }

  Future<int> deleteContact(int id) async {
    final db = await _open();
    return db.delete(tableContact, where: '$tblContactColId = ?', whereArgs: [id]);
  }

  Future<int> updateFavorite(int id, int value) async {
    final db = await _open();
    return db.update(tableContact, {tblContactColFavorite: value}, where: '$tblContactColId = ?', whereArgs: [id]);
  }

  Future<int> updateContact(ContactModel contactModel) async {
    final db = await _open();
    return db.update(tableContact, contactModel.toMap(), where: '$tblContactColId = ?', whereArgs: [contactModel.id]);
  }
}
