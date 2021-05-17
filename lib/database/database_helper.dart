import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/account.dart';
class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String accountTable='account_table';
  String colId = 'id';
  String colName = 'name';

  DatabaseHelper._createInstance();
  factory DatabaseHelper(){
    if(_databaseHelper==null){
      _databaseHelper= DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $accountTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT)');
  }

  Future<Database> initializeDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'accounts.db';

    var accountDatabase = await openDatabase(path,version: 1,onCreate: _createDb);
    return accountDatabase;
  }

  Future<Database> get database async {
    if(_database==null){
      _database = await initializeDatabase();
    }
    return _database;
  }
//Fetch
  Future<List<Map<String,dynamic>>> getAccountMapList() async{
    Database db = await this.database;
    var result = await db.query(accountTable,orderBy: '$colId ASC');
    return result;
  }

  Future<List<Account>> getAccountList() async{
    var accountMapList = await getAccountMapList();
    List<Account> accountList = List<Account>();
    int count = accountMapList.length;

    for(int i=0;i<count;i++){
      accountList.add(Account.fromMapObject(accountMapList[i]));
    }
    return accountList;
  }
//insert
  Future<int> insertAccount(Account account) async{
    Database db = await this.database;
    var result = await db.insert(accountTable, account.toMap());
    return result;
  }
//update
  Future<int> updateAccount(Account account,int id) async{
    Database db = await this.database;

    var result = await db.update(accountTable, account.toMap(), where: '$colId= ?',whereArgs: [id]);
    return result;
  }

//delete
  Future<int> deleteAccount(int id) async{
    Database db = await this.database;
    var result = await db.delete(accountTable,where: '$colId= ?',whereArgs: [id]);
    return result;
  }
}