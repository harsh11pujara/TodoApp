part of 'todo_bloc.dart';

@immutable
abstract class TodoState {}

//initialisation
class TodoInitialState extends TodoState {}

//fetch data
class TodoFetchLoadingState extends TodoState{}

class TodoFetchLoadedState extends TodoState {
  final List<TaskModel>? data;
  TodoFetchLoadedState(this.data);
}

class TodoFetchErrorState extends TodoState {
  final String error;
  TodoFetchErrorState(this.error);
}

//update event
class TodoUpdatedLoadingState extends TodoState {}

class TodoUpdateCompleteState extends TodoState {
  final List<TaskModel>? data;
  TodoUpdateCompleteState(this.data);
}

class TodoUpdateErrorState extends TodoState {
  final String error;
  TodoUpdateErrorState(this.error);
}

//insert event
class TodoInsertLoadingState extends TodoState {}

class TodoInsertCompleteState extends TodoState {
  final TaskModel data;
  TodoInsertCompleteState(this.data);
}

class TodoInsertErrorState extends TodoState {
  final String error;
  TodoInsertErrorState(this.error);
}

//delete event
class TodoDeleteLoadingState extends TodoState {}

class TodoDeleteCompleteState extends TodoState {
  final List<TaskModel>? data;
  TodoDeleteCompleteState(this.data);
}

class TodoDeleteErrorState extends TodoState {
  final String error;
  TodoDeleteErrorState(this.error);
}
