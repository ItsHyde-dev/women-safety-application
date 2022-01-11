import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:safety_application/models/email_model.dart';

class EmailDatabase{
  static final EmailDatabase instance = EmailDatabase._init();

  static Database? _database;

  EmailDatabase._init();

  Future<Database> get database async {
    if(_database != null) return _database!;

    _database = await _initDB('email.db');
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
        CREATE TABLE $tableEmail (
          ${emailFields.id} $idType,
          ${emailFields.mail} $textType,
          ${emailFields.location} $textType
          )
      ''');
  }

  Future <Mail> create (Mail mail) async{
    final db = await instance.database;

    final id = await db.insert(tableEmail, mail.toJson());
    return mail.copy(id: id);
  }

  Future<List<Mail>> readAllMails() async{
    final db = await instance.database;

    final result = await db.query(tableEmail);

    return result.map((json) => Mail.fromJson(json)).toList();
  }

  Future<int> update(Mail mail) async{
    final db = await instance.database;

    return db.update(
        tableEmail,
        mail.toJson(),
        where: '${emailFields.id} = ?',
        whereArgs: [mail.id]
    );
  }

  Future close() async{
    final db = await instance.database;
    db.close();
  }
}