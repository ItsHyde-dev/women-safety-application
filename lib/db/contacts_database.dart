import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:safety_application/models/contacts_model.dart';

class ContactsDatabase{

  static final ContactsDatabase instance = ContactsDatabase._init();

  static Database? _database;

  ContactsDatabase._init();

  Future<Database> get database async {
     if(_database != null) return _database!;

     _database = await _initDB('contacts.db');
     return _database!;
  }

  Future<Database> _initDB(String filePath) async{
     final dbPath = await getDatabasesPath();
     final path = join(dbPath, filePath);

     return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async{

      final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      final textType = 'TEXT NOT NULL';

      await db.execute('''
        CREATE TABLE $tableContacts (
          ${contactsFields.id} $idType,
          ${contactsFields.name} $textType,
          ${contactsFields.email} $textType,
          ${contactsFields.number} $textType
        )
      ''');
  }

  Future <Contact> create (Contact contact) async{
    final db = await instance.database;

    final id = await db.insert(tableContacts, contact.toJson());
    return contact.copy(id: id);
  }

  Future<Contact> readContacts(int id) async{
    final db = await instance.database;
    final maps = await db.query(
      tableContacts,
      columns: contactsFields.values,
      where: '${contactsFields.id} = ?',
      whereArgs: [id],
    );

    if(maps.isNotEmpty){
      return Contact.fromJson(maps.first);
    }

    else{
      throw Exception('ID $id not found');
    }
  }

  Future<List<Contact>> readAllContacts() async{
    final db = await instance.database;

    final result = await db.query(tableContacts);

    return result.map((json) => Contact.fromJson(json)).toList();
  }

  Future<int> update(Contact contact) async{
    final db = await instance.database;

    return db.update(
        tableContacts,
        contact.toJson(),
        where: '${contactsFields.id} = ?',
        whereArgs: [contact.id]
    );
  }

  Future<int> delete(int id) async{
    final db = await instance.database;

    return db.delete(tableContacts,
        where: '${contactsFields.id} = ?',
        whereArgs: [id]
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

}