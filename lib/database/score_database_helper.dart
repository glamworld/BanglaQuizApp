import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/score.dart';
class ScoreDatabaseHelper{
  static ScoreDatabaseHelper _databaseHelper;
  static Database _database;

  String scoreTable='score_table';
  String colId = 'id';
  String colName = 'name';
  String colScore = 'score';
  String colIncome = 'income';

  ScoreDatabaseHelper._createInstance();
  factory ScoreDatabaseHelper(){
    if(_databaseHelper==null){
      _databaseHelper= ScoreDatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $scoreTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, $colScore TEXT, $colIncome INTEGER)');
  }

  Future<Database> initializeDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'scores.db';

    var scoreDatabase = await openDatabase(path,version: 1,onCreate: _createDb);
    return scoreDatabase;
  }

  Future<Database> get database async {
    if(_database==null){
      _database = await initializeDatabase();
    }
    return _database;
  }
//Fetch
  Future<List<Map<String,dynamic>>> getScoreMapList() async{
    Database db = await this.database;
    var result = await db.query(scoreTable,orderBy: '$colIncome DESC');
    return result;
  }

  Future<List<Score>> getScoreList() async{
    var scoreMapList = await getScoreMapList();
    List<Score> scoreList = List<Score>();
    int count = scoreMapList.length;

    for(int i=0;i<count;i++){
      scoreList.add(Score.fromMapObject(scoreMapList[i]));
    }
    return scoreList;
  }
//insert
  Future<int> insertScore(Score score) async{
    Database db = await this.database;
    var result = await db.insert(scoreTable, score.toMap());
    return result;
  }

//delete
  Future<int> deleteScores() async{
    Database db = await this.database;
    var result = await db.delete(scoreTable);
    return result;
  }
}