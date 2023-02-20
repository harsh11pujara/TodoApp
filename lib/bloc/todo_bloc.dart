import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:todo_app_bloc_sqlite/model/task_model.dart';
import 'package:todo_app_bloc_sqlite/utilities/databaseHelper.dart';

part 'todo_event.dart';

part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final DatabaseHelper _databaseHelper;
  List<TaskModel> task = [];

  TodoBloc(this._databaseHelper) : super(TodoInitialState()) {
    on((event, emit) async {
      if (event is InitialiseTodo) {
        try {
          await _databaseHelper.initializeDatabase();
        } catch (e) {
          throw 'error in initialisation $e';
        }
      } else if (event is CreateTodo) {
        emit(TodoInsertLoadingState());
        try {
          task.add(event.data);
          _databaseHelper.insertTodo(event.data);
          emit(TodoInsertCompleteState(event.data));
        } catch (e) {
          emit(TodoInsertErrorState('error in create $e'));
        }
      } else if (event is ReadTodo) {
        emit(TodoFetchLoadingState());
        try {
          task = await _databaseHelper.fetchData();
          emit(TodoFetchLoadedState(task));
        } catch (e) {
          emit(TodoFetchErrorState('error in read $e'));
        }
      } else if (event is UpdateTodo) {
        emit(TodoUpdatedLoadingState());
        try {
          task[event.index].isCompleted = !task[event.index].isCompleted;
          _databaseHelper.updateTodo(event.data);
          emit(TodoUpdateCompleteState(task));
        } catch (e) {
          emit(TodoUpdateErrorState('error in update $e'));
        }
      } else if (event is DeleteTodo) {
        emit(TodoDeleteLoadingState());
        try {
          task.removeWhere((element) {
            return element.isCompleted == true;
          });
          _databaseHelper.deleteTodo();
          emit(TodoDeleteCompleteState(task));
        } catch (e) {
          emit(TodoDeleteErrorState('error in delete $e'));
        }
      }
    });
  }
}
