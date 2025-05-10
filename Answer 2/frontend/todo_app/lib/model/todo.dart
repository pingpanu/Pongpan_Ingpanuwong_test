class Todo{
  int id;
  String title;
  String detail;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.detail,
    required this.completed
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      detail: json['detail'],
      completed: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'detail': detail,
  };
}