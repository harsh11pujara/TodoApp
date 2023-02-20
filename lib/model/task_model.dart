class TaskModel {
  int id;
  String taskName;
  String reminderTime;
  bool isCompleted;

  TaskModel(
      {required this.id,
      required this.taskName,
      required this.reminderTime,
      required this.isCompleted});

  factory TaskModel.toJson(Map<String, dynamic> json) {
    bool temp = json['isCompleted'] == 1 ? true : false;
    return TaskModel(
      id: json['id'],
        taskName: json['task'],
        reminderTime: json['reminder'],
        isCompleted: temp);
  }

  Map<String, dynamic> toMap() {
    int temp = isCompleted ? 1 : 0;
    return {'id': id ,'task': taskName, 'reminder': reminderTime, 'isCompleted': temp};
  }
}
