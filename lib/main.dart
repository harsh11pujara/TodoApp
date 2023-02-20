import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app_bloc_sqlite/bloc/todo_bloc.dart';
import 'package:todo_app_bloc_sqlite/model/task_model.dart';
import 'package:todo_app_bloc_sqlite/notification_service.dart';
import 'package:todo_app_bloc_sqlite/utilities/databaseHelper.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BlocProvider(
      create: (context) => TodoBloc(DatabaseHelper())..add(InitialiseTodo()),
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationService _notificationService = NotificationService();
  final todoController = TextEditingController();
  String todo = '';
  int indexI = 0;
  List<TaskModel> task = [];
  DateTime? scheduleTime;
  bool reminderSet = false;
  int count = 0;
  bool isLoading = true;

  @override
  void initState() {
    BlocProvider.of<TodoBloc>(context).add(ReadTodo());
    _notificationService.initialiseNotification();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFF131236),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('TODO'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            margin: const EdgeInsets.only(left: 25, right: 25, top: 120, bottom: 0),
            height: height,
            width: width,
            child: Center(
              child: Column(children: [
                createTodoTile(),
                const SizedBox(
                  height: 35,
                ),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Reminder',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  height: 330,
                  child: BlocListener<TodoBloc, TodoState>(
                    listener: (context, state) {
                      if (state is TodoFetchLoadingState ||
                          state is TodoUpdatedLoadingState ||
                          state is TodoDeleteLoadingState ||
                          state is TodoInsertLoadingState) {
                        isLoading = true;
                      } else if (state is TodoFetchLoadedState) {
                        task = state.data!;
                        isLoading = false;
                      } else if (state is TodoUpdateCompleteState) {
                        task = state.data!;
                        isLoading = false;
                      } else if (state is TodoDeleteCompleteState) {
                        task = state.data!;
                        isLoading = false;
                      } else if (state is TodoInsertCompleteState) {
                        if (reminderSet) {
                          _notificationService.scheduleNotification(
                              state.data.id, todoController.text, "Hey it's time to complete ${todoController.text}",
                              alarmTime: scheduleTime!);
                          reminderSet = false;
                        }
                        // task.add(state.data);
                        todoController.clear();
                        isLoading = false;
                      } else {
                        throw 'error fetching data in main';
                      }
                    },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            itemCount: task.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              indexI = index;
                              return todoTile(width: width, index: index);
                            },
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 10),
                  height: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xFF131236),
                      boxShadow: const [
                        BoxShadow(color: Colors.white24, spreadRadius: 0, blurRadius: 8, offset: Offset(0, -5)),
                      ],
                      border: Border.all(color: const Color(0xFFbd1df2), width: 1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocListener<TodoBloc, TodoState>(
                          listener: (context, state) {
                            if (state is TodoFetchLoadedState ||
                                state is TodoDeleteCompleteState ||
                                state is TodoUpdateCompleteState ||
                                state is TodoInsertCompleteState) {
                              setState(() {});
                            }
                          },
                          child: Text(
                            '${task.length} items',
                            style: const TextStyle(color: Colors.white),
                          )),
                      ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<TodoBloc>(context).add(DeleteTodo());
                        },
                        style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: const Color(0xFF131236)),
                        child: const Center(child: Text('Clear Completed', style: TextStyle(color: Colors.white))),
                      )
                    ],
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget todoTile({required double width, required int index}) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        tileColor: const Color(0xFF2a2952),
        onTap: () {
          BlocProvider.of<TodoBloc>(context).add(UpdateTodo(task[index], index));
        },
        title: Text(
          task[index].taskName,
          style: const TextStyle(color: Colors.white),
        ),
        leading: Icon(
          task[index].isCompleted ? Icons.check_circle_sharp : Icons.radio_button_unchecked_sharp,
          color: const Color(0xFFbd1df2),
        ),
        trailing: Text(
          task[index].reminderTime,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget createTodoTile() {
    return Container(
      height: 50,
      width: 400,
      padding: const EdgeInsets.only(left: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF2a2952),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: 180,
              child: TextField(
                controller: todoController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Create a new todo...',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.name,
              )),
          IconButton(
              onPressed: () {
                // _notificationService.sendNotification('ToDo Title', 'This is body');
                DatePicker.showDateTimePicker(context, onChanged: (time) {}, onConfirm: (time) {
                  scheduleTime = time;
                  reminderSet = true;
                },
                    theme: const DatePickerTheme(
                        backgroundColor: Color(0xFF2a2952),
                        itemStyle: TextStyle(color: Colors.white),
                        cancelStyle: TextStyle(color: Color(0xFFbd1df2)),
                        doneStyle: TextStyle(color: Colors.green)));
              },
              icon: const Icon(
                Icons.timer,
                color: Colors.white,
              )),
          GestureDetector(
              onTap: () {
                if (todoController.text != '') {
                  var data = TaskModel(
                      id: task.isNotEmpty ? task[task.length - 1].id + 1 : 0,
                      taskName: todoController.text,
                      reminderTime: reminderSet ? '${scheduleTime!.hour}:${scheduleTime!.minute}' : '',
                      isCompleted: false);

                  BlocProvider.of<TodoBloc>(context).add(CreateTodo(data));
                }
              },
              child: Container(
                width: 50,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: const Center(
                  child: Icon(Icons.add),
                ),
              )),
        ],
      ),
    );
  }
}
