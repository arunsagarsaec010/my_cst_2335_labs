import 'package:floor/floor.dart';

@Entity(tableName: 'TodoItem')
class TodoItem {
  static int ID = 1;

  @primaryKey
  final int id;

  final String todoItem;
  final String quantity;

  TodoItem(this.id, this.todoItem, this.quantity){
    if(id > ID){
      ID+=1;
    }
  }
}