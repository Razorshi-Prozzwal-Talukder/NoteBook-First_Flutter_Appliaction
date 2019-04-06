import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notekeeper/models/note.dart';


class DatabaseHelper{

  static DatabaseHelper _databaseHelper; //singleton databasehelper
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); //name contructor to ceate instance of databasehelper

  factory DatabaseHelper(){
    if(_databaseHelper==null){
      _databaseHelper = DatabaseHelper._createInstance();//this is execute only once
    }
    return _databaseHelper;
  }

  Future<Database> get database async{

    if(_database == null){
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database>initializeDatabase() async{
//get the directory path for both android and ios to store database
  Directory directory = await getApplicationDocumentsDirectory();
  String path  = directory.path + 'notes.db';

  //open or create the database at a given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,'
    '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  //Fetch operation : get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db = await this.database;

    var result  = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  //Insert operation
  Future<int> insertNote(Note note) async{
    Database db = await this.database;

    var result  = await db.insert(noteTable, note.toMap());
    return result;
  }

  //update operation
  Future<int> updateNote(Note note) async{
    Database db = await this.database;

    var result  = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  //delete function
  Future<int> deleteNote(int id) async{
    Database db = await this.database;

    int result  = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  //get the number of object
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
 }

 //get map list, [list<map>] and convert it to 'Note list' [list<note>]
  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList();//get map list from database
    int count = noteMapList.length;//count the number of map entries in db table

    List<Note> noteList = List<Note>();
    //for loop to create a 'Note list' from a map list
    for(int i=0; i<count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }




}