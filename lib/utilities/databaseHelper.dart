import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app_bloc_sqlite/model/task_model.dart';



class DatabaseHelper {
  final String tableName = 'ToDo';
  final String columnId = 'id';
  final String taskName = 'task';
  final String reminderTime = 'reminder';
  final String isCompleted = 'isCompleted';

  static Database? _database;
  // static DatabaseHelper? _helper;

  // DatabaseHelper._init();
  // factory DatabaseHelper(){
  //   if(_helper == null){
  //     _helper = DatabaseHelper._init();
  //   }
  //   return _helper!;
  // }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    String path = join(dir,'todoDB.db');
    // var path = '${dir}todoDB.db';
    var database = openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $tableName (
        $columnId INTEGER primary key ,
        $taskName TEXT not null,
        $reminderTime TEXT,
        $isCompleted INTEGER
        )
      ''');
      },
    );
    return database;
  }

  void insertTodo(TaskModel taskData) async{
    var db = await database;
    var result = await db.insert(tableName, taskData.toMap());
    print ('inserting data result $result');
  }

  Future<List<TaskModel>> fetchData() async{

    var db = await database;
    var data = await db.query(tableName);
    var result = data.map((e) => TaskModel.toJson(e)).toList();
    print('fetched data $data');
    return result;
  }

  void updateTodo(TaskModel taskData) async{

    var db = await database;
    var result = await db.update(tableName, taskData.toMap(),where: '$columnId = ?',whereArgs: [taskData.id]);
    print ('data updated $result');
  }

  void deleteTodo() async{
    var db = await database;
    var result = db.delete(tableName,where: '$isCompleted = 1');
  }
}
