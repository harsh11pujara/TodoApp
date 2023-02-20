part of 'todo_bloc.dart';

@immutable
abstract class TodoEvent {}

class InitialiseTodo extends TodoEvent{}

class CreateTodo extends TodoEvent{
  final TaskModel data;
  CreateTodo(this.data);
}

class DeleteTodo extends TodoEvent{

}

class UpdateTodo extends TodoEvent{
  final TaskModel data;
  final int index;
  UpdateTodo(this.data, this.index);
}

class ReadTodo extends TodoEvent{}
