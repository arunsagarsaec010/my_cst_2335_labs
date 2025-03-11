import 'dart:async';
import 'package:floor/floor.dart';
import 'todo_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'todo_item.dart';

part 'database.g.dart';

@Database(version: 2, entities: [TodoItem])
abstract class AppDatabase extends FloorDatabase {
  TodoDao get todoDao;
}